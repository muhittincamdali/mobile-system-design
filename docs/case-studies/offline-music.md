# Case study: offline music downloads

"Design offline listening for a Spotify-style app": the user marks playlists for download and
plays them without a network.

## 1. Requirements

**Functional**

- Download a playlist or album for offline listening; show progress per track.
- Play downloaded tracks without a network, including in the background.
- Keep downloads in sync when the playlist changes.
- Remove downloads, and respect a storage limit the user can set.

**Non-functional**

- Downloads continue when the app is in the background and resume after interruptions.
- Downloads use Wi-Fi only unless the user allows cellular.
- Content stays protected: files are encrypted and licenses expire if the account is not seen
  online for a set period.

**Out of scope:** the streaming protocol, recommendations, podcasts.

## 2. Estimates

At 160 kbit/s, a 3.5-minute track is about 4.2 MB; a 300-track library is about 1.3 GB. That
drives the design: downloads take minutes to hours, must survive app restarts, and need
storage management.

## 3. High-level design

```text
LibraryScreen ── DownloadsViewModel ── DownloadManager ─┬─ DownloadQueue (database: tasks, state)
                                                        ├─ background URLSession / WorkManager
                                                        ├─ TrackStore (encrypted files, index)
                                                        └─ LicenseStore (keys, expiry)
Player ── TrackStore + LicenseStore
SyncClient ── playlist changes ── DownloadManager
```

## 4. API and data

```http
GET /v1/playlists/{id}/offline-manifest
→ { "version": 18, "tracks": [{ "id": "t_1", "url": "…", "bytes": 4201334, "sha256": "…" }] }

GET <track url>           Range: bytes=1048576-        (resumable)
POST /v1/licenses         { "track_ids": [...] }   → keys, expiry
```

Local tables: `download_tasks` (track, state, bytes_done, attempts, error), `tracks` (id, file,
size, last_played), `playlists_offline` (id, manifest_version).

## 5. Deep dives

### Download state machine

```text
queued → downloading → verifying → done
   ↑          │             │
   └── waiting_for_network ◄┘ (temporary error, backoff)
              │
              └→ failed (permanent: 404, license refused)
```

Persist the state of each task, so the queue survives the app being killed. Verify each file
against its checksum before marking it done.

### Background transfer

On iOS, a background `URLSession`
([`URLSessionConfiguration.background(withIdentifier:)`](<https://developer.apple.com/documentation/foundation/urlsessionconfiguration/background(withidentifier:)>))
lets the system continue downloads while the app is suspended and relaunches the app to
handle completion. On Android, a
[WorkManager](https://developer.android.com/develop/background-work/background-tasks/persistent)
worker with network and storage constraints does the same, using a foreground service for
long-running transfers. Use HTTP range requests to resume partial downloads.

### Storage management

Check free space before starting, keep a per-app limit the user can change, and evict the
least recently played downloads that are not in a pinned playlist when the limit is reached.
Store the files in Application Support (iOS) or app-specific storage (Android), excluded from
backups, never in caches: the system may delete caches, and the user expects downloads to stay.

### Keeping downloads in sync

When the manifest version changes, compute the difference: queue new tracks, remove tracks no
longer in any offline playlist, keep the rest. Do it in the background on Wi-Fi.

### Protection and licenses

Encrypt each file with a per-track key; keep keys in the Keychain (iOS) or encrypted with a
key from the Android Keystore. Licenses carry an expiry; the app renews them whenever it is
online and refuses to play when they have expired, after warning the user.

### Playback offline

The player resolves a track to the local file first and only then to the stream. Play counts
recorded offline go into an [outbox](../topics/offline-and-sync.md#the-outbox) and are sent
later, with idempotency keys so a retried upload is not counted twice.

## 6. Trade-offs and metrics

- Higher bitrate sounds better and costs storage and download time; offer a quality setting.
- Aggressive eviction saves space and risks deleting what the user wanted; prefer asking.
- Measure: download success rate, time to download a playlist, bytes resumed vs restarted,
  playback failures offline, license renewals.

# Examples

## SystemDesignLab

An iOS and macOS app with one screen per building block of the guide. It talks to an
in-process server (`LabServer.swift`) that answers like a real API — pages with cursors, `503`
with `Retry-After` while it is down, `notConnectedToInternet` while the device is offline — so
the labs run without a backend and behave the same on every run.

| Lab           | What to try                                                                                                                                                                                                                               | Package types                                        |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| Feed          | Switch the server to **Flaky** or **Down** and pull to refresh. Retries hide single failures, three failed calls open the circuit breaker, and cached pages keep the feed readable.                                                       | `Paginator`, `Retrier`, `CircuitBreaker`, `LRUCache` |
| Offline likes | Like posts while **Offline** is on, then turn it off. The outbox sends the changes in order, each with its idempotency key; tapping twice replaces the waiting change. The queue is saved in Application Support and survives a relaunch. | `Outbox`, `FileOutboxStore`                          |
| Sync          | Save on the phone, sync, save on the tablet (its clock is behind) and sync again: the later edit wins on both. Move the tablet's clock more than 60 s ahead and its timestamps are rejected.                                              | `HybridLogicalClock`, `LWWRegister`                  |
| Estimator     | Change the inputs and read the request rate, bandwidth, storage and phone budgets.                                                                                                                                                        | `CapacityEstimate`, `ClientBudget`                   |

The app uses the package from this checkout (a local package reference to `../..`), so it
always shows the current code. It is a SwiftUI `App` with a `WindowGroup` scene and reacts to
`scenePhase`: the outbox is flushed when the scene becomes active.

Run it:

1. Open `Examples/SystemDesignLab/SystemDesignLab.xcodeproj` in Xcode 26 or later.
2. Choose the **SystemDesignLab** scheme and an iPhone simulator or **My Mac** as the run
   destination.
3. Press **Run** (⌘R).

From the command line:

```sh
cd Examples/SystemDesignLab
xcodebuild build -scheme SystemDesignLab -destination 'generic/platform=iOS Simulator'
xcodebuild build -scheme SystemDesignLab -destination 'platform=macOS'
```

Launching with `-lab feed`, `-lab outbox`, `-lab sync` or `-lab estimator` opens that lab
directly; [`scripts/capture-screenshots.sh`](../scripts/capture-screenshots.sh) uses it to take
the README screenshots.

The README's code samples live in
[`ReadmeSamples.swift`](SystemDesignLab/SystemDesignLab/ReadmeSamples.swift). The package's
test target compiles and runs that file through the symlink
`Tests/MobileSystemDesignTests/ReadmeExamples.swift`, and
[`scripts/check-readme-samples.mjs`](../scripts/check-readme-samples.mjs) checks that the
README shows the same text.

The project file is made with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from
[`project.yml`](SystemDesignLab/project.yml) and committed, so you only need XcodeGen after
editing `project.yml`.

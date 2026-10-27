# Case study: a chat app

"Design the client of a WhatsApp-style messenger": one-to-one and small group conversations,
delivered in real time, usable offline.

## 1. Requirements

**Functional**

- Send and receive text messages in one-to-one and group chats.
- Show delivery state: sending, sent, delivered, read.
- Show the conversation list with the last message and unread counts.
- Notify the user of new messages when the app is not open.

**Non-functional**

- Messages appear within about a second when both users are online.
- A message written offline is sent when the network returns, exactly once, in order.
- The history is available offline.
- Privacy: messages are end-to-end encrypted (the design of the protocol itself is out of
  scope).

**Out of scope:** media messages, calls, message search on the server.

## 2. Estimates

A user who sends 40 and receives 80 messages a day, at about 200 bytes per message, moves
about 24 kB of message payload a day; a year of history is under 10 MB. Storage and bandwidth
are small, so the design is driven by latency, ordering and battery, not by volume.

## 3. High-level design

```text
ChatScreen ── ChatViewModel ── MessageRepository ─┬─ MessageStore (database)
                                                  ├─ Outbox ── SendAPI
                                                  └─ SyncClient ─┬─ WebSocket (foreground)
                                                                 └─ pull since token
Push notification ── NotificationService ── SyncClient (catch up)
```

The screen reads only from `MessageStore`. Sending writes to the store and the outbox;
receiving writes to the store from the socket or from a pull.

## 4. API and data

```text
WebSocket (foreground)
  → { "type": "send", "client_id": "<uuid>", "chat": "c_1", "body": "…" }
  ← { "type": "ack", "client_id": "<uuid>", "id": "m_1001", "seq": 1001 }
  ← { "type": "message", "chat": "c_1", "id": "m_1002", "seq": 1002, "from": "u_7", … }
  ← { "type": "receipt", "chat": "c_1", "up_to_seq": 1002, "state": "read", "by": "u_7" }

HTTP
  GET /v1/sync?since=<token>   → messages, receipts, chat changes, next token
```

Each message has a client id (UUID, created on the sender's device) and, once the server
accepts it, a server id and a **sequence number per chat**. The client id makes sending
idempotent; the sequence number gives every device the same order.

Local tables: `chats` (id, title, last_seq, unread_count), `messages` (chat, client_id,
server_id, seq, sender, body, state, created_at) with an index on `(chat, seq)`.

## 5. Deep dives

### Sending

1. Insert the message locally with state `sending` and a client id, so it shows at once.
2. Enqueue it in an [outbox](../topics/offline-and-sync.md#the-outbox) with the client id as
   idempotency key.
3. Send over the socket when connected, else over HTTP when the network returns.
4. On `ack`, store the server id and sequence and set `sent`. A retried send that the server
   already accepted returns the same `ack`, so no duplicate appears.

Messages from one device to one chat are sent one at a time, oldest first, so they keep their
order.

### Receiving and ordering

Apply incoming messages by sequence number. If `seq` jumps (1002, then 1005), pull the missing
range before showing later messages; ignore a message whose server id is already stored. While
the user's own unsent messages wait, show them after the last received message, then move them
to their server position on `ack`.

### Connection lifecycle

Open the socket when a scene becomes active, send heartbeats, reconnect with backoff and
jitter, and close it in the background. On every (re)connect, pull changes since the last sync
token before relying on the socket. See
[Network resilience and real-time updates](../topics/resilience-and-real-time.md).

### Background delivery

When the app is not running, the server sends a push notification. With end-to-end
encryption, the push carries an encrypted payload that a notification service extension
([`UNNotificationServiceExtension`](https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension))
decrypts to show the text; on Android, a high-priority FCM data message wakes the app. Either
way, the app pulls the full history when it next opens: pushes can be dropped or coalesced.

### Receipts

Batch receipts ("read up to seq 1002") instead of sending one per message, and debounce them
while the user scrolls.

## 6. Trade-offs and metrics

- One socket per app, multiplexing all chats, saves battery compared with one per chat.
- Per-chat sequence numbers are simple and enough for ordering; global ordering is not needed.
- Measure: send-to-ack latency, time from push to message visible, reconnects per hour,
  outbox length, messages pulled after reconnect.

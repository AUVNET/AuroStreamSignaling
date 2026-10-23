## Unreleased (2026-10-21)

* `ErrorModel.roomId` (optional): the room a `joinRoom` / `createRoom` error is about,
  read from the server's `error-message` payload (`roomId`, or `errorData.roomId`).
  Null with servers older than 2026-10-21. Existing `ErrorModel(...)` calls are unchanged.
* `errorRoomIdOf(data)` helper; `ErrorModel.fromJson` now converts `eventName` / `message`
  strings to the enums (it assigned the raw strings before).
* Server side (AuroStream Signaling, opt-in per project, default off): `rooms.autoCreateOnAuthorizedJoin`
  (+ optional `rooms.autoCreateRoomIdPattern`) creates a missing room on a join that the
  project's room-auth webhook allowed, instead of answering `roomNotFound`. The webhook is
  asked again with action `create` before the room is made, room ids longer than 128 characters
  are never auto-created, and the room-auth cache key now includes the action (a cached `join`
  allow never authorizes a `create`). Best effort: no unique index, a rare duplicate room
  document is harmless.

## 0.0.1

* TODO: Describe initial release.

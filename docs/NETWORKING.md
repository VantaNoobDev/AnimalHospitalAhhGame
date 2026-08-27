# Networking and security

Red modules in `src/network` define serialization contracts. Contracts reject malformed types and invalid enums early; server services repeat important state checks because contract validation alone is not authorization.

## Client requests

| Remote | Kind | Request | Server result |
| --- | --- | --- | --- |
| `ResolveCheckIn` | Function | patient ID, admit decision | correct decision boolean |
| `AssignRoom` | Event | patient ID, room enum | none |
| `ApplyTreatment` | Function | patient ID, treatment enum | success boolean |
| `PurchaseClass` | Function | class ID | purchase boolean |
| `GetPatientSnapshot` | Function | none | safe visible patients for late join |
| `GetShiftState` | Function | none | current shift number, time, and status |

Requests are accepted only when their identifiers are bounded, their enum values are known, the player is present, the relevant shift/state allows the action, and the player's token bucket has capacity. Purchases additionally use a per-player lock and verify persisted coins before deduction.

## Server events

| Remote | Audience | Purpose |
| --- | --- | --- |
| `PatientSpawned` | All players | Safe visible patient description |
| `PatientResolved` | All players | Remove patient from client state |
| `SanityChanged` | One player | Batched authoritative sanity value |
| `ShiftStarted` | All or joining player | Begin local presentation timer |
| `ShiftEnded` | All players | End local shift presentation |
| `StartDialogue` | One player | Display validated dialogue payload |

Coins, class ownership, class experience, and statistics are not duplicated as Red events. `DataServiceTyped` persists and replicates those fields.

## Adding a remote

1. Define its Red contract in `src/network`.
2. Validate types, length, ranges, and enums there.
3. Rate-limit the server handler.
4. Validate current game state and permission in the server service.
5. Return minimal information; never send hidden anomaly state or full profiles.

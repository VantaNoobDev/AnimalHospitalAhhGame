# Architecture

## Runtime flow

1. `Server.server.luau` requires services and calls each `Init` method once.
2. `Data.luau` loads and reconciles player profiles through `DataServiceTyped`.
3. `ShiftService` enables patient interactions and sanity drain for an active shift.
4. `PatientService` creates pooled patient records and publishes safe display data.
5. Clients request check-in, room, treatment, or class actions through Red contracts.
6. Server services validate rate, state, identifier, enum, and economy requirements.
7. Successful actions update persistent coins/statistics; `DataServiceTyped` replicates them.
8. Troves release event connections, delayed work, and other lifecycle resources.

## Ownership

| Component | Owns | Does not trust |
| --- | --- | --- |
| `ShiftService` | Active shift and spawn schedule | Client time |
| `PatientService` | Patient state, decisions, rewards | Patient IDs, rooms, treatments |
| `SanityService` | Per-player sanity and drain state | Client sanity |
| `ClassService` | Costs, ownership, levels, perks | Purchase requests |
| `DataServiceTyped` | Profile session, saving, replication | Client-local data writes |
| Client services | Presentation state and request APIs | Their own mirrors as authority |

## Lifecycle

Services expose `Init` when they connect events and `Destroy` when they own cleanup. Player-specific cleanup is handled from the server composition root. `SanityService` no longer subscribes to `PlayerAdded` independently, preventing the old double initialization.

## Performance choices

- Patient species are cached in an array once instead of rebuilt per spawn.
- Patient records are reused through a warmed object pool.
- Sanity changes are calculated each Heartbeat but replicated on a configured interval and epsilon.
- Shift spawn debt is carried forward with `+= interval`, which avoids drift after a slow frame.
- Client getters copy internal tables so UI code cannot mutate service state accidentally.

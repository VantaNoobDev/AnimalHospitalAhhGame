# Configuration

All gameplay tuning lives in `src/config/GameConfig.luau`.

## Shift

Controls shift duration, spawn intervals, interval scaling, anomaly chance, and immediate first spawn.

## Sanity

Controls maximum sanity, warning thresholds, drain rate, difficulty scaling, and replication batching. Drain only runs while a shift marks the player active.

## Economy

| Setting | Meaning |
| --- | --- |
| `StartingCoins` | New-profile balance |
| `CorrectCheckInReward` | Reward for one correct patient decision |
| `SuccessfulTreatmentReward` | Reward for one successful treatment |

Class prices remain beside class definitions in `ClassService` because the definition and price form one catalog entry.

## Security

`RemoteBurst` and `RemoteRefillPerSecond` configure the shared token-bucket policy used by gameplay remotes. `MaximumIdentifierLength` rejects oversized identifiers at the network boundary and service boundary.

## Data

`ProfileStoreIndex` and `ProfileKeyPrefix` identify the production store. Changing either creates a different logical profile namespace. `UseMockInStudio` should normally stay enabled during development.

## Patients and anomalies

Patient progression requirements, pooling-independent behavior, trait counts, red-herring probability, and anomaly scaling are configurable. Successful treatment clears the patient by default so completed patients cannot remain active indefinitely.

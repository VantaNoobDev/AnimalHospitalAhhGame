# Development guide

## Commands

```bash
rokit install
wally install
npm install
npm run build:rojo
npm test
```

`build:rojo` regenerates `default.project.json` from `src`. Run it after adding, moving, or removing Luau files.

## Player data

Edit the template in `src/data/Data.luau`. Keep values DataStore-safe. Increment `schemaVersion` and migrate raw profile data in `Data.Service:onPlayerInit` when a deployed shape changes. Server gameplay reads and writes `Data[player]`; client UI uses `Data.client` only as a replicated mirror.

## Adding a service

Keep server authority in `Server.luau`, client-facing state in `Client.luau`, and shared definitions in `Utils.luau` or a clearly named shared module. Put connections inside `Init`, cleanup inside `Destroy`, and wire both at the appropriate startup composition root.

## Section comments

Use short `--// Name` headings such as `--// Dependencies`, `--// State`, or `--// Public API`. Add one only when it separates a meaningful group; small files do not need every possible heading.

## Release checklist

- Run `npm test`.
- Test with two Studio clients.
- Verify DataStore mock mode is appropriate for the environment.
- Exercise spammed remote requests and duplicate purchases.
- Join during an active shift and confirm state synchronization.
- Leave during delayed dialogue and confirm there are no errors.

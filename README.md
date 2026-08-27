# Animal Hospital AHH

A server-authoritative Roblox/Luau game foundation for running animal-hospital shifts, identifying anomalies, treating patients, managing sanity, and unlocking persistent classes.

## Setup

Install the toolchain and packages, then start Rojo:

```bash
rokit install
wally install
npm install
npm run build:rojo
rojo serve
```

Connect with the Rojo Studio plugin. Data uses mock storage in Studio by default, so local testing does not touch production profiles.

## Quality check

```bash
npm test
```

This runs Selene and builds a place file with Rojo. Enable Luau's new type solver for `DataServiceTyped` autocomplete and type checking.

## Project map

| Path | Purpose |
| --- | --- |
| `src/config` | Balance, data, economy, and security settings |
| `src/data` | Typed persistent player-data schema |
| `src/modules` | Reusable general-purpose utilities |
| `src/network` | Red remote contracts and boundary validation |
| `src/services` | Server gameplay authority and client-facing APIs |
| `src/startup` | Server/client composition roots |
| `src/ui` | Dialogue components, controller, view, and formatting |

## Core rules

- The server owns patient, shift, sanity, economy, and class decisions.
- Remote arguments are untrusted and validated again in the receiving service.
- Player data is changed through `DataServiceTyped`; do not build a second save cache.
- Every long-lived connection, thread, or disposable object belongs to a Trove.
- Repeatedly allocated runtime records should use `ObjectPool` when profiling shows value.
- Balance changes belong in `GameConfig`.

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Configuration](docs/CONFIGURATION.md)
- [Networking and security](docs/NETWORKING.md)
- [Utilities](docs/UTILITIES.md)
- [Development guide](docs/DEVELOPMENT.md)

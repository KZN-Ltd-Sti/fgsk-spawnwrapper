# FGSK Spawn Wrapper

Resource that wraps the stock FiveM `spawnmanager` to provide custom spawn logic (last position persistence + default spawn points) without rewriting the core spawn pipeline.

## Features
- Disables `spawnmanager` auto-spawn and triggers spawning only after the intro resource signals readiness.
- Delegates model streaming/visibility to the official `spawnmanager:spawnPlayer`, so we inherit the stock, battle-tested spawn flow.
- Persists player coordinates in `player_spawns` via oxmysql, so reconnects return to the last position (with fallback default spawns).
- Exposes simple events (`fgsk-spawnwrapper:begin`, `fgsk-spawnwrapper:spawnPlayer`, `fgsk-spawnwrapper:spawned`) for other resources to hook into (e.g., loading screens or inventory resets).

## Requirements
- `spawnmanager` (system resource) must stay enabled.
- `oxmysql` configured with the `player_spawns` / `spawn_points` schema.
- Intro/loading resource that calls `TriggerEvent('fgsk-spawnwrapper:begin')` once the player is ready (e.g., `fgsk-loading`).

## Usage
1. `ensure fgsk-spawnwrapper` in `fxproject.json` (FXDK) or `server.cfg`.
2. Populate `Config.SpawnPoints` / DB entries with your desired spawns; the server script will prefer last-position records when available.
3. Optional: listen to `fgsk-spawnwrapper:spawned` to reset inventories, outfits, etc.

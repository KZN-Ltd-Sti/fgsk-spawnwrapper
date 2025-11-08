# FGSK Spawn Plan

## Goal
Use the stock FiveM `spawnmanager` resource for ped creation and respawns, while providing custom logic for selecting spawn points, persisting last positions, and integrating with FGSK intro/loading flows.

## Approach
1. **Resource scaffold** – minimal `fxmanifest.lua`, config, client/server scripts.
2. **Spawn flow** – disable auto-spawn, hook into intro completion, and call `exports.spawnmanager:spawnPlayer` or set auto-spawn callbacks.
3. **Data** – reuse existing DB schema (`player_spawns`, `spawn_points`) via oxmysql; share logic as needed.
4. **Selector UI** – reintroduce NUI panel later; start with auto last-position + fallback spawn.
5. **Respawn handling** – leverage native `spawnmanager:forceRespawn`/callbacks, enforcing hospital cooldown via server events.
6. **Docs/tests** – README and TODO to keep track of integration steps.

## Dependencies
- `spawnmanager` (Cfx system resource)
- `oxmysql` for persistence
- `intro` resource to signal when loading is complete

## Open Questions
- Do we keep the previous NUI from `spawn-manager` or build a new, simpler selector?
- Should respawn penalties remain in DB from previous iteration?

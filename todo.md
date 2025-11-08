# FGSK Spawn TODO

- [x] Scaffold resource (`fxmanifest.lua`, `config.lua`, `client/main.lua`, `server/main.lua`) that depends on `spawnmanager` + `oxmysql`.
- [x] Disable default auto-spawn and request spawn flow after intro/ready events.
- [x] Fetch/persist last position via `player_spawns` and use `spawnmanager:spawnPlayer`.
- [ ] Implement hospital respawn pipeline using native `spawnmanager` callbacks instead of manual teleports.
- [ ] Reintroduce (or redesign) spawn selector UI once core flow is stable.

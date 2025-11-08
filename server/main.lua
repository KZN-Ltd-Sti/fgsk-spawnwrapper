local function debugPrint(...)
    if not Config.Debug then
        return
    end

    local msg = table.concat({ ... }, ' ')
    print(('[fgsk-spawnwrapper] %s'):format(msg))
end

local function getIdentifier(src)
    if not src then
        return nil
    end

    local identifiers = GetPlayerIdentifiers(src)
    for _, identifier in ipairs(identifiers) do
        if identifier:sub(1, 8) == 'license:' then
            return identifier
        end
    end

    return identifiers[1]
end

local function getSpawnById(id)
    for _, point in ipairs(Config.SpawnPoints) do
        if point.id == id then
            return point
        end
    end

    return nil
end

local function getDefaultSpawn()
    for _, point in ipairs(Config.SpawnPoints) do
        if point.isDefault then
            return point
        end
    end

    return Config.SpawnPoints[1]
end

local function fetchPlayerSpawn(identifier)
    if not identifier then
        return nil
    end

    local success, row = pcall(function()
        return MySQL.single.await([[
            SELECT last_pos_x, last_pos_y, last_pos_z, last_pos_heading, preferred_spawn
            FROM player_spawns
            WHERE identifier = ?
        ]], { identifier })
    end)

    if not success then
        debugPrint(('Failed to fetch spawn for %s: %s'):format(identifier, row))
        return nil
    end

    if not row then
        return nil
    end

    if not row.last_pos_x or not row.last_pos_y or not row.last_pos_z then
        return nil
    end

    return {
        coords = {
            x = row.last_pos_x,
            y = row.last_pos_y,
            z = row.last_pos_z,
            heading = row.last_pos_heading or 0.0
        },
        preferredSpawn = row.preferred_spawn
    }
end

local function persistPlayerSpawn(identifier, coords, preferred)
    if not identifier or not coords then
        return
    end

    local x = tonumber(coords.x)
    local y = tonumber(coords.y)
    local z = tonumber(coords.z)
    local h = tonumber(coords.heading) or 0.0

    if not x or not y or not z then
        return
    end

    local ok, err = pcall(function()
        MySQL.prepare.await([[
            INSERT INTO player_spawns
                (identifier, last_pos_x, last_pos_y, last_pos_z, last_pos_heading, preferred_spawn, is_new_player)
            VALUES (?, ?, ?, ?, ?, ?, 0)
            ON DUPLICATE KEY UPDATE
                last_pos_x = VALUES(last_pos_x),
                last_pos_y = VALUES(last_pos_y),
                last_pos_z = VALUES(last_pos_z),
                last_pos_heading = VALUES(last_pos_heading),
                preferred_spawn = COALESCE(VALUES(preferred_spawn), preferred_spawn),
                is_new_player = VALUES(is_new_player)
        ]], {
            identifier,
            x,
            y,
            z,
            h,
            preferred
        })
    end)

    if not ok then
        debugPrint(('Failed to persist spawn for %s: %s'):format(identifier, err))
    end
end

local function buildSpawnPayload(spawnPoint, sourceType)
    local coords = spawnPoint.coords

    return {
        name = spawnPoint.name,
        coords = coords,
        heading = coords.heading or 0.0,
        preferredSpawnId = spawnPoint.id,
        sourceType = sourceType or 'fallback'
    }
end

RegisterNetEvent('fgsk-spawnwrapper:requestSpawn', function()
    local src = source
    local identifier = getIdentifier(src)

    debugPrint(('Player %s requested spawn'):format(src))

    if not identifier then
        local defaultSpawn = getDefaultSpawn()
        TriggerClientEvent('fgsk-spawnwrapper:spawnPlayer', src, buildSpawnPayload(defaultSpawn, 'default_no_id'))
        return
    end

    local record = fetchPlayerSpawn(identifier)
    if record and record.coords then
        TriggerClientEvent('fgsk-spawnwrapper:spawnPlayer', src, {
            name = 'Last Position',
            coords = record.coords,
            heading = record.coords.heading or 0.0,
            preferredSpawnId = record.preferredSpawn,
            sourceType = 'last_position'
        })
        return
    end

    local defaultSpawn = getDefaultSpawn()
    TriggerClientEvent('fgsk-spawnwrapper:spawnPlayer', src, buildSpawnPayload(defaultSpawn, 'default'))
end)

RegisterNetEvent('fgsk-spawnwrapper:spawned', function(payload)
    local src = source
    local identifier = getIdentifier(src)
    if not identifier or not payload then
        return
    end

    if payload.coords then
        persistPlayerSpawn(identifier, payload.coords, payload.preferredSpawnId)
    else
        local coords = GetEntityCoords(GetPlayerPed(src))
        persistPlayerSpawn(identifier, {
            x = coords.x,
            y = coords.y,
            z = coords.z,
            heading = GetEntityHeading(GetPlayerPed(src))
        }, payload.preferredSpawnId)
    end
end)

local spawnRequested = false

local function debugPrint(...)
    if not Config.Debug then
        return
    end

    local msg = table.concat({ ... }, ' ')
    print(('[fgsk-spawnwrapper] %s'):format(msg))
end

local function disableAutoSpawn()
    local ok, err = pcall(function()
        exports.spawnmanager:setAutoSpawn(false)
        exports.spawnmanager:setAutoSpawnCallback(function()
            debugPrint('Spawnmanager auto callback hit; requesting spawn flow')
            TriggerEvent('fgsk-spawnwrapper:begin')
        end)
    end)

    if not ok then
        debugPrint(('Failed to configure spawnmanager exports: %s'):format(err))
    end
end

local function requestSpawnData()
    if spawnRequested then
        return
    end

    spawnRequested = true
    TriggerServerEvent('fgsk-spawnwrapper:requestSpawn')
end

local function spawnAtCoords(payload)
    if not payload or not payload.coords then
        debugPrint('Spawn payload missing coords')
        return
    end

    local coords = payload.coords
    local model = Config.DefaultModel or 'mp_m_freemode_01'

    debugPrint(('Spawning at %s via %s'):format(payload.name or 'Unknown', payload.sourceType or 'unknown'))

    exports.spawnmanager:spawnPlayer({
        x = coords.x,
        y = coords.y,
        z = coords.z,
        heading = coords.heading or payload.heading or 0.0,
        model = model,
        skipFade = false
    }, function()
        spawnRequested = false
        TriggerServerEvent('fgsk-spawnwrapper:spawned', {
            coords = coords,
            preferredSpawnId = payload.preferredSpawnId,
            sourceType = payload.sourceType
        })
    end)
end

RegisterNetEvent('fgsk-spawnwrapper:spawnPlayer', spawnAtCoords)

RegisterNetEvent('fgsk-spawnwrapper:begin', requestSpawnData)

exports('BeginSpawnFlow', function()
    TriggerEvent('fgsk-spawnwrapper:begin')
end)

AddEventHandler('onClientResourceStart', function(resName)
    if resName == GetCurrentResourceName() then
        disableAutoSpawn()
    end

    if resName == 'spawnmanager' then
        disableAutoSpawn()
    end
end)

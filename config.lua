Config = {}

Config.DefaultModel = 'mp_m_freemode_01'

Config.SpawnPoints = {
    {
        id = 1,
        name = 'Legion Square',
        coords = { x = 215.76, y = -810.12, z = 30.73, heading = 160.0 },
        isDefault = true,
        isHospital = false
    },
    {
        id = 2,
        name = 'Pillbox Hospital',
        coords = { x = 298.54, y = -584.95, z = 43.26, heading = 70.0 },
        isDefault = false,
        isHospital = true
    }
}

Config.FallbackSpawnId = 1
Config.HospitalSpawnIds = { 2 }

Config.Debug = true

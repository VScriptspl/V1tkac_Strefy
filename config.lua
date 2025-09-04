Config = {}

Config.Zones = {
    {
        name = "Strefa Centrum",
        coords = vector3(234.5, -789.2, 30.5),
        radius = 50.0,
        reward = {
            money = 5000,
            items = {
                {name = "weapon_pistol", amount = 1},
                {name = "ammo", amount = 50}
            }
        }
    },
    {
        name = "Strefa Lotnisko",
        coords = vector3(-1020.4370, -2965.0339, 13.9458),
        radius = 75.0,
        reward = {
            money = 7500,
            items = {
                {name = "armor", amount = 1}
            }
        }
    },
    {
        name = "Strefa grapeside",
        coords = vector3(2129.9509, 4789.2339, 40.9694),
        radius = 50.0,
        reward = {
            money = 5000,
            items = {
                {name = "weapon_pistol", amount = 1},
                {name = "ammo", amount = 50}
            }
        }
    },
    {
        name = "Strefa domki",
        coords = vector3(2349.8445, 2562.8713, 46.6678),
        radius = 75.0,
        reward = {
            money = 7500,
            items = {
                {name = "armor", amount = 1}
            }
        }
    },
    {
        name = "Strefa sendi",
        coords = vector3(1285.9158, 3104.8069, 40.9072),
        radius = 50.0,
        reward = {
            money = 5000,
            items = {
                {name = "weapon_pistol", amount = 1},
                {name = "ammo", amount = 50}
            }
        }
    },
    {
        name = "Strefa doki",
        coords = vector3(-512.5698, -2828.2654, 101.0000),
        radius = 75.0,
        reward = {
            money = 7500,
            items = {
                {name = "armor", amount = 1}
            }
        }
    }
}

Config.CaptureTime = 300 -- sekundy
Config.MinPlayers = 1
Config.NotificationDuration = 5000 -- milisekundy
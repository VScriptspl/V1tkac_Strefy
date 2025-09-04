local zones = {}

-- Initialize zones from config
Citizen.CreateThread(function()
    for _, zoneConfig in pairs(Config.Zones) do
        CreateZone(zoneConfig)
    end
end)

function CreateZone(zoneData)
    local zone = {
        name = zoneData.name,
        center = zoneData.coords,
        radius = zoneData.radius,
        active = true,
        capturing = false,
        captureProgress = 0,
        players = {},
        lastCapture = 0 -- Initialize lastCapture
    }
    
    zones[#zones + 1] = zone
    return zone
end

function IsPlayerInZone(player, zone)
    local ped = GetPlayerPed(player)
    local playerCoords = GetEntityCoords(ped)
    local distance = #(playerCoords - zone.center)
    
    return distance <= zone.radius
end

function UpdateZoneStatus(zone, players)
    if (os.time() - zone.lastCapture) < 900 then
        local timeLeft = math.ceil(900 - (os.time() - zone.lastCapture))
        TriggerClientEvent('V1tkac-strefy:notification', -1, {
            message = "Strefa " .. zone.name .. " będzie dostępna za " .. timeLeft .. " sekund",
            type = "error"
        })
        return
    end

    if #players >= Config.MinPlayers then
        zone.captureProgress = zone.captureProgress + (1 / Config.CaptureTime)
        
        TriggerClientEvent('V1tkac-strefy:updateProgress', -1, {
            zoneName = zone.name,
            progress = zone.captureProgress,
            isActive = true
        })
        
        if zone.captureProgress >= 1.0 then
            GiveZoneRewards(players, zone)
            ResetZone(zone)
            zone.lastCapture = os.time()
        end
    else
        -- Reset progress when no players in zone
        if zone.captureProgress > 0 then
            zone.captureProgress = 0
            TriggerClientEvent('V1tkac-strefy:updateProgress', -1, {
                zoneName = zone.name,
                progress = 0,
                isActive = false
            })
        end
    end
end

function GiveZoneRewards(players, zone)
    -- Find zone config by matching zone name
    local zoneConfig = nil
    for _, cfg in pairs(Config.Zones) do
        if cfg.name == zone.name then
            zoneConfig = cfg
            break
        end
    end

    if not zoneConfig then return end

    for _, playerId in ipairs(players) do
        local xPlayer = exports.es_extended:getSharedObject().GetPlayerFromId(playerId)
        
        if xPlayer then
            -- Add money reward
            if zoneConfig.reward.money then
                xPlayer.addMoney(zoneConfig.reward.money)
            end
            
            -- Add item rewards
            if zoneConfig.reward.items then
                for _, item in ipairs(zoneConfig.reward.items) do
                    xPlayer.addInventoryItem(item.name, item.amount)
                end
            end
            
            -- Send notification
            TriggerClientEvent('V1tkac-strefy:notification', playerId, {
                message = "Otrzymałeś nagrody za przejęcie strefy " .. zone.name,
                type = "success"
            })
        end
    end
end

function ResetZone(zone)
    zone.captureProgress = 0
    zone.capturing = false
end

-- Main update loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Update every second
        for _, zone in pairs(zones) do
            if zone.active then
                local playersInZone = {}
                for _, player in ipairs(GetPlayers()) do
                    if IsPlayerInZone(player, zone) then
                        table.insert(playersInZone, player)
                    end
                end
                UpdateZoneStatus(zone, playersInZone)
            end
        end
    end
end)
local capturing = false
local captureProgress = 0
local zoneName = ""

local zoneBlips = {}
local blips = {}
local isProgressVisible = false
local currentZone = nil
local isInZone = false

-- Add debug print for NUI messages
local function debugPrint(message)
    print('^3[DEBUG]^7 ' .. message)
end

-- UI Drawing
function DrawUI()
    if capturing then
        DrawRect(0.5, 0.95, 0.15, 0.02, 0, 0, 0, 150)
        DrawRect(0.5 - 0.075 + (captureProgress * 0.075), 0.95, 0.15 * captureProgress, 0.02, 255, 0, 0, 200)
        SetTextScale(0.3, 0.3)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        AddTextComponentString(zoneName .. " - Przejmowanie: " .. math.floor(captureProgress * 100) .. "%")
        DrawText(0.425, 0.94)
    end
end

-- Notification System
function ShowNotification(text, type)
    local colors = {
        success = {r = 50, g = 255, b = 50},
        error = {r = 255, g = 50, b = 50},
        info = {r = 50, g = 50, b = 255}
    }
    
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text)
    ThefeedNextPostBackgroundColor(colors[type].r, colors[type].g, colors[type].b)
    EndTextCommandThefeedPostTicker(false, true)
end

-- Create blips for all zones
Citizen.CreateThread(function()
    for _, zoneData in pairs(Config.Zones) do
        local blip = AddBlipForCoord(zoneData.coords)
        SetBlipSprite(blip, 310) -- skull sprite
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zoneData.name)
        EndTextCommandSetBlipName(blip)

        blips[#blips + 1] = blip
    end
end)

-- Draw zone markers
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, zoneData in pairs(Config.Zones) do
            DrawMarker(1,
                zoneData.coords.x, zoneData.coords.y, zoneData.coords.z - 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                zoneData.radius * 2.0, zoneData.radius * 2.0, 2.0,
                255, 0, 0, 50,
                false, false, 2,
                false, nil, nil, false
            )
        end
    end
end)

-- Test NUI when resource starts
--Citizen.CreateThread(function()
--    Wait(1000) -- Wait for NUI to load
--    debugPrint("Testing NUI system...")
--    
--    -- Test message
--    SendNUIMessage({
--        type = "showProgress",
--        progress = 0,
--        title = "Test UI",
--        description = "Initialization"
--    })
--    
--    Wait(2000)
--    
--    SendNUIMessage({
--        type = "hideProgress"
--    })
--end)
--
-- Add this function to check if player is in any zone
local function CheckIfInZone()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for _, zoneData in pairs(Config.Zones) do
        local distance = #(playerCoords - zoneData.coords)
        if distance <= zoneData.radius then
            return true
        end
    end
    return false
end

-- Add zone checking thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local wasInZone = isInZone
        isInZone = CheckIfInZone()
        
        if wasInZone and not isInZone then
            -- Player left the zone
            SendNUIMessage({
                type = "showProgress",
                progress = 100, -- Start at 100% for countdown
                title = "Anulowane przejmowanie strefy",
                description = currentZone,
                progressType = "cancelled"
            })
            
            -- Hide after 2 seconds
            Citizen.SetTimeout(2000, function()
                SendNUIMessage({
                    type = "hideProgress"
                })
                isProgressVisible = false
                currentZone = nil
            end)
        end
    end
end)

RegisterNetEvent('V1tkac-strefy:updateProgress')
AddEventHandler('V1tkac-strefy:updateProgress', function(data)
    if data.isActive and data.progress > 0 and isInZone then
        currentZone = data.zoneName
        SendNUIMessage({
            type = "showProgress",
            progress = math.floor(data.progress * 100),
            title = "Przejmowanie strefy",
            description = data.zoneName,
            progressType = "capturing"
        })
        isProgressVisible = true
    end
end)

-- Add NUI Callback
---RegisterNUICallback('loaded', function(data, cb)
---    debugPrint("NUI Interface loaded")
---    cb('ok')
---end)

-- Event do powiadomień
RegisterNetEvent('V1tkac-strefy:notification')
AddEventHandler('V1tkac-strefy:notification', function(data)
    if isProgressVisible then
        SendNUIMessage({
            type = "hideProgress"
        })
        isProgressVisible = false
    end
end)

-- Dodaj czyszczenie blipów przy wyłączeniu resourcea
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if isProgressVisible then
        SendNUIMessage({
            type = "hideProgress"
        })
    end
    
    for _, blip in pairs(blips) do
        RemoveBlip(blip)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        DrawUI()
    end
end)

print("Config status:", Config ~= nil)
print("Config.Zones status:", Config and Config.Zones ~= nil)

if not Config then
    print("Config nie został załadowany!")
    return
end
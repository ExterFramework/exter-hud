hunger = hunger or 100 -- do not change default initialization
thirst = thirst or 100 -- do not change default initialization

Config = Config or {}

-- Supported: qbcore, esx, qbox, standalone, custom, auto
Config.Framework = Config.Framework or "auto"

Config.useElectricVehicles = true
Config.SpeedUnit = "MPH" -- MPH or KMH

Config.Guidemenu = {
    {
        Title = "Finding your Windows Communication Device",
        Description = "EXTERCITY 2.0"
    },
    {
        Title = "FPS Capping for UI lag:",
        Description = "EXTERCITY 2.0"
    },
}

-- Seatbelt eject behaviour defaults
Config.ejectVelocity = Config.ejectVelocity or 45.0
Config.unknownEjectVelocity = Config.unknownEjectVelocity or 70.0
Config.unknownModifier = Config.unknownModifier or 17.0
Config.minDamage = Config.minDamage or 2000.0

local fuelResources = {
    "cdn-fuel",
    "qb-fuel",
    "ps-fuel",
    "ox_fuel",
    "LegacyFuel",
    "legacyfuel",
}

local function getStartedFuelResource()
    for i = 1, #fuelResources do
        local res = fuelResources[i]
        if GetResourceState(res) == "started" then
            return res
        end
    end
    return nil
end

local function tryExport(resource, fn, ...)
    local ok, result = pcall(function()
        return exports[resource][fn](...)
    end)

    if ok then
        return true, result
    end

    return false, nil
end

function getFuel(veh)
    if not veh or veh == 0 then
        return 100.0
    end

    local activeFuel = getStartedFuelResource()
    if not activeFuel then
        return 100.0
    end

    if activeFuel == "cdn-fuel" then
        local ok, fuel = tryExport(activeFuel, "GetFuel", veh, false)
        return ok and fuel or 100.0
    end

    if activeFuel == "qb-fuel" then
        local ok, fuel = tryExport(activeFuel, "GetFuel", veh)
        if ok then
            return fuel
        end

        ok, fuel = tryExport(activeFuel, "getFuel", veh)
        return ok and fuel or 100.0
    end

    if activeFuel == "ps-fuel" then
        local ok, fuel = tryExport(activeFuel, "getFuel", veh)
        return ok and fuel or 100.0
    end

    if activeFuel == "ox_fuel" then
        local ok, fuel = tryExport(activeFuel, "getFuel", veh)
        return ok and fuel or 100.0
    end

    if activeFuel == "LegacyFuel" or activeFuel == "legacyfuel" then
        local ok, fuel = tryExport(activeFuel, "GetFuel", veh)
        return ok and fuel or 100.0
    end

    return 100.0
end

function setFuel(veh, level)
    if not veh or veh == 0 then
        return false
    end

    local activeFuel = getStartedFuelResource()
    if not activeFuel then
        return false
    end

    if activeFuel == "cdn-fuel" then
        return tryExport(activeFuel, "SetFuel", veh, level)
    end

    if activeFuel == "qb-fuel" then
        local ok = tryExport(activeFuel, "SetFuel", veh, level)
        if ok then
            return true
        end

        ok = tryExport(activeFuel, "setFuel", veh, level)
        return ok
    end

    if activeFuel == "ps-fuel" then
        return tryExport(activeFuel, "setFuel", veh, level)
    end

    if activeFuel == "ox_fuel" then
        return tryExport(activeFuel, "setFuel", veh, level)
    end

    if activeFuel == "LegacyFuel" or activeFuel == "legacyfuel" then
        return tryExport(activeFuel, "SetFuel", veh, level)
    end

    return false
end

function getElectro(veh)
    return getFuel(veh)
end

function SeatBeltActived()
    -- exports['your_notification']:SendAlert('inform', 'Seatbelt enabled')
end

function SeatBeltDesactivated()
    -- exports['your_notification']:SendAlert('inform', 'Seatbelt disabled')
end

function SeatBeltError()
    -- exports['your_notification']:SendAlert('error', "You can't enable seatbelt on this vehicle")
end

function getNitrousLevel()
    return 0
end

function getHarnessLevel()
    return 0
end

Config.electricVehicles = {
    [GetHashKey('voltic')] = true,
    [GetHashKey('surge')] = true,
    [GetHashKey('dilettante')] = true,
    [GetHashKey('raiden')] = true,
    [GetHashKey('cyclone')] = true,
    [GetHashKey('neon')] = true,
    [GetHashKey('tezeract')] = true,
}

PoliceCars = {
    'police',
}

if not IsDuplicityVersion() then
    RegisterCommand('fuelxd', function()
        local newFuelLevel = 8.0
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

        if DoesEntityExist(vehicle) and vehicle ~= 0 then
            if not setFuel(vehicle, newFuelLevel) then
                print('[exter-hud] No compatible fuel system found for setting fuel level.')
            end
        else
            print('[exter-hud] You are not inside a vehicle.')
        end
    end, false)

    RegisterCommand('enginexd', function()
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

        if DoesEntityExist(vehicle) and vehicle ~= 0 then
            SetVehicleEngineHealth(vehicle, 0.0)
            print("[exter-hud] The vehicle engine was damaged.")
        else
            print('[exter-hud] You are not inside a vehicle.')
        end
    end, false)
end

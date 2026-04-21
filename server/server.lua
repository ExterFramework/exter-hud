local CodeID = {
    author = 'sobing',
    codeName = 'exter-hud | HUD System LiKE 4.0',
    version = '1.1'
}

CreateThread(function()
    print(('%s - [%s] v%s successfully started!'):format(CodeID.author, CodeID.codeName, CodeID.version))
end)

local function detectFramework()
    local configured = (Config and Config.Framework or 'auto'):lower()

    if configured ~= 'auto' then
        return configured
    end

    if GetResourceState('qbx_core') == 'started' then
        return 'qbox'
    end

    if GetResourceState('qb-core') == 'started' then
        return 'qbcore'
    end

    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    end

    return 'standalone'
end

local framework = detectFramework()

local function registerQBCoreCommands()
    if GetResourceState('qb-core') ~= 'started' then
        return false
    end

    local ok, qb = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)

    if not ok or not qb or not qb.Commands then
        return false
    end

    qb.Commands.Add('cash', 'Check Cash Balance', {}, false, function(source)
        local player = qb.Functions.GetPlayer(source)
        if not player then
            return
        end

        local cashamount = player.PlayerData.money.cash or 0
        TriggerClientEvent('QBCore:Notify', source, ('You have: %s in cash'):format(cashamount), 'info')
    end)

    qb.Commands.Add('bank', 'Check Bank Balance', {}, false, function(source)
        local player = qb.Functions.GetPlayer(source)
        if not player then
            return
        end

        local bankamount = player.PlayerData.money.bank or 0
        TriggerClientEvent('QBCore:Notify', source, ('You have: %s in bank'):format(bankamount), 'info')
    end)

    return true
end

local function registerESXCommands()
    if GetResourceState('es_extended') ~= 'started' then
        return false
    end

    local ok, esx = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if not ok or not esx or not esx.RegisterCommand then
        return false
    end

    esx.RegisterCommand('cash', 'user', function(xPlayer)
        local cash = xPlayer.getMoney and xPlayer.getMoney() or 0
        xPlayer.showNotification(('You have: %s in cash'):format(cash))
    end, false)

    esx.RegisterCommand('bank', 'user', function(xPlayer)
        local bank = xPlayer.getAccount and (xPlayer.getAccount('bank') or {}).money or 0
        xPlayer.showNotification(('You have: %s in bank'):format(bank))
    end, false)

    return true
end

local function registerFallbackCommands()
    RegisterCommand('cash', function(source)
        TriggerClientEvent('chat:addMessage', source, { args = { '^3HUD', 'Cash command is only available when a framework economy is active.' } })
    end, false)

    RegisterCommand('bank', function(source)
        TriggerClientEvent('chat:addMessage', source, { args = { '^3HUD', 'Bank command is only available when a framework economy is active.' } })
    end, false)
end

local registered = false
if framework == 'qbcore' or framework == 'qbox' then
    registered = registerQBCoreCommands()
elseif framework == 'esx' then
    registered = registerESXCommands()
end

if not registered then
    registerFallbackCommands()
end

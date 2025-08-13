local framework = Config.Framework

-- Universal notification function
local function Notify(msg, type)
    type = type or 'primary'
    if Config.Notification == 'qb' and framework == 'qb' then
        QBCore.Functions.Notify(msg, type) -- QBCore notification
    elseif Config.Notification == 'esx' and framework == 'esx' then
        ESX.ShowNotification(msg) -- ESX notification
    elseif Config.Notification == 'ox' then
        lib.notify({title = 'Dance Session', description = msg, type = type}) -- ox_lib notification
    end
end

-- Dance input menu
RegisterNetEvent('dance_session:openMenu', function()
    local input = lib.inputDialog('Enter Dance Name', {
        {type = 'input', label = 'Dance Name', placeholder = 'example: dance1'}
    })
    if input and input[1] and input[1] ~= '' then
        TriggerServerEvent('dance_session:setDance', input[1]) -- send dance name to server
    else
        Notify('Dance name cannot be empty.', 'error') -- error notification
    end
end)

-- Start dance
RegisterNetEvent('dance_session:startDance', function(danceName)
    ExecuteCommand('e ' .. danceName) -- runs the emote command
end)

-- Stop dance
RegisterNetEvent('dance_session:stopDance', function()
    ExecuteCommand('e c') -- stops any active emote
end)

-- ox_lib notify handler (server triggers)
RegisterNetEvent('dance_session:oxNotify', function(msg, type)
    lib.notify({title = 'Dance Session', description = msg, type = type}) -- show ox_lib notification
end)

local framework = Config.Framework
local danceSessions = {}  -- Stores all active dance sessions
local sessionCounter = 0  -- Counter for session IDs

-- Framework objects
local QBCore, ESX
if framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif framework == "esx" then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

-- Helper function: notify player
local function Notify(src, msg, type)
    type = type or "primary"
    if Config.Notification == "qb" and QBCore then
        TriggerClientEvent('QBCore:Notify', src, msg, type)
    elseif Config.Notification == "esx" and ESX then
        TriggerClientEvent('esx:showNotification', src, msg)
    elseif Config.Notification == "ox" then
        TriggerClientEvent('dance_session:oxNotify', src, msg, type)
    end
end

-- Helper: get the session ID of a player
local function GetPlayerSession(playerId)
    for id, data in pairs(danceSessions) do
        for _, memberId in ipairs(data.members) do
            if memberId == playerId then return id end
        end
    end
    return nil
end

-- Helper: remove a player from a session
local function RemovePlayerFromSession(playerId, sessionId)
    local members = danceSessions[sessionId].members
    for i, id in ipairs(members) do
        if id == playerId then
            table.remove(members, i)
            break
        end
    end
end

-- Create a new session
RegisterCommand('createsession', function(source)
    sessionCounter = sessionCounter + 1
    danceSessions[sessionCounter] = {
        host = source,
        members = {source},
        currentDance = nil
    }
    Notify(source, 'Session #' .. sessionCounter .. ' created successfully. Use /opendance to choose a dance.', 'success')
end)

-- Open dance menu (host only)
RegisterCommand('opendance', function(source)
    local sessionId = GetPlayerSession(source)
    if not sessionId then
        Notify(source, 'You are not in any session.', 'error')
        return
    end
    if danceSessions[sessionId].host ~= source then
        Notify(source, 'Only the host can open the dance menu.', 'error')
        return
    end
    TriggerClientEvent('dance_session:openMenu', source)
end)

-- Set the current dance
RegisterNetEvent('dance_session:setDance', function(danceName)
    local src = source
    local sessionId = GetPlayerSession(src)
    if not sessionId then return end
    danceSessions[sessionId].currentDance = danceName
    for _, playerId in ipairs(danceSessions[sessionId].members) do
        TriggerClientEvent('dance_session:startDance', playerId, danceName)
    end
    Notify(src, 'Dance changed to: ' .. danceName, 'success')
end)

-- Join a session
RegisterCommand('joindance', function(source, args)
    local sessionId = tonumber(args[1])
    if not sessionId or not danceSessions[sessionId] then
        Notify(source, 'Session not found.', 'error')
        return
    end
    table.insert(danceSessions[sessionId].members, source)
    Notify(source, 'Joined session #' .. sessionId, 'success')
    if danceSessions[sessionId].currentDance then
        TriggerClientEvent('dance_session:startDance', source, danceSessions[sessionId].currentDance)
    end
end)

-- Leave a session
RegisterCommand('leavedance', function(source)
    local sessionId = GetPlayerSession(source)
    if not sessionId then
        Notify(source, 'You are not in a session.', 'error')
        return
    end
    RemovePlayerFromSession(source, sessionId)
    TriggerClientEvent('dance_session:stopDance', source)
    Notify(source, 'You left session #' .. sessionId, 'primary')
end)

-- Stop the dance (host only)
RegisterCommand('stopdance', function(source)
    local sessionId = GetPlayerSession(source)
    if not sessionId then return end
    if danceSessions[sessionId].host ~= source then
        Notify(source, 'Only the host can stop the dance.', 'error')
        return
    end
    for _, playerId in ipairs(danceSessions[sessionId].members) do
        TriggerClientEvent('dance_session:stopDance', playerId)
    end
end)

-- End the session (host only)
RegisterCommand('endsession', function(source)
    local sessionId = GetPlayerSession(source)
    if not sessionId then return end
    if danceSessions[sessionId].host ~= source then
        Notify(source, 'Only the host can end the session.', 'error')
        return
    end
    for _, playerId in ipairs(danceSessions[sessionId].members) do
        TriggerClientEvent('dance_session:stopDance', playerId)
        Notify(playerId, 'Session #' .. sessionId .. ' has ended.', 'error')
    end
    danceSessions[sessionId] = nil
end)

-- Auto-kick or handle host disconnect
AddEventHandler('playerDropped', function()
    local src = source
    local sessionId = GetPlayerSession(src)
    if not sessionId then return end
    if danceSessions[sessionId].host == src then
        for _, playerId in ipairs(danceSessions[sessionId].members) do
            if playerId ~= src then
                TriggerClientEvent('dance_session:stopDance', playerId)
                Notify(playerId, 'Host left, session ended.', 'error')
            end
        end
        danceSessions[sessionId] = nil
    else
        RemovePlayerFromSession(src, sessionId)
    end
end)

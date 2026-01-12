local VORPcore = exports.vorp_core:GetCore()
local isNuiOpen = false
local pigeonInFlight = false
local lastSenderId = nil  -- Store the last sender's ID for replies

-- Register the letter item as usable (opens the send UI)
-- Note: This is triggered from server-side item registration

-- Event called from server when letter item is used
RegisterNetEvent('carrier_pigeon:openUI', function()
    if pigeonInFlight then
        VORPcore.NotifyRightTip(Config.Notifications.pigeonBusy, 4000)
        return
    end
    
    OpenMessageUI()
end)

function OpenMessageUI()
    isNuiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        maxLength = Config.MaxMessageLength
    })
end

function CloseMessageUI()
    isNuiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

-- NUI Callbacks
RegisterNUICallback('sendMessage', function(data, cb)
    local targetId = tonumber(data.targetId)
    local message = data.message
    
    if not targetId or targetId < 1 then
        VORPcore.NotifyRightTip(Config.Notifications.invalidPlayer, 4000)
        cb('ok')
        return
    end
    
    if not message or message == '' then
        cb('ok')
        return
    end
    
    if string.len(message) > Config.MaxMessageLength then
        VORPcore.NotifyRightTip(Config.Notifications.messageTooLong, 4000)
        cb('ok')
        return
    end
    
    CloseMessageUI()
    
    -- Send to server for validation and delivery
    TriggerServerEvent('carrier_pigeon:sendMessage', targetId, message)
    
    cb('ok')
end)

RegisterNUICallback('closeUI', function(data, cb)
    CloseMessageUI()
    cb('ok')
end)

-- Handle ESC key to close
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isNuiOpen then
            if IsControlJustPressed(0, 0x156F7119) then -- BACKSPACE
                CloseMessageUI()
            end
        else
            Citizen.Wait(500)
        end
    end
end)

-- Event: Pigeon has been sent (update local state)
RegisterNetEvent('carrier_pigeon:pigeonSent', function()
    pigeonInFlight = true
    VORPcore.NotifyRightTip(Config.Notifications.messageSent, 4000)
    
    -- Play a little animation or sound here if desired
    -- Could add pigeon flying away particle/sound
end)

-- Event: Pigeon has returned
RegisterNetEvent('carrier_pigeon:pigeonReturned', function()
    pigeonInFlight = false
    VORPcore.NotifyRightTip(Config.Notifications.pigeonReturned, 4000)
    
    -- Play return sound/notification
end)

-- Event: Message delivery failed (player offline)
RegisterNetEvent('carrier_pigeon:deliveryFailed', function()
    pigeonInFlight = false
    VORPcore.NotifyRightTip(Config.Notifications.playerNotFound, 4000)
end)

-- Event: Receive a message
RegisterNetEvent('carrier_pigeon:receiveMessage', function(senderName, message, senderId)
    -- Store sender ID for potential reply
    lastSenderId = senderId
    
    -- Notification that message arrived
    VORPcore.NotifyRightTip(Config.Notifications.messageReceived, 4000)
    
    -- Small delay then show the message
    Citizen.Wait(1000)
    
    -- Open read UI with the message
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showMessage',
        senderName = senderName,
        message = message,
        canReply = (senderId ~= nil)  -- Can only reply if we have sender ID
    })
    isNuiOpen = true
end)

RegisterNUICallback('closeMessage', function(data, cb)
    CloseMessageUI()
    lastSenderId = nil
    cb('ok')
end)

-- Reply to a message
RegisterNUICallback('replyMessage', function(data, cb)
    CloseMessageUI()
    
    if not lastSenderId then
        cb('ok')
        return
    end
    
    if pigeonInFlight then
        VORPcore.NotifyRightTip(Config.Notifications.pigeonBusy, 4000)
        lastSenderId = nil
        cb('ok')
        return
    end
    
    -- Check items before opening UI
    TriggerServerEvent('carrier_pigeon:checkItemsForReply', lastSenderId)
    cb('ok')
end)

-- Server confirmed we have items, open reply UI
RegisterNetEvent('carrier_pigeon:openReplyUI', function(targetId)
    isNuiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openReply',
        maxLength = Config.MaxMessageLength,
        targetId = targetId
    })
    lastSenderId = nil
end)

-- Event: No items
RegisterNetEvent('carrier_pigeon:noLetter', function()
    VORPcore.NotifyRightTip(Config.Notifications.noLetter, 4000)
end)

RegisterNetEvent('carrier_pigeon:noPigeon', function()
    VORPcore.NotifyRightTip(Config.Notifications.noPigeon, 4000)
end)
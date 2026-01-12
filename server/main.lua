local VORPcore = exports.vorp_core:GetCore()
local VORPInv = exports.vorp_inventory:vorp_inventoryApi()

-- Track players with pigeons in flight (prevents spam)
local pigeonsInFlight = {}

-- Register the letter item as usable
exports.vorp_inventory:registerUsableItem(Config.LetterItem, function(data)
    local src = data.source
    local character = VORPcore.getUser(src).getUsedCharacter
    
    -- Check if player has a pigeon
    local pigeonCount = VORPInv.getItemCount(src, Config.PigeonItem)
    
    if pigeonCount < 1 then
        TriggerClientEvent('carrier_pigeon:noPigeon', src)
        return
    end
    
    -- Check if pigeon is already in flight
    if pigeonsInFlight[src] then
        TriggerClientEvent('carrier_pigeon:deliveryFailed', src)
        return
    end
    
    -- Open the UI
    TriggerClientEvent('carrier_pigeon:openUI', src)
end)

-- Handle message sending
RegisterNetEvent('carrier_pigeon:sendMessage', function(targetId, message)
    local src = source
    local senderChar = VORPcore.getUser(src).getUsedCharacter
    local senderName = senderChar.firstname .. ' ' .. senderChar.lastname
    
    -- Validate message length
    if string.len(message) > Config.MaxMessageLength then
        return
    end
    
    -- Check items again (in case of exploits)
    local letterCount = VORPInv.getItemCount(src, Config.LetterItem)
    local pigeonCount = VORPInv.getItemCount(src, Config.PigeonItem)
    
    if letterCount < 1 then
        TriggerClientEvent('carrier_pigeon:noLetter', src)
        return
    end
    
    if pigeonCount < 1 then
        TriggerClientEvent('carrier_pigeon:noPigeon', src)
        return
    end
    
    -- Check if pigeon is in flight
    if pigeonsInFlight[src] then
        return
    end
    
    -- Check if target player is online
    local targetPlayer = VORPcore.getUser(targetId)
    if not targetPlayer then
        TriggerClientEvent('carrier_pigeon:deliveryFailed', src)
        return
    end
    
    -- All checks passed - remove items and send
    VORPInv.subItem(src, Config.LetterItem, 1)    -- Letter is consumed
    VORPInv.subItem(src, Config.PigeonItem, 1)    -- Pigeon temporarily removed
    
    -- Mark pigeon as in flight
    pigeonsInFlight[src] = true
    
    -- Notify sender
    TriggerClientEvent('carrier_pigeon:pigeonSent', src)
    
    -- Schedule delivery after SendTime
    Citizen.SetTimeout(Config.SendTime, function()
        -- Check if target is still online
        local target = VORPcore.getUser(targetId)
        if target then
            -- Deliver the message
            TriggerClientEvent('carrier_pigeon:receiveMessage', targetId, senderName, message)
        end
        -- Note: Even if target logged off during flight, letter is still consumed
        -- This is a design choice - you could refund the letter here if preferred
        
        -- Schedule pigeon return after ReturnTime
        Citizen.SetTimeout(Config.ReturnTime, function()
            -- Check if sender is still online
            local sender = VORPcore.getUser(src)
            if sender then
                -- Return the pigeon
                VORPInv.addItem(src, Config.PigeonItem, 1)
                TriggerClientEvent('carrier_pigeon:pigeonReturned', src)
            end
            -- Clear the in-flight status
            pigeonsInFlight[src] = nil
        end)
    end)
end)

-- Clean up on player disconnect
AddEventHandler('playerDropped', function(reason)
    local src = source
    pigeonsInFlight[src] = nil
end)

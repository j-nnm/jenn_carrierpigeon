Config = {}

-- Items
Config.LetterItem = 'letter'           -- Item name for letters (consumed on send)
Config.PigeonItem = 'carrier_pigeon'   -- Item name for pigeons (temporarily removed, returns after delivery)

-- Timing (in milliseconds)
Config.SendTime = 30000                -- Time for pigeon to deliver message (30 seconds)
Config.ReturnTime = 30000              -- Time for pigeon to return after delivery (30 seconds)

-- Message Settings
Config.MaxMessageLength = 140          -- Maximum characters per message

-- Notifications
Config.Notifications = {
    noLetter = "You don't have any letters to write on.",
    noPigeon = "You don't have a carrier pigeon to send.",
    pigeonBusy = "Your pigeon is already delivering a message.",
    playerNotFound = "Your pigeon couldn't find that person. They may not be around.",
    messageSent = "Your pigeon takes flight with your message...",
    pigeonReturned = "Your carrier pigeon has returned.",
    messageReceived = "A carrier pigeon arrives with a message for you.",
    messageTooLong = "Your message is too long. Keep it under " .. 140 .. " characters.",
    invalidPlayer = "Invalid player ID.",
}

-- UI Settings
Config.OpenKey = 0x760A9C6F            -- Key to close NUI (BACKSPACE) - opening is handled by item use

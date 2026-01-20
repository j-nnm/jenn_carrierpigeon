# [WIP] Carrier Pigeon Messaging

A period-appropriate messaging system for RedM using VORP framework. Send short messages to other players via carrier pigeon!

## Features

- **Time-appropriate communication** - No phones or radios, just pigeons!
- **Dual consumable system** - Requires both letters (consumed) and pigeons (reusable)
- **Realistic timing** - 30 seconds to deliver, 30 seconds for pigeon to return
- **Offline protection** - If recipient is offline, pigeon returns and items aren't consumed
- **Anti-spam** - Can't send another message while your pigeon is in flight
- **Clean NUI** - Period-styled paper/letter UI

## Usage

1. Player uses a `letter` item from their inventory
2. If they have a `carrier_pigeon`, the send UI opens
3. Enter the recipient's player ID and write a short message (140 chars max)
4. Click "Send Pigeon" - the pigeon flies off
5. After 30 seconds, recipient receives the message
6. After another 30 seconds, the pigeon returns to the sender's inventory

## Configuration

Edit `config.lua` to customize:

```lua
Config.LetterItem = 'letter'           -- Item name for letters
Config.PigeonItem = 'carrier_pigeon'   -- Item name for pigeons
Config.SendTime = 30000                -- Delivery time (ms)
Config.ReturnTime = 30000              -- Return time (ms)
Config.MaxMessageLength = 140          -- Character limit
```

## Dependencies

- vorp_core
- vorp_inventory

## Notes

- The letter is consumed on send (even if recipient logs off during delivery)
- The pigeon is temporarily removed and returns after delivery + return time
- If the recipient is offline when you try to send, the pigeon returns immediately and no items are consumed
- Players can only have one pigeon in flight at a time

-- Add these items to your vorp items table
-- Adjust the table name if yours is different

INSERT INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`) VALUES
('letter', 'Letter', 10, 1, 'item_standard', 1, 'A blank piece of paper for writing messages.'),
('carrier_pigeon', 'Carrier Pigeon', 3, 1, 'item_standard', 0, 'A trained carrier pigeon that can deliver messages to other people.');

-- Note: 
-- 'letter' is usable (triggers the send UI)
-- 'carrier_pigeon' is NOT usable directly - it's used automatically when sending a letter
-- Adjust the 'limit' values as needed for your server's economy

-- BN KOTH persistence schema version 4.
-- Adds logical vehicle-family ownership, included-first-spawn use, and mastery.

ALTER TABLE `bn_koth_player_progression`
    ADD COLUMN `vehicle_progression` MEDIUMTEXT NULL AFTER `saved_kits`;

UPDATE `bn_koth_player_progression`
SET `vehicle_progression` = '-'
WHERE `vehicle_progression` IS NULL;

ALTER TABLE `bn_koth_player_progression`
    MODIFY COLUMN `vehicle_progression` MEDIUMTEXT NOT NULL;

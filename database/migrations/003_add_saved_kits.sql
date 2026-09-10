-- BN KOTH persistence schema version 3.
-- Adds bounded saved loadout intent. Entitlement remains server-validated on use.

ALTER TABLE `bn_koth_player_progression`
    ADD COLUMN `saved_kits` MEDIUMTEXT NULL AFTER `active_perks`;

UPDATE `bn_koth_player_progression`
SET `saved_kits` = '-'
WHERE `saved_kits` IS NULL;

ALTER TABLE `bn_koth_player_progression`
    MODIFY COLUMN `saved_kits` MEDIUMTEXT NOT NULL;

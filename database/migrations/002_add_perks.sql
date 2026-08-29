-- BN KOTH persistence schema version 2.
-- Adds stable persistent perk ownership and active-slot selections.

ALTER TABLE `bn_koth_player_progression`
    ADD COLUMN `owned_perks` TEXT NULL AFTER `weapon_kills`,
    ADD COLUMN `active_perks` TEXT NULL AFTER `owned_perks`;

UPDATE `bn_koth_player_progression`
SET `owned_perks` = '-', `active_perks` = '-'
WHERE `owned_perks` IS NULL OR `active_perks` IS NULL;

ALTER TABLE `bn_koth_player_progression`
    MODIFY COLUMN `owned_perks` TEXT NOT NULL,
    MODIFY COLUMN `active_perks` TEXT NOT NULL;

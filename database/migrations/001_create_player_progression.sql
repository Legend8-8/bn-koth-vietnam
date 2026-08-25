-- BN KOTH persistence schema version 1.
-- Apply once to the MariaDB/MySQL database configured for extDB3.

CREATE TABLE IF NOT EXISTS `bn_koth_player_progression` (
    `uid` VARCHAR(20) NOT NULL,
    `schema_version` INT UNSIGNED NOT NULL,
    `xp` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `cash` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `owned_weapons` TEXT NOT NULL,
    `weapon_kills` TEXT NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

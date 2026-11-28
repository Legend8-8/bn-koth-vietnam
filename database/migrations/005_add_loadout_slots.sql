-- Slot ownership is per Steam UID, shared by every playable team.
ALTER TABLE bn_koth_player_progression
    ADD COLUMN unlocked_loadout_slots INT UNSIGNED NOT NULL DEFAULT 1;

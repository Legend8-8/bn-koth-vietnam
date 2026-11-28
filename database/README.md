# BN KOTH persistence database

The database schema is owned by the numbered files in `database/migrations/`.
Apply them in ascending order. Mission persistence schema version `5` uses
`001_create_player_progression.sql` through `005_add_loadout_slots.sql` with the
table `bn_koth_player_progression`.

`uid` is the Steam UID primary key. `schema_version`, `xp`, `cash`,
`owned_weapons`, `weapon_kills`, `owned_perks`, `active_perks`, logical vehicle
progression, and `unlocked_loadout_slots` are durable. Slot ownership is one
count per Steam UID, shared across teams; old players start with one free slot.
The legacy `saved_kits` column remains in the V5 SQL
contract but is written as `-`; kits and team preferred kit IDs live in client
`profileNamespace`. `created_at` and `updated_at`
are database audit timestamps. Level is derived from XP; rentals and round
statistics are not stored.

The durable collection text columns use restricted deterministic codecs documented in
`docs/deployment-extdb3.md`; they are not SQF source and must never be compiled.
Unknown future schema versions are rejected by the mission without updating
the row.

Production schema-v5 deployment is: apply all migrations through `005_add_loadout_slots.sql`, copy
`extdb3/bn_koth.ini.example` to `@extDB3/sql_custom/bn_koth.ini`, restart the
server, then verify reconnect and full server-restart persistence. Credentials
remain only in the private extDB3 connection configuration.

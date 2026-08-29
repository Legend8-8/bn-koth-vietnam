# BN KOTH persistence database

The database schema is owned by the numbered files in `database/migrations/`.
Apply them in ascending order. Mission persistence schema version `2` uses
`001_create_player_progression.sql` followed by `002_add_perks.sql` and the
table `bn_koth_player_progression`.

`uid` is the Steam UID primary key. `schema_version`, `xp`, `cash`,
`owned_weapons`, `weapon_kills`, `owned_perks`, and `active_perks` are durable. `created_at` and `updated_at`
are database audit timestamps. Level is derived from XP; rentals and round
statistics are not stored.

The durable collection text columns use restricted deterministic codecs documented in
`docs/deployment-extdb3.md`; they are not SQF source and must never be compiled.
Unknown future schema versions are rejected by the mission without updating
the row.

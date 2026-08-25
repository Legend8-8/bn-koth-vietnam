# BN KOTH persistence database

The database schema is owned by the numbered files in `database/migrations/`.
Apply them in ascending order. Mission persistence schema version `1` uses
`001_create_player_progression.sql` and the table
`bn_koth_player_progression`.

`uid` is the Steam UID primary key. `schema_version`, `xp`, `cash`,
`owned_weapons`, and `weapon_kills` are durable. `created_at` and `updated_at`
are database audit timestamps. Level is derived from XP; rentals and round
statistics are not stored.

The two text columns use the restricted deterministic codec documented in
`docs/deployment-extdb3.md`; they are not SQF source and must never be compiled.
Unknown future schema versions are rejected by the mission without updating
the row.

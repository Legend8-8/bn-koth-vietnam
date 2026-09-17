# extDB3 persistence deployment

## Boundary

extDB3 is a dedicated-server-only adapter behind `functions/persistence/`.
Gameplay, clients, progression, teams, and UI do not issue SQL or call the
extension. The mission config contains only the extDB3 connection-section name,
protocol identifier, SQL_CUSTOM filename, and timeout threshold. Credentials
remain in the server-local `extdb3-conf.ini`.

## Files and configuration

1. Install an extDB3 release appropriate to the server OS/architecture and add
   it to the Arma server's `-serverMod` list.
2. Install any runtime/redistributable required by that extDB3 release.
3. Create a MariaDB/MySQL database and a least-privilege user with `SELECT`,
   `INSERT`, and `UPDATE` on `bn_koth_player_progression`.
4. Apply every numbered file in `database/migrations/` in ascending order.
5. Merge `database/extdb3/extdb3-conf.ini.example` into the server-local
   `@extDB3/extdb3-conf.ini`, replacing all placeholders. The section name must
   match `CfgBnKothPersistence.extdbDatabase` (`BN_KOTH` by default).
6. Copy `database/extdb3/bn_koth.ini.example` to
   `@extDB3/sql_custom/bn_koth.ini`. Its name must match
   `CfgBnKothPersistence.extdbSqlCustomFile`.
7. Ensure the Arma/TCAdmin service account can read the extension, its config,
   and `sql_custom` file, and can load the native library.
8. Restart the server. Do not use a live reload for migration or protocol
   changes.

The mission performs `9:VERSION`, `9:ADD_DATABASE`, then
`9:ADD_DATABASE_PROTOCOL` for the `SQL_CUSTOM` protocol. Because extDB3 keeps
database and protocol registrations alive for the server-process lifetime, a
same-process mission reload returns `[0,"Already Connected to Database"]` for
the database and `[0,"Error Protocol Name Already Taken"]` for the protocol.
The extDB3 log spells the former message with an additional `a`, but that is not
the `callExtension` return value. The adapter accepts only those exact
source-defined duplicate responses; `Failed to Load Protocol`, unknown-protocol,
other rejection, and malformed responses fail immediately. A reuse candidate
must still complete the existing read-only `healthCheck` query against
`bn_koth_player_progression` and return the exact BN KOTH schema-v4 protocol
marker before publishing readiness. The query references `vehicle_progression`,
so readiness also fails closed when migration 004 has not been applied.
This probe is also required after cold registration, so a registered but stale,
wrong, or unusable SQL_CUSTOM path fails closed. It does not log credentials or
raw query parameters.

A successful RPT marker includes `backend=EXTDB3`, `ready=true`,
`code=EXTDB_READY`, and `lifecycle=COLD_INIT` or
`lifecycle=MISSION_RELOAD_REUSE`. The preceding bounded registration messages
identify database and protocol state as `COLD_REGISTERED` or `REUSED_EXISTING`.

## Serialization

`owned_weapons` is `-` for an empty array, otherwise sorted unique lowercase
classnames joined with commas. `weapon_kills` is `-` for an empty map,
otherwise entries sorted by classname and encoded as
`classname=non_negative_integer`, joined with commas. Tokens permit only ASCII
lowercase letters, digits, and underscore. Parsing rejects duplicates,
unexpected delimiters, invalid characters, negative/non-integral counts, and
empty tokens. The legacy `saved_kits` field remains in the V4 statement and is
written as `-`. Saved loadouts and their preferred ID live in client
`profileNamespace`; their content passes server validation on load and spawn.

`vehicle_progression` is a bounded fixed-width decimal-byte encoding of a
data-only array containing logical owned family IDs, first-spawn-used family
IDs, and sorted family/counter rows. This survives SQL_CUSTOM's restricted
input character policy, never contains physical objects or runtime net IDs,
and is decoded with `parseSimpleArray`, never `compile`.

## Failure policy

Missing extension, connection/protocol failure, malformed/error response,
duplicate rows, invalid UID, invalid authoritative progression fields, and query duration beyond
the configured threshold are explicit failures. Legacy `saved_kits` text is
ignored on load so it cannot block XP/cash/ownership/perk/vehicle progression.
The existing configured session fallback may let the player continue with a server-owned default state,
but it does not claim durability. A session created from any failed/malformed or
future-schema load is write-blocked for the rest of that mission session, so its
defaults cannot overwrite the durable row. Failed saves remain dirty. Future
schema rows are rejected and are not automatically overwritten.

`callExtension` is synchronous and cannot be interrupted by SQF. The configured
threshold therefore detects and rejects an over-time response after control
returns; database/driver connection timeouts must also be configured on the
server. Progression saves remain event-driven and debounced. Local saved-kit
changes do not schedule database writes.

## TCAdmin-oriented verification checklist

1. Install the extension in the path used by the Arma server and add the
   correct `-serverMod` argument.
2. Install required redistributables/native dependencies.
3. Create the database and least-privilege user.
4. Run all numbered migrations in ascending order.
5. Configure the `BN_KOTH` extDB3 connection section.
6. Place `bn_koth.ini` under extDB3's `sql_custom` directory.
7. Confirm the TCAdmin/Arma service account can read and load those files.
8. Restart and verify `EXTDB_READY` in the server RPT and extDB3's own log.
9. Join with a first-time Steam UID and verify one row is created.
10. Earn XP/cash/mastery, acquire a weapon and a vehicle family, then disconnect
    and verify the progression save-success RPT marker. Save a named loadout locally.
11. Reconnect and confirm progression restores from the database while the saved
    loadout remains in the same client profile and remains entitlement-validated.
12. Reload the mission without stopping `arma3server_x64.exe`; confirm
    `MISSION_RELOAD_REUSE`, `EXTDB_READY`, durable values, subsequent saves, and
    statistics/leaderboard queries all remain available without session fallback.
13. Repeat the same-process mission reload at least once more.
14. Restart the entire server and confirm `COLD_INIT` and the durable values
    restore again.

For schema-v4 deployment from schema v2 or earlier, apply
`003_add_saved_kits.sql` and then `004_add_vehicle_progression.sql`. From schema
v3, apply only migration 004. Copy the updated SQL_CUSTOM file, restart the
server, then verify vehicle ownership, first-spawn use and mastery through
reconnect, mission reload and a full process restart. Saved-kit data needs no
database migration or restoration; use the same client profile. No
repository-side statement or serializer work remains for the operator to author.

The operator must supply privately: server OS/architecture, extDB3 build and
install path, exact `-serverMod` configuration, MariaDB/MySQL host/port/database,
least-privilege username/password, whether outbound/local DB access is allowed,
and the TCAdmin service-account identity/permissions. None belongs in Git.

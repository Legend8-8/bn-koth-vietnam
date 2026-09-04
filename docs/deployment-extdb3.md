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
4. Apply `database/migrations/001_create_player_progression.sql`.
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
`9:ADD_DATABASE_PROTOCOL` for the `SQL_CUSTOM` protocol. It does not log
credentials or raw query parameters. A successful RPT marker includes
`backend=EXTDB3`, `ready=true`, and `code=EXTDB_READY`.

## Serialization

`owned_weapons` is `-` for an empty array, otherwise sorted unique lowercase
classnames joined with commas. `weapon_kills` is `-` for an empty map,
otherwise entries sorted by classname and encoded as
`classname=non_negative_integer`, joined with commas. Tokens permit only ASCII
lowercase letters, digits, and underscore. Parsing rejects duplicates,
unexpected delimiters, invalid characters, negative/non-integral counts, and
empty tokens. Database text is parsed as data only; it is never passed to
`compile`.

## Failure policy

Missing extension, connection/protocol failure, malformed/error response,
duplicate rows, invalid UID, invalid serialized data, and query duration beyond
the configured threshold are explicit failures. The existing configured
session fallback may let the player continue with a server-owned default state,
but it does not claim durability. A session created from any failed/malformed or
future-schema load is write-blocked for the rest of that mission session, so its
defaults cannot overwrite the durable row. Failed saves remain dirty. Future
schema rows are rejected and are not automatically overwritten.

`callExtension` is synchronous and cannot be interrupted by SQF. The configured
threshold therefore detects and rejects an over-time response after control
returns; database/driver connection timeouts must also be configured on the
server. Saves remain event-driven and debounced.

## TCAdmin-oriented verification checklist

1. Install the extension in the path used by the Arma server and add the
   correct `-serverMod` argument.
2. Install required redistributables/native dependencies.
3. Create the database and least-privilege user.
4. Run the numbered migration.
5. Configure the `BN_KOTH` extDB3 connection section.
6. Place `bn_koth.ini` under extDB3's `sql_custom` directory.
7. Confirm the TCAdmin/Arma service account can read and load those files.
8. Restart and verify `EXTDB_READY` in the server RPT and extDB3's own log.
9. Join with a first-time Steam UID and verify one row is created.
10. Earn XP/cash/mastery or acquire a weapon, then disconnect and verify the
    save-success RPT marker.
11. Reconnect and confirm the values restore.
12. Restart the entire server and confirm the values restore again.

The operator must supply privately: server OS/architecture, extDB3 build and
install path, exact `-serverMod` configuration, MariaDB/MySQL host/port/database,
least-privilege username/password, whether outbound/local DB access is allowed,
and the TCAdmin service-account identity/permissions. None belongs in Git.

Bro-Nation KOTH Vietnam — Multiplayer Locality

1. Purpose

Arma multiplayer code may run on:

- the dedicated server;
- every client;
- one specific client;
- a headless client;
- the machine local to a particular object.

Every function must have a deliberate execution location.

2. Core Principle

The server calculates gameplay truth.

Clients display information and send requests.

Combat-attribution collection registers only on the server. Projectile facts
and bounded victim hit records remain server-local and are not broadcast;
optional diagnostics only control RPT verbosity. `EntityKilled` owns lethality,
`combat_handleKill` owns valid PvP, and progression mastery consumes only the
attached unique `ATTRIBUTED` canonical infantry root. Clients have no mastery
mutation or weapon-attribution request endpoint.

A client must not be trusted to determine:

- zone ownership;
- team score;
- kills or rewards;
- experience;
- currency;
- purchases;
- unlocks;
- round winners.

3. System Ownership

System or action| Execution owner
Mission framework initialisation| Server and clients separately
Round state| Server
Round start and end| Server
Active location selection| Server
Eligible zone-player detection| Server
Zone population calculation| Server
Zone ownership calculation| Server
Team score| Server
Win-condition calculation| Server
Team assignment validation| Server
Experience and level changes| Server
Player input and menus| Owning client
HUD drawing| Each client
Local sounds and visual effects| Each client
Purchase request creation| Owning client
Purchase validation| Server
Experience and currency changes| Server
Database access| Server
Gameplay vehicle creation| Server
Local player loadout interface| Owning client
Loadout entitlement validation| Server
Traversal input, geometry probing and movement| Owning client
Named kit profile storage and management| Owning client; stored data remains untrusted intent
Arsenal physical-loadout reconciliation| Server reads the owned player object
Arsenal preview framework| Owning client; currently disabled
Safe-zone physical inventory blocking| Owning client
Safe-zone ground-loot and corpse cleanup| Server
Respawn presentation| Owning client
Respawn rules and validation| Server
Player safe-zone membership| Server
Player firing and damage enforcement| Owning client
Vehicle safe-zone membership| Server
Vehicle damage and firing enforcement| Current vehicle owner
Opposing-safe-zone ejection| Owning client, on server instruction
Headless-client AI processing| Headless client when introduced

4. Initialisation Files

"initServer.sqf"

Used for server-only startup.

Examples:

- creating authoritative mission state;
- starting the round manager;
- starting zone monitoring;
- initialising team score;
- selecting the active location.

"initPlayerLocal.sqf"

Runs once for each player on their own machine.

Examples:

- initialising the HUD;
- installing local event handlers;
- creating client menus;
- displaying notifications.

This file must account for join-in-progress players.

"initPlayerServer.sqf"

Runs on the server when a player joins.

Examples:

- validating the player;
- assigning initial server-side player state;
- sending the current round state to the joining player;
- loading and normalizing persistent data through the server-only persistence service.

"init.sqf"

Must not become a dumping ground.

It should contain only shared startup that genuinely needs to execute on every machine, or direct execution into clearly owned initialisation functions.

4.1 Representation handoff lifecycle

The transfer function bn_koth_fnc_teams_transferRepresentation is a server-owned handoff primitive.

Use it when a player must be moved to a newly created or newly selected representation unit, such as:

- lobby representation assignment;
- gameplay deployment assignment;
- any server-authoritative role/unit transition.

Do not call this handoff function from client startup files.

The startup file initPlayerLocal.sqf runs once on each client and initializes local systems for that client. It is not the place to authoritatively choose or transfer representation ownership.

Server-side usage pattern:

[_uid, _targetUnit, _targetState, _deletePrevious] call bn_koth_fnc_teams_transferRepresentation;

Parameter meaning:

- _uid: player UID string;
- _targetUnit: server-selected representation unit object;
- _targetState: logical player state string (for example LOBBY or DEPLOYING);
- _deletePrevious: whether to delete the previous non-player representation after successful handoff.

On success, the lifecycle is:

1. Server validates record and owner.
2. Server asks owning client to selectPlayer through bn_koth_fnc_ui_selectControlledUnit.
3. Server waits until target-unit locality ownership matches the player owner.
4. Server updates authoritative player record state.
5. Server triggers post-handoff local reinitialization on the owning client (map icons, 3D icons, ESC menu), plus server-side curator setup.

This split keeps authority server-side while still ensuring client-local systems are reinstalled after ownership changes.

5. State Distribution

The server stores authoritative state.

Clients receive only the information needed for presentation.

Examples of client-visible state:

- current round state;
- current team scores;
- current zone status;
- remaining preparation time;
- winning team.

Where practical, state should be published only when it changes rather than continuously broadcasting identical values.

6. Join in Progress

A joining player must receive the current state of the active round.

The player must not assume the round is beginning from its initial state.

At minimum, a joining player needs:

- current round state;
- active location;
- active zone details;
- active WEST and EAST safe-zone markers;
- current zone owner;
- raw, weighted and Priority-zone population;
- current team scores;
- winning score;
- remaining relevant timer information.

7. Client Requests

Client-to-server requests must contain the minimum required information.

Example:

[_loadoutId] remoteExecCall [
    "bn_koth_fnc_loadouts_request",
    2
];

The server must independently validate:

- the requesting player;
- the player’s side;
- the player’s position;
- the requested identifier;
- any level requirement;
- any cost;
- request frequency;
- current round state.

The client must not supply its own UID, balance, level or entitlement when the server can obtain those values itself.

8. Remote Execution Rules

Remote execution must use an allowlist.

Only intentional public network endpoints may be remotely executed.

Naming should distinguish requests from internal functions.

Examples:

bn_koth_fnc_loadouts_request
bn_koth_fnc_vehicles_requestSpawn
bn_koth_fnc_ui_receiveState

Internal calculation functions must not be remotely executable unless there is a specific documented reason.

9. Object Locality

Before executing a command on a unit or vehicle, confirm where that object is local.

Vehicle creation should normally be performed by the server.

Commands that require local execution must be sent to the machine that owns the object.

Locality must not be guessed from where a function happened to be called.

Traversal runs only for the current local player representation. It publishes
no authoritative state, sends no remote request, and creates no JIP payload.
The engine continues to replicate the owning client's unit transform normally;
the mission-local traversal lock and diagnostics remain client-local.

Safe-zone membership is calculated on the server. Player `HandleDamage`, `FiredMan`, `GetInMan` and physical-inventory handlers are installed on each current local player representation, including after respawn or `selectPlayer`. The inventory-open handler uses the published active markers and the shared safe-zone geometry helper to block local UI access when either the actor or container crosses the boundary. Vehicle `allowDamage`, `HandleDamage` and `Fired` enforcement is reapplied whenever the vehicle owner changes. The server independently validates and deletes safe-zone loot holders and corpses. The only safe-zone remote endpoints are server-to-owner ejection and vehicle-protection application; both reject non-server remote callers.

10. Performance

Do not use "eachFrame" for zone control, scoring or database activity.

Suggested initial intervals:

- zone population calculation: once per second;
- safe-zone membership and locality reconciliation: four times per second;
- safe-zone inventory blocking: event-based, with a bounded check only while the physical inventory display is open;
- safe-zone ground cleanup: entity events plus one activation-time sweep, never a recurring world scan;
- score awarding: configurable, such as once every five seconds;
- HUD refresh: only when values change, or at a controlled client-side interval;
- persistence saving: mutation-driven dirty state with one coalesced delayed save,
  plus disconnect/mission-end flushes; never every frame or every score tick.

Clients have no persistence endpoint. They cannot load, save, or submit XP, cash,
ownership, or mastery values. Registration supplies only a server-observed Steam
UID to `functions/persistence/`; the existing targeted progression snapshot is the
sole client presentation path. extDB3 calls remain server-local behind the backend
adapter. No persistence function is remotely exposed and no database result is
accepted from a client.

All players do not need to calculate the same authoritative zone result independently.

11. Disconnects and Death

The server calculation must naturally remove players who:

- disconnect;
- die;
- become spectators;
- leave the zone;
- change to an ineligible state.

Cached player references must be checked before use.

12. Locality Review Questions

Before merging a multiplayer feature, answer:

1. Which machine runs this function?
2. Which machine owns the affected object?
3. Is the input trusted?
4. Can a client fake this request?
5. What happens for a join-in-progress player?
6. What happens if the player disconnects midway?
7. Is the same work unnecessarily running on every client?
8. Does the server remain authoritative?

13. Store Weapon Requests

The client sends only `PURCHASE`/`RENT` plus a canonical weapon classname. The
server resolves the player and UID from `remoteExecutedOwner`, invokes the
existing server-only acquisition API, targets the result to that owner, and
publishes changed cash/ownership/rental state through the existing player-only
progression update. Store requests never broadcast and never equip equipment.

14. Vehicle Rental Requests

Clients submit only RENT or owner access-mode intent. The server derives the
UID from `remoteExecutedOwner`, validates current side/level/perks, cash and
active-rental state, selects/reserves a cached authored paid pad, creates the
vehicle server-local, and only then deducts cash — all as one transaction with
no separate requisition step. The active rental map is server-only; only the
requesting client receives their projected state. Get-in authorization is
checked from server-owned UID/access data. A narrowly allowlisted
server-to-owner endpoint performs locality-sensitive ejection.
# Perk requests

Perk purchase and activation requests are client intent only. The server derives the player from `remoteExecutedOwner`, reads configured price and authoritative progression, commits atomically, marks persistence dirty, and publishes only to that owner. Suppressor cleanup is server-derived; the owning client only applies the server-signed Unit Loadout because `setUnitLoadout` must execute where the player unit is local.

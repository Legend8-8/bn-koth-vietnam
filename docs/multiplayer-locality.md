Bro-Nation KOTH Vietnam - Multiplayer Locality

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
Respawn presentation| Owning client
Respawn rules and validation| Server
Headless-client AI processing| Headless client when introduced

4. Initialisation Files

initServer.sqf

Used for server-only startup.

Examples:

- creating authoritative mission state;
- starting the round manager;
- starting zone monitoring;
- initialising team score;
- selecting the active location.

initPlayerLocal.sqf

Runs once for each player on their own machine.

Examples:

- initialising the HUD;
- installing local event handlers;
- creating client menus;
- displaying notifications.

This file must account for join-in-progress players.

initPlayerServer.sqf

Runs on the server when a player joins.

Examples:

- validating the player;
- assigning initial server-side player state;
- sending the current round state to the joining player;
- loading future persistent data.

init.sqf

Must not become a dumping ground.

It should contain only shared startup that genuinely needs to execute on every machine, or direct execution into clearly owned initialisation functions.

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
- current zone owner;
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

10. Performance

Do not use eachFrame for zone control, scoring or database activity.

Suggested initial intervals:

- zone population calculation: once per second;
- score awarding: configurable, such as once every five seconds;
- HUD refresh: only when values change, or at a controlled client-side interval;
- database saving: event-based and periodic, not every score tick.

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

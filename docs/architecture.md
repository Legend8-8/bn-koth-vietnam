Bro-Nation KOTH Vietnam — Architecture

1. Purpose

This document defines how the mission code is organised.

The project must remain predictable enough that a developer can identify the location of a feature without searching the entire repository.

2. Main Rules

1. The server owns authoritative game state.
2. Clients display state and request actions.
3. Clients do not award score, money, experience or equipment.
4. Each system has one clearly named folder.
5. Configuration is kept separate from runtime logic.
6. Shared behaviour is implemented once.
7. Functions should have one clear responsibility.
8. Large all-purpose scripts must be avoided.
9. Multiplayer locality must be stated in each public function header.
10. New systems must be documented before they become large.

AO population suitability is server-owned and distinct from vote eligibility.
The teams system resolves registered, currently connected human players for AO
sizing regardless of team-selection state; the existing team-selected UID path
continues to own voting and deployment eligibility. The round system retains
valid published candidates and reconciles them only when current connected-human
population invalidates an option, with a final resolution-time defence.

Location vehicle capability is derived centrally from actual convention-resolved
Eden spawn roles. UI and vehicle systems consume the same side-specific free,
paid and command capability result; a derivable role name is never authority.

Combat attribution remains server-owned and fail-closed. Bounded event-driven
collection observes server-visible projectile creation and hit events and
resolves only generated factual ammo compatibility plus the canonical
`variantOf` graph. Verbose `CfgBnKothCombat.attributionDiagnostics` RPT output
is optional. Only one `ATTRIBUTED` canonical infantry root attached to the
canonical valid-PvP kill record may award weapon mastery; `UNKNOWN`,
`AMBIGUOUS`, explosive, and non-infantry evidence awards none. Client-reported
weapon classnames and `currentWeapon` are never authoritative attribution.

3. Function Prefix

All KOTH mission functions use:

bn_koth_fnc_

Examples:

bn_koth_fnc_round_setState
bn_koth_fnc_zone_getPopulation
bn_koth_fnc_zone_updateControl
bn_koth_fnc_scoring_addTeamScore

Functions from external libraries retain their original prefixes and must not use the `bn_koth_fnc_` prefix.

KOTH functions must not be added to the Paradigm repository unless they are genuinely generic and useful outside KOTH.

4. Repository Organisation

bn-koth-vietnam/
├── config/
├── functions/
│   ├── common/
│   ├── round/
│   ├── roundStats/
│   ├── teams/
│   ├── groups/
│   ├── zone/
│   ├── scoring/
│   ├── respawn/
│   ├── traversal/
│   ├── loadouts/
│   ├── vehicles/
│   ├── progression/
│   ├── persistence/
│   └── ui/
├── ui/
├── images/
├── sounds/
├── strings/
├── description.ext
├── init.sqf
├── initServer.sqf
├── initPlayerLocal.sqf
├── initPlayerServer.sqf
└── maps/
    └── <terrain>/
        ├── mission.sqm
        └── map_config/locations.hpp

Shared gameplay/config/tooling remain at repository root.

Terrain-specific AO/location runtime configuration is owned by:

maps/<terrain>/map_config/locations.hpp

Generated/symlinked Arma mission folders are development outputs, not
repository source-of-truth structure.

5. Folder Ownership

"config/"

Contains values and definitions, not active gameplay loops.

Examples:

- playable sides;
- faction definitions;
- score limits;
- round timings;
- zone settings;
- location definitions;
- loadout definitions;
- reward values.

"functions/common/"

Contains small utilities used by multiple systems.

A function belongs here only when it is not owned by one specific gameplay system.

"functions/round/"

Contains:

- round state;
- valid state transitions;
- starting a round;
- ending a round;
- resetting a round;
- declaring a winner.

"functions/roundStats/"

Owns server-authoritative, round-only competitive player statistics and the
small Live Leaders presentation projection.

Current responsibilities include:

- kills and deaths for the active round;
- current and best valid-PvP kill streaks;
- physical objective-point contribution from actual team score ticks;
- `BN_KOTH_roundStats`, keyed by player UID and kept server-only;
- `BN_KOTH_liveLeaders`, the small client-visible projection used by the lobby.

Round statistics consume existing authoritative gameplay decisions rather than
recalculating them:

- canonical kill identity/validity comes from `functions/combat/`;
- objective eligibility comes from `BN_KOTH_zoneEligibleSnapshot`;
- objective points are recorded only when `functions/scoring/` actually awards
  the corresponding team score tick.

Live Leaders use a strict-greater replacement rule. Equal values do not replace
the current card holder, so the first player to reach a leading value keeps the
card until another player exceeds it.

Round stats reset only when the next round enters `ACTIVE`. They remain intact
through `ENDING`, `RESETTING`, `WAITING` and map voting so the completed round's
leaders can still be shown in the lobby.

Round-only statistics are deliberately separate from persistent progression and
future lifetime statistics.

"functions/teams/"

Contains:

- playable-side validation;
- team assignment;
- team balance;
- faction information;
- side switching rules.

"functions/groups/"

Owns the server-session player-group model and its derived native Arma group
representation. `BN_KOTH_groups` is server-only and keyed by a stable logical
group ID; each non-empty record has one `leaderUid`, an ordered unique
`memberUids` array, a revision, and derived native-group fields. The server
serializes CREATE, JOIN, LEAVE, KICK, TRANSFER and DISBAND mutations against
current player records. A client supplies only the operation and applicable
target identifier; the server resolves the requester through
`remoteExecutedOwner` and the server-owned player registry.

Logical groups survive the round lobby/reset cycle but not a member disconnect.
Native grouping is event-driven at logical mutation, deployment and ACTIVE JIP
deployment, death/respawn, return to lobby, disconnect, and round release. It is
never a second authority: team assignment remains owned by `functions/teams/`,
and reconciliation may remove an incompatible member but may not change a
player's team.

The logical leader's authoritative deployed playable side controls final
same-side reconciliation. A connected but undeployed leader has no inferred
side: membership and `leaderUid` remain unchanged, and affected deployed members
remain in normal/singleton native groups until the leader deploys. Native Arma
leadership may temporarily differ while the logical leader is dead or otherwise
not materialized, but derived engine leadership never changes `leaderUid`.

Group presentation is requester-specific client state. Opening the Group Menu
requests a read-only snapshot. Snapshot handling does not own routine native
repair and the menu is never required for authoritative or native state to
become correct. Mutation/lifecycle publication captures transient impact from
the affected logical group members and sides. Only deployed recipients whose
current-group or same-side available-group projection can have changed receive
an update; an unrelated ungrouped lifecycle event produces no group traffic.

"functions/zone/"

Contains:

- detecting eligible players;
- counting raw, weighted and Priority occupants by side in one eligibility pass;
- calculating zone ownership;
- publishing zone state;
- detecting control changes.

"functions/scoring/"

Contains:

- team scores;
- score intervals;
- score validation;
- score limit checks;
- occupied-AO objective-cycle cadence and dispatch to progression.

"functions/respawn/"

Contains:

- player respawn handling;
- server-authoritative safe-zone membership;
- client-local firing and damage enforcement for player-owned units;
- locality-aware vehicle invulnerability and firing enforcement;
- opposing-safe-zone vehicle-entry prevention and ejection;
- server-owned safe-zone ground-loot and corpse cleanup;
- valid spawn selection.

"functions/traversal/"

Contains owning-client traversal behaviour:

- local player-state validation;
- obstacle, ledge, destination and clearance probing;
- stock Arma 3/S.O.G. animation selection;
- local cubic movement execution and interruption recovery;
- optional client-only RPT and Draw3D diagnostics.

Traversal owns no authoritative game-mode state and exposes no RemoteExec
endpoint. Its tuning is owned by `CfgBnKothTraversal`, and its input action is
registered through the existing mission-local gamemode keybinding system.

"functions/loadouts/"

Contains:

- applying configured loadouts;
- validating equipment;
- client-local physical inventory blocking inside active safe zones;
- future equipment purchase handling.

"functions/vehicles/"

Contains:

- vehicle spawning;
- vehicle ownership;
- active vehicle limits;
- abandonment and cleanup;
- future vehicle purchases.

"functions/progression/"

Contains player progression systems:

- `xp/` owns server-authoritative XP awards, level calculation, level progress,
  and AO participation, control/Priority bonuses, and combat reward hooks;
- `cash/` owns server-authoritative session cash initialization, reads, awards,
  and atomic spending. It consumes the same validated kill/objective
  reward events as XP and creates no independent eligibility loop;
- `acquisition/` owns canonical weapon purchase and server-session rental
  transactions. It calculates the combined cash/entitlement transition once,
  commits it once, and publishes only the affected player's targeted state;
- `mastery/` owns the canonical lowercase `weaponKills` map and awards exactly
  once from fail-closed server attribution on a valid active-round PvP kill;
- progression entitlement evaluation consumes authoritative level/rule data;
- persistent unlocks and mastery storage cross the progression/persistence
  boundary; future perks and reward multipliers belong there rather than in UI.

Current authoritative progression state is stored in the server-owned
`BN_KOTH_playerProgression` map keyed by UID. Registration establishes it through
`functions/persistence/`: load by validated UID, normalize the persistent schema,
or deliberately create a session fallback/first-time state. Persistent fields are
`schemaVersion`, `uid`, `xp`, `cash`, `ownedWeapons`, and `weaponKills`. Level is
always derived from XP. `rentedWeapons` remains server-session-only and resets on
server restart. Clients receive only
their own presentation state, including cash, through the existing initial
snapshot and targeted progression-update path.

Round-only competitive statistics do not belong to progression. They are owned
by `functions/roundStats/` and reset on the next `ACTIVE` round without changing
persistent/session progression values.

"functions/persistence/"

Owns the server-only persistence service boundary, schema normalization,
first-time defaults, dirty/save scheduling, reconnect recovery, and backend
adapter calls. The production adapter uses extDB3 SQL_CUSTOM prepared statements;
the in-memory adapter remains for focused contract tests only. Gameplay systems
never issue SQL or call extDB3 directly. Numbered files under
`database/migrations/` own the durable schema. Unsupported future schemas,
malformed records, and backend failures are logged explicitly. Configured session
fallback remains server-authoritative, is write-blocked from durable storage, and
never treats a failed save as a success.

"functions/career/"

Owns server-only lifetime career delta batching, connected-session playtime,
paired lifetime/hourly persistence, and bounded semantic leaderboard queries.
It consumes decisions already made by combat, round statistics, XP and round
completion owners. It does not detect kills, deaths, objective presence, XP or
winners independently. Steam UID is identity; profile name is presentation
metadata updated against the same UID. Leaderboard callers select only approved
metric/period/mode IDs and bounded result sizes; SQL_CUSTOM statement selection
and database access remain server-only.

"functions/ui/"

Contains client-side presentation:

- HUD updates;
- menus;
- notifications;
- score displays;
- zone displays.

UI functions do not calculate authoritative results.

6. Configuration Versus Logic

Values likely to change during balancing must not be buried inside functions.

Avoid:

if (_score >= 1000) then {
    // End round
};

Prefer:

private _scoreLimit = missionNamespace getVariable [
    "BN_KOTH_scoreLimit",
    1000
];

The score limit should originate from the relevant configuration file.

7. System Boundaries

Systems communicate through small public functions.

Example:

[] call bn_koth_fnc_scoring_awardObjectiveTick;

The zone system decides who controls the zone.

The scoring system decides whether and how score is awarded.

The zone system must not directly edit the team score variable.

The existing zone cadence calls scoring_awardObjectiveTick. Scoring owns the
30-second occupied-AO cycle in BN_KOTH_scoreProgress: CONTROLLED and CONTESTED
continue the same cycle, including controller changes; NEUTRAL/inactive resets it.
At completion scoring refreshes zone_evaluateControl with its skip-scoring flag,
then progression_xp_awardObjectiveTick consumes BN_KOTH_zoneEligibleSnapshot.
Progression awards additive participation/control/Priority XP and cash using its
existing mutation and persistence paths, with no player scan. Only CONTROLLED
completions award team score and round/career objective points.

Consecutive cycles publish an active start timestamp in the same completion path,
aligned to the previous server epoch rather than the delayed update time. Missed
intervals after a server stall are not replayed with fabricated eligibility.
HUD interpolation wraps against that server timestamp and duration while the
next publication is in flight; it never awards or acknowledges a cycle.
JIP uses the existing scoreProgress snapshot. Round ENDING resets progress and
prevents reseeding after the final valid personal reward and team score tick.

Round statistics are downstream consumers of those authoritative decisions.
They must not reinterpret kill validity, duplicate AO eligibility checks, award
team score, or award progression rewards.

8. Function Files

Each function file must include:

/*
    File:
        fn_example.sqf

    Author:
        Bro-Nation

    Description:
        Clear description of this function.

    Execution:
        Server / Client / Any

    Parameters:
        0: Description <TYPE>

    Returns:
        Description <TYPE>

    Public:
        Yes / No
*/

Private helper functions should still document their execution environment and purpose.

9. Authoritative State

Authoritative server state includes:

- current round state;
- active combat location;
- zone ownership;
- zone population (`raw`, `weighted` and `priority` pairs in playable-side order);
- active team safe-zone markers;
- player and vehicle safe-zone status;
- team scores;
- winning side;
- player progression;
- server-only round statistics;
- the client-visible Live Leaders projection;
- purchases;
- spawned gameplay vehicles.

Clients may receive copies of this information for display.

Logical player groups additionally own a session-only display name and lock
flag. Stable logical IDs remain unchanged by renaming, and neither field is
derived from native Arma groups. Transient 60-second invitations are held in a
separate server-only target-keyed map and are never persisted or broadcast.
Requester-specific projections expose invite candidates only after the server
proves that both leader and candidate are deployed ACTIVE humans on the same
authoritative side and that the candidate is currently ungrouped.

The server decides safe-zone membership from authoritative player records and active location markers. Commands whose effects depend on object locality, including player ejection and vehicle `allowDamage`, execute on the current owner through narrowly allowlisted server-to-client endpoints. Local event handlers enforce firing, damage and physical-inventory presentation rules. The server independently deletes safe-zone ground loot and corpses from a strict candidate allowlist, so client inventory presentation is never the cleanup authority.

A client copy is never treated as proof by the server.

10. Remote Execution

Only specifically approved functions may be remotely executed.

Client requests must be validated by the server.

A client request must never contain a result that the client was responsible for deciding.

Good request:

Request to purchase loadout X.

Bad request:

Grant me loadout X because I have enough money.

11. Dependencies

The mission is built using native Arma 3 mission systems.

Initial required dependencies:

- Arma 3;
- S.O.G. Prairie Fire.

The project does not depend on:

- Paradigm;
- Mike Force;
- CBA;
- another KOTH mission or framework.

Dedicated production persistence additionally requires the documented extDB3
and MariaDB/MySQL server deployment. extDB3 remains an adapter dependency, not a
gameplay or client dependency.

External dependencies must not be introduced without a documented reason and agreement from the project maintainers.

Code may be informed by patterns used in other Bro-Nation projects, but KOTH-specific code must be implemented and owned by this repository.

12. Definition of Complete

A feature is complete only when:

- its files are in the correct system folder;
- its public functions are documented;
- locality is correct;
- client inputs are validated;
- no unrelated system behaviour is duplicated;
- it has been tested on a dedicated server;
- relevant documentation has been updated.

13. Store Transaction Boundary

The deployed Store is a global canonical-weapon discovery and acquisition
client. It reads targeted progression state for presentation and submits only
operation/classname intent. A narrow server endpoint derives the caller from
`remoteExecutedOwner`, delegates to the existing acquisition owner, returns
the structured result only to that requester, and relies on the existing
targeted progression update for cash/ownership/rental repaint. Store
transactions never auto-equip a weapon.

14. Vehicle Progression Boundary

`CfgBnKothVehicles >> Metadata >> Vehicles` owns human-authored vehicle
progression and provisional economy policy. Canonical roots own side, level,
price, Store category and role fields; an explicitly authored structural
variant may contain only `variantOf` and inherits the root policy. Runtime must
not infer relationships or Store grouping from classnames.

The one-time factual source audit is stored in `data/vehicle_inventory.csv`.
It records public physical EAST/WEST S.O.G. classes and official table facts
only. It is not runtime configuration and owns no KOTH entitlement or balance
policy. Because the official tables do not prove vehicle inheritance, the
current metadata authors only a curated combat-progression surface and
declares no vehicle `variantOf` relationships. Paint, faction and support-only
copies remain audit rows, not progression products.

`functions/vehicles/` owns config lookup, pure side/level/perk eligibility and
the authoritative one-life rental lifecycle. RENT is the complete transaction:
it validates eligibility and affordability, reserves an authored paid pad,
creates and sanitizes the exact curated vehicle, registers UID-owned access
state, and only then charges cash exactly once. One UID may hold at most one
active rented vehicle at a time; there is no pending/requisition stage. Rental
state never persists. The managed free-vehicle and command-vehicle lifecycles
remain separate, and a
rented M577 receives no managed command capability.
# Perk ownership and activation

Perks extend the existing progression/persistence boundary. `ownedPerks` is permanent purchase state; `activePerks` is the persisted, bounded subset whose gameplay effects are enabled. The server owns both arrays, purchase transactions, active-slot validation, and managed-loadout enforcement. Clients receive only a targeted presentation projection and submit narrow perk intents.

The Suppressor perk is enforced only when constructing or applying a managed loadout. Battlefield pickups remain ordinary Arma inventory state and are not polled or deleted. Confirmed deactivation first replaces the server-owned intended loadout with a catalogue-derived suppressor-free loadout, applies that server-derived loadout through the existing local application path, and only then finalizes deactivation.

Cloak is consumed at the server-owned successful-spot boundary. The ordinary replicated mark and its expiry remain unchanged; only the target HUD-warning deadline is omitted when the authoritative requester's `activePerks` contains `cloak`. Warning state is per successful action, so a later non-Cloak spot can still warn an already marked target.

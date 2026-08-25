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
│   ├── zone/
│   ├── scoring/
│   ├── respawn/
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
- future personal reward handling.

"functions/respawn/"

Contains:

- player respawn handling;
- server-authoritative safe-zone membership;
- client-local firing and damage enforcement for player-owned units;
- locality-aware vehicle invulnerability and firing enforcement;
- opposing-safe-zone vehicle-entry prevention and ejection;
- server-owned safe-zone ground-loot and corpse cleanup;
- valid spawn selection.

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
  and Priority-zone, control, and combat reward hooks;
- `cash/` owns server-authoritative session cash initialization, reads, awards,
  and atomic spending. It consumes the same validated kill/control/Priority
  reward events as XP and creates no independent eligibility loop;
- `acquisition/` owns canonical weapon purchase and server-session rental
  transactions. It calculates the combined cash/entitlement transition once,
  commits it once, and publishes only the affected player's targeted state;
- `mastery/` owns the canonical lowercase `weaponKills` map and awards exactly
  once from fail-closed server attribution on a valid active-round PvP kill;
- progression entitlement evaluation consumes authoritative level/rule data;
- future persistent unlocks, perks, mastery storage and reward multipliers
  belong to progression/persistence boundaries rather than client UI.

Current progression state is stored in the server-owned
`BN_KOTH_playerProgression` map keyed by UID. It is session-scoped for now and
is not yet database-backed. Cash, permanent weapon ownership, and weapon
rentals, and weapon mastery initialize once per UID registration and survive
respawn, side changes and round transitions for the server session. Rentals currently expire only
with that session; no wall-clock or round reset owns rental expiry.
Cumulative XP is the stable progression value;
level is derived from the config-owned curve so future persistence can load XP
without duplicating balance rules into the database layer. Clients receive only
their own presentation state, including cash, through the existing initial
snapshot and targeted progression-update path.

Round-only competitive statistics do not belong to progression. They are owned
by `functions/roundStats/` and reset on the next `ACTIVE` round without changing
persistent/session progression values.

"functions/persistence/"

Contains future:

- database loading;
- database saving;
- data migration;
- reconnect recovery.

No other system may communicate directly with the database.

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

[_controllingSide] call bn_koth_fnc_scoring_awardControlTick;

The zone system decides who controls the zone.

The scoring system decides whether and how score is awarded.

The zone system must not directly edit the team score variable.

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

The project does not initially depend on:

- Paradigm;
- Mike Force;
- CBA;
- extDB3;
- another KOTH mission or framework.

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

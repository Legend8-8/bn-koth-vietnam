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

mission/
└── bn_koth_vietnam.cam_lao_nam/
    ├── config/
    ├── functions/
    │   ├── common/
    │   ├── round/
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
    └── strings/

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
- counting players by side;
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
- safe-zone handling;
- spawn protection;
- valid spawn selection.

"functions/loadouts/"

Contains:

- applying configured loadouts;
- validating equipment;
- future equipment purchase handling.

"functions/vehicles/"

Contains:

- vehicle spawning;
- vehicle ownership;
- active vehicle limits;
- abandonment and cleanup;
- future vehicle purchases.

"functions/progression/"

Contains future:

- experience;
- levels;
- unlocks;
- currency;
- player statistics.

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
- zone population;
- team scores;
- winning side;
- player progression;
- purchases;
- spawned gameplay vehicles.

Clients may receive copies of this information for display.

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
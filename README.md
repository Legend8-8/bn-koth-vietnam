Bro-Nation KOTH Vietnam

A two-team King of the Hill game mode for Arma 3, built around the S.O.G. Prairie Fire setting and assets.

The mission is being developed as a standalone Bro-Nation project using native Arma 3 mission systems.

Status

This project is in early development.

The initial goal is a small, reliable multiplayer prototype containing:

- two playable teams;
- protected faction bases;
- one combat zone;
- zone control;
- team scoring;
- a winning score;
- round ending and resetting.

Progression, currency, shops and database persistence will be added only after the core game mode works reliably.

Core Concept

Two teams fight for control of a designated combat zone.

A team controls the zone when it has more eligible players inside the zone than the opposing team.

The controlling team earns score at configured intervals.

The first team to reach the score limit wins the round.

Initial Teams

- WEST: United States and allied forces
- EAST: PAVN and Viet Cong forces

The game mode is initially designed for two teams, but playable sides must remain configuration-driven so another side could be introduced later without rewriting the core systems.

Requirements

- Arma 3
- S.O.G. Prairie Fire

The initial project does not require:

- Paradigm;
- Mike Force;
- CBA;
- extDB3;
- another KOTH framework;
- client-side community mods.

Additional dependencies must not be introduced without a documented reason and maintainer agreement.

Advanced Traversal

The mission directly includes Bro-Nation Advanced Climbing - Vanilla/SOG
behaviour using stock Arma 3 and S.O.G. animation states. No separate client mod
is required. The action is unbound by default and can be assigned from the pause
menu under `GAMEMODE KEYBINDINGS` as `Advanced Climb (Vanilla/SOG)`.

Project Principles

- The server owns authoritative gameplay state.
- Clients display state and submit validated requests.
- Every gameplay system has one clear folder and owner.
- Configuration is kept separate from runtime logic.
- Important values are configurable.
- Features are developed in small, reviewable stages.
- Dedicated-server testing is required.
- KOTH-specific code remains inside this repository.
- The project must remain easy to navigate.

A developer should be able to identify the location of a feature without searching the entire repository.

Examples:

Zone ownership:
functions/zone/

Team scoring:
functions/scoring/

Round state and victory:
functions/round/

Respawning and spawn protection:
functions/respawn/

Vehicle spawning and limits:
functions/vehicles/

Documentation

Project decisions and technical rules are documented in:

- ""docs/game-design.md"" (docs/game-design.md) — gameplay rules and project scope;
- ""docs/architecture.md"" (docs/architecture.md) — code organisation and system ownership;
- ""docs/multiplayer-locality.md"" (docs/multiplayer-locality.md) — server, client and object locality;
- ""docs/testing.md"" (docs/testing.md) — testing requirements and checklists.
- ""docs/development.md"" (docs/development.md) — local dev setup and build tooling.
- ""docs/zones.md"" (docs/zones.md) — multi-zone configuration and one-mission workflow.

Contributors must read these documents before implementing a major system.

Local Developer Tooling

Windows helper scripts are included in the repository root:

- setup_dev_environment.py
- build.py
- user_paths_example.py

These scripts are intentionally similar to the Mike-Force local workflow.

Repository Structure

Shared source of truth lives at repository root:

bn-koth-vietnam/
├── config/
├── functions/
│   ├── common/
│   ├── round/
│   ├── teams/
│   ├── zone/
│   ├── scoring/
│   ├── respawn/
│   └── ui/
├── ui/
├── images/
├── sounds/
├── strings/
├── description.ext
├── initServer.sqf
├── initPlayerLocal.sqf
├── initPlayerServer.sqf
└── maps/
    └── <terrain>/
        ├── mission.sqm
        └── map_config/
            └── locations.hpp

Runtime terrain-specific AO/location config is owned only by:

maps/<terrain>/map_config/locations.hpp

Development mission folders (for example bn_koth_vietnam.cam_lao_nam in Arma
MPMissions) are generated/symlinked outputs and are not source-of-truth repo
structure.

Folders should be created when they are required. Empty systems do not need placeholder implementation files.

Function Naming

Mission functions use the prefix:

bn_koth_fnc_

Examples:

bn_koth_fnc_round_setState
bn_koth_fnc_zone_getPopulation
bn_koth_fnc_zone_updateControl
bn_koth_fnc_scoring_addTeamScore

Development Workflow

The intended branch structure is:

main
development
feature/*
fix/*
docs/*

- "main" contains stable releases.
- "development" contains integrated development work.
- Feature and fix branches are created from "development".
- Changes are merged through pull requests.
- Direct development on "main" should be avoided.
- One pull request should contain one clear feature or fix.

First Development Milestone

The first playable version must demonstrate:

1. The dedicated server initialises the mission.
2. WEST and EAST players spawn at their own bases.
3. The server detects eligible players inside the combat zone.
4. The server determines whether the zone is neutral, contested or controlled.
5. The controlling team earns score.
6. Clients receive and display the current state.
7. A team reaching the score limit wins.
8. The round ends and resets cleanly.
9. Join-in-progress players receive the current round state.
10. Client and server RPT files remain free from repeated script errors.

Contributing

Before changing gameplay code:

1. Read the relevant documentation.
2. Identify the system that owns the behaviour.
3. Avoid placing unrelated behaviour in the same function.
4. Confirm where the code must execute.
5. Keep authoritative decisions on the server.
6. Test the change using the process in "docs/testing.md".
7. Update documentation when behaviour or architecture changes.

Copilot contributors must follow ".github/copilot-instructions.md".

Licence

A project licence must be selected before public redistribution or accepting outside contributions.

Until then, no assumption should be made that project code may be copied, modified or redistributed outside Bro-Nation.

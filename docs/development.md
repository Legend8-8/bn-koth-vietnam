Bro-Nation KOTH Vietnam - Development Setup

1. Purpose

This repo includes local Windows tooling similar to Mike-Force:

- setup_dev_environment.py: creates/syncs linked mission folders in your Arma missions path.
- build.py: creates clean output copies in build_output/ for packaging/testing.

2. First-Time Setup

1. Review and edit user_paths.py.
2. Run setup_dev_environment.py as administrator.
3. Launch Arma 3 and open a generated mission folder such as bn_koth_vietnam.cam_lao_nam.

3. Build Output

Run build.py to export trimmed mission folders for all maps under maps/<map_name>/.

4. Multi-Map Layout

- Shared mission content remains at repo root.
- Map-specific overrides go in maps/<map_name>/ (for example maps/cam_lao_nam/mission.sqm).
- Terrain AO/location runtime config is owned by maps/<map_name>/map_config/locations.hpp.
- Root config/locations.hpp is non-authoritative and must not contain live AO definitions.
- Target mission folders are named as <MISSION_STEM>.<map_name>.

5. Notes

- user_paths.py is gitignored as machine-local config.
- Existing linked mission content is retained. The merged `config/` subtree is
  refreshed from shared and map-specific sources on every setup run because it
  cannot be represented by one direct directory link. This keeps function
  registrations and other shared configuration current in existing missions.

6. Multiplayer Handoff Reference

When adding or modifying player-representation transitions, use the locality lifecycle documented in docs/multiplayer-locality.md section 4.1 (Representation handoff lifecycle).

Short rule: initPlayerLocal.sqf is client startup only, while bn_koth_fnc_teams_transferRepresentation is the server-owned handoff path for moving a player to a new representation unit.

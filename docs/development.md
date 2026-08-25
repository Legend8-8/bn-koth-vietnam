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

7. Equipment Side Metadata

Generated `sourceAffiliations[]` is factual S.O.G. provenance only. KOTH
gameplay availability is human-authored as `allowedSides[]`; visual faction
identity is separately human-authored as `appearanceSide`; progression fields
such as `minLevel` remain independent. Never derive one of these policy fields
from another, and never author policy on a structural weapon variant instead
of its canonical logical root.

For weapons only, `crossSideAllowed = 1` explicitly opens a cross-side mastery
path. `allowedSides[]` remains native/default availability and factual
`sourceAffiliations[]` never enables the path. `masteryKillsRequired` is evaluated
against the server-owned canonical `weaponKills` map after level passes.

Progression and economy balance values belong in mission config. XP reward and
curve values are under `CfgBnKothScoring.progression`; provisional session cash
starting/reward values are under `CfgBnKothScoring.economy`. Server functions
own cash mutation. Clients may display targeted cash state and submit future
purchase intent, but must never set or award cash.

Canonical weapon ownership and rental state are server-owned under
`functions/progression/acquisition/`. Purchase and rent validate the player,
canonical metadata, side, level, perks, configured price, and cash before one
combined state commit. Neither operation equips a weapon. Rentals currently
last for the server session. Store V1 exposes those existing transactions for
canonical weapons. Provisional playtest prices are human-authored only on
canonical roots; structural variants inherit them. Rental is currently 20% of
purchase price. Final price balancing remains future work.
Cross-side mastery is server-authoritative: level,
mastery, and perks pass before purchase/rent, and ownership never bypasses them.

Persistent player data is accessed only through `functions/persistence/`.
Gameplay mutations update `BN_KOTH_playerProgression` and mark the UID dirty;
the service coalesces saves and flushes at disconnect and mission end. Its schema
persists XP, cash, canonical ownership, and weapon mastery, while deriving level
and excluding rentals and round statistics. Production uses the server-only
`EXTDB3` adapter; `MEMORY` remains a contract-test backend. SQL, SQL_CUSTOM
protocol strings, serialization, and extension calls stay inside persistence.
Apply numbered `database/migrations/` files and follow
`docs/deployment-extdb3.md`; never put database credentials in mission config.

Vehicle progression metadata is separately human-authored under
`CfgBnKothVehicles >> Metadata >> Vehicles`. Its explicit `storeCategory`
(`GROUND`, `SEA`, `ROTARY`, or `FIXED_WING`) and `vehicleRole` fields prepare
future Store grouping without classname heuristics. Vehicle progression does
not use weapon mastery. Levels and prices are provisional; persistence and an
authoritative vehicle requisition/acquisition transaction remain future work.
The existing managed free-vehicle system is unchanged and does not treat these
prices as a spawn requirement.

`data/vehicle_inventory.csv` is a one-time factual audit of the official S.O.G.
EAST/WEST CfgVehicles tables, not a maintained scraper output. Factual side,
faction, subcategory and vehicle weapons in that file must never be treated as
KOTH policy. Human-authored side, level, price, Store category and role remain
in `config/vehicles.hpp`, which intentionally selects only the combat-relevant
progression products planned for the Store. No vehicle relationship may be
inferred from a classname or from a similar display name.

Unclassified combat equipment may temporarily remain uncontrolled. Visual
equipment (uniforms, vests, backpacks, headgear, and facewear) must have a
valid matching `appearanceSide` before it can enter an authoritative loadout.

Bro-Nation KOTH Vietnam - Multi-Zone Setup

1. Strategy

Use one mission.sqm per map, not one mission.sqm per zone.

For Cam Lao Nam, keep all potential zones in the same mission.sqm and select one active zone by location ID.

2. Why One mission.sqm

- Easier to maintain than multiple parallel mission files.
- Matches the config-driven architecture.
- Supports server-side rotation between rounds without mission reload.
- Keeps join-in-progress state simple: one authoritative active location.

3. What Defines a Zone

Each zone is defined by location ID in maps/<map_name>/map_config/locations.hpp under CfgBnKothLocations.

Each location should include:

- zoneMarker
- respawnWestMarker
- respawnEastMarker
- westBaseZoneMarker
- eastBaseZoneMarker
- objects[] (optional explicit list; prefix-based detection is preferred)

Both base-zone markers must have valid marker geometry. They define the spatial safe zones for player and vehicle protection, physical inventory blocking, ground-loot removal and corpse cleanup, and are required for the location to be selected. These rules apply only to the active bases; battlefield scavenging remains available in the active AO outside them.

4. mission.sqm Notes (for your current file)

In mission.sqm, marker names are what gameplay code uses, for example:

- saigon_zone
- saigon_respawn_west
- saigon_respawn_east
- saigon_west_base_zone
- saigon_east_base_zone

Numeric marker id values in mission.sqm (for example id=0, id=2, id=3) are editor-internal and should not be used for runtime game logic.

5. Object Grouping by Zone

If an object belongs to a specific location, give it an Eden variable name with prefix <locationId>_.

Example naming pattern:

- saigon_cover_01
- saigon_tower_01
- hue_cover_01

You can still use objects[] for explicit object names, but it is optional.

At location activation time:

- active location static objects are enabled and visible;
- non-active static objects are hidden/disabled but not deleted;
- runtime-created AO objects may be tracked/cleaned up separately.

6. Runtime Flow

Server startup uses CfgBnKothSettings.defaultLocationId and calls:

- bn_koth_fnc_zone_setActiveLocation

That function:

- publishes BN_KOTH_activeLocationId;
- publishes BN_KOTH_activeZoneMarker, active respawn markers and active safe-zone markers;
- hides inactive location markers;
- deactivates non-active static location objects using <locationId>_ prefix matching (and objects[] entries if provided), while keeping them reactivatable.

Zone control/scoring then runs only on BN_KOTH_activeZoneMarker.

7. Adding a New Zone

1. Add zone, respawn and side-specific base-zone markers in mission.sqm (via Eden).
2. Name markers clearly (example: hue_zone, hue_respawn_west, hue_respawn_east, hue_west_base_zone and hue_east_base_zone).
3. Add class hue in maps/<map_name>/map_config/locations.hpp.
4. Give zone-specific objects Eden variable names with prefix <locationId>_ (for example hue_...).
5. Set defaultLocationId to hue for testing.
6. Start mission and verify only hue markers/objects are active.

8. Dynamic Priority Zone

The zone system also supports a moving priority area inside the active AO.

- The priority zone is a smaller rectangle aligned with the active zone marker.
- `priorityAreaRatio = 0.10` directly configures ten percent of the AO footprint area; the server derives the linear scale with `sqrt(priorityAreaRatio)` while preserving the AO aspect ratio.
- A one-metre minimum half-size is only a degenerate-AO safety floor and does not override the configured ratio for normal AOs.
- Movement cadence and distance remain config-owned and are applied by the existing server zone manager.
- Actual elapsed server time is used for movement so scheduler delays do not reduce its real-time speed.
- The complete priority-zone footprint remains inside the active AO, including rotated and elliptical AOs.
- Players inside the priority zone count as two players for objective control weighting.
- Main AO players continue to count normally.
- The existing control pass publishes one structured population value with raw eligible players, weighted control and raw Priority occupancy for both playable sides.
- The gameplay HUD consumes published `raw` population for the main AO row and
  published `priority` population for a visually distinct `+N` bonus row; it
  does not rescan players or alter control weighting.
- Its appearance uses raw eligible-player counts inside the priority zone, independently of control weighting:
  - no WEST or EAST players: green with a solid fill;
  - more WEST than EAST players: blue with a solid fill;
  - more EAST than WEST players: red with a solid fill;
  - equal nonzero WEST and EAST players: purple with diagonal lines.
- The server owns movement and control weighting; control evaluation does not advance movement.
- The server also owns priority-zone appearance decisions and broadcasts marker changes only when the color or brush changes.
- A global marker provides client and join-in-progress visibility of the current objective hotspot.
- During ACTIVE play, one silent client-local Arma Simple Task identifies the
  Priority objective. Its destination follows the same global marker, owns no
  geometry or gameplay state, and is removed with the deployed HUD/objective.

The same active-AO lifecycle owns a small config-driven set of physical battlefield
weapon holders. The server performs a bounded placement search inside the active
marker, resolves ammunition from factual compatibility data, tracks every holder,
and deletes the tracked set when the AO is cleared. Physical use grants no Arsenal,
ownership, rental, or persistent progression entitlement.
Placement resolves the highest nearby geometry surface within 1.5 metres of the
terrain baseline and adds only 0.08 metres of clearance, keeping holders visible
on pavement without accepting inaccessible elevated surfaces.

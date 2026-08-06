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
- objects[] (optional explicit list; prefix-based detection is preferred)

4. mission.sqm Notes (for your current file)

In mission.sqm, marker names are what gameplay code uses, for example:

- saigon_zone
- saigon_respawn_west
- saigon_respawn_east

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
- publishes BN_KOTH_activeZoneMarker and active respawn markers;
- hides inactive location markers;
- deactivates non-active static location objects using <locationId>_ prefix matching (and objects[] entries if provided), while keeping them reactivatable.

Zone control/scoring then runs only on BN_KOTH_activeZoneMarker.

7. Adding a New Zone

1. Add zone + respawn markers in mission.sqm (via Eden).
2. Name markers clearly (example: hue_zone, hue_respawn_west, hue_respawn_east).
3. Add class hue in maps/<map_name>/map_config/locations.hpp.
4. Give zone-specific objects Eden variable names with prefix <locationId>_ (for example hue_...).
5. Set defaultLocationId to hue for testing.
6. Start mission and verify only hue markers/objects are active.

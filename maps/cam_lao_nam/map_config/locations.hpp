class CfgBnKothSettings
{
    // Location ID used at server start when no override is provided.
    defaultLocationId = "saigon";

    // Optional future rotation list.
    locationRotation[] =
    {
        "saigon"
    };
};

class CfgBnKothLocations
{
    class saigon
    {
        displayName = "Saigon";
        zoneMarker = "saigon_zone";
        respawnWestMarker = "saigon_respawn_west";
        respawnEastMarker = "saigon_respawn_east";

        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "saigon_".
        // Any non-active location objects with prefix "<locationId>_" are auto-deleted.
        objects[] = {};
    };
};

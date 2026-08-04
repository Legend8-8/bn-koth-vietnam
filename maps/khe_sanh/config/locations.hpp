class CfgBnKothSettings
{
    // Set this to one of the IDs defined under CfgBnKothLocations.
    defaultLocationId = "khe_sanh";

    locationRotation[] =
    {
        "khe_sanh"
    };
};

class CfgBnKothLocations
{
    class khe_sanh
    {
        displayName = "Khe Sanh";
        zoneMarker = "khe_sanh_zone";
        respawnWestMarker = "khe_sanh_respawn_west";
        respawnEastMarker = "khe_sanh_respawn_east";

        // Use Eden variable prefix khe_sanh_ for map-specific objects.
        objects[] = {};
    };
};

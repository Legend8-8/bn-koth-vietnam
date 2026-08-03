class CfgBnKothSettings
{
    // Set this to one of the IDs defined under CfgBnKothLocations.
    defaultLocationId = "altis";

    locationRotation[] =
    {
        "altis"
    };
};

class CfgBnKothLocations
{
    class altis
    {
        displayName = "Altis";
        zoneMarker = "altis_zone";
        respawnWestMarker = "altis_respawn_west";
        respawnEastMarker = "altis_respawn_east";

        // Use Eden variable prefix altis_ for map-specific objects.
        objects[] = {};
    };
};

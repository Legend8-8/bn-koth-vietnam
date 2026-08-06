class CfgBnKothSettings
{
    // Set this to one of the IDs defined under CfgBnKothLocations.
    defaultLocationId = "bra";

    locationRotation[] =
    {
        "bra"
    };
};

class CfgBnKothLocations
{
    class bra
    {
        displayName = "Bra";
        zoneMarker = "bra_zone";
        respawnWestMarker = "bra_respawn_west";
        respawnEastMarker = "bra_respawn_east";

        // Use Eden variable prefix bra_ for map-specific objects.
        objects[] = {};
    };
};

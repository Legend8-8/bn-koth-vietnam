class CfgBnKothSettings
{
    // Location ID used at server start when no override is provided.
    defaultLocationId = "saigon";

    // Optional future rotation list.
    locationRotation[] =
    {
	    "saigon",
	    "hue",
	    "hanoi"
    };
};

class CfgBnKothLocations
{
    class saigon
    {
        displayName = "Saigon";
        description = "Urban city center. Dense streets and close-quarters fighting.";
        image = "images\\ui\\lobby\\saigon.jpg";
        zoneMarker = "saigon_zone";
        respawnWestMarker = "saigon_respawn_west";
        respawnEastMarker = "saigon_respawn_east";
        westBaseZoneMarker = "saigon_west_base_zone";
        eastBaseZoneMarker = "saigon_east_base_zone";

        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "saigon_".
        objects[] = {};
    };

    class hue
    {
        displayName = "Hue";
        description = "Riverside city. Long sightlines and strong defensive positions.";
        image = "images\\ui\\lobby\\hue.jpg";
        zoneMarker = "hue_zone";
        respawnWestMarker = "hue_respawn_west";
        respawnEastMarker = "hue_respawn_east";
        westBaseZoneMarker = "hue_west_base_zone";
        eastBaseZoneMarker = "hue_east_base_zone";

        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "hue_".
        objects[] = {};
    };

    class hanoi
    {
        displayName = "Hanoi";
        description = "Capital outskirts. Open areas and village combat.";
        image = "images\\ui\\lobby\\hanoi.jpg";
        zoneMarker = "hanoi_zone";
        respawnWestMarker = "hanoi_respawn_west";
        respawnEastMarker = "hanoi_respawn_east";
        westBaseZoneMarker = "hanoi_west_base_zone";
        eastBaseZoneMarker = "hanoi_east_base_zone";

        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "hanoi_".
        objects[] = {};
    };
};

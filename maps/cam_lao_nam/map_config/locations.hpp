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
        zoneMarker = "saigon_zone";
        respawnWestMarker = "saigon_respawn_west";
        respawnEastMarker = "saigon_respawn_east";
        westBaseZoneMarker = "saigon_west_base_zone";
        eastBaseZoneMarker = "saigon_east_base_zone";
        eastPaidGround_spawnpoint = "saigon_east_paid_ground_spawnpoint";
        eastPaidAir_spawnpoint = "saigon_east_paid_air_spawnpoint";
        eastPaidSea_spawnpoint = "saigon_east_paid_sea_spawnpoint";
        eastFreeGround_spawnpoint = "saigon_east_free_ground_spawnpoint";
        eastFreeAir_spawnpoint = "saigon_east_free_air_spawnpoint";
        eastFreeSea_spawnpoint = "saigon_east_free_sea_spawnpoint";
        westPaidGround_spawnpoint = "saigon_west_paid_ground_spawnpoint";
        westPaidAir_spawnpoint = "saigon_west_paid_air_spawnpoint";
        westPaidSea_spawnpoint = "saigon_west_paid_sea_spawnpoint";
        westFreeGround_spawnpoint = "saigon_west_free_ground_spawnpoint";
        westFreeAir_spawnpoint = "saigon_west_free_air_spawnpoint";
        westFreeSea_spawnpoint = "saigon_west_free_sea_spawnpoint";

        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "saigon_".
        objects[] = {};
    };

    class hue
    {
        displayName = "Hue";
        zoneMarker = "hue_zone";
        respawnWestMarker = "hue_respawn_west";
        respawnEastMarker = "hue_respawn_east";
        westBaseZoneMarker = "hue_west_base_zone";
        eastBaseZoneMarker = "hue_east_base_zone";
        eastPaidGround_spawnpoint = "hue_east_paid_ground_spawnpoint";
        eastPaidAir_spawnpoint = "hue_east_paid_air_spawnpoint";
        eastPaidSea_spawnpoint = "hue_east_paid_sea_spawnpoint";
        eastFreeGround_spawnpoint = "hue_east_free_ground_spawnpoint";
        eastFreeAir_spawnpoint = "hue_east_free_air_spawnpoint";
        eastFreeSea_spawnpoint = "hue_east_free_sea_spawnpoint";
        westPaidGround_spawnpoint = "hue_west_paid_ground_spawnpoint";
        westPaidAir_spawnpoint = "hue_west_paid_air_spawnpoint";
        westPaidSea_spawnpoint = "hue_west_paid_sea_spawnpoint";
        westFreeGround_spawnpoint = "hue_west_free_ground_spawnpoint";
        westFreeAir_spawnpoint = "hue_west_free_air_spawnpoint";
        westFreeSea_spawnpoint = "hue_west_free_sea_spawnpoint";

        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "hue_".
        objects[] = {};
    };

    class hanoi
    {
        displayName = "Hanoi";
        zoneMarker = "hanoi_zone";
        respawnWestMarker = "hanoi_respawn_west";
        respawnEastMarker = "hanoi_respawn_east";
        westBaseZoneMarker = "hanoi_west_base_zone";
        eastBaseZoneMarker = "hanoi_east_base_zone";
        eastPaidGround_spawnpoint = "hanoi_east_paid_ground_spawnpoint";
        eastPaidAir_spawnpoint = "hanoi_east_paid_air_spawnpoint";
        eastPaidSea_spawnpoint = "hanoi_east_paid_sea_spawnpoint";
        eastFreeGround_spawnpoint = "hanoi_east_free_ground_spawnpoint";
        eastFreeAir_spawnpoint = "hanoi_east_free_air_spawnpoint";
        eastFreeSea_spawnpoint = "hanoi_east_free_sea_spawnpoint";
        westPaidGround_spawnpoint = "hanoi_west_paid_ground_spawnpoint";
        westPaidAir_spawnpoint = "hanoi_west_paid_air_spawnpoint";
        westPaidSea_spawnpoint = "hanoi_west_paid_sea_spawnpoint";
        westFreeGround_spawnpoint = "hanoi_west_free_ground_spawnpoint";
        westFreeAir_spawnpoint = "hanoi_west_free_air_spawnpoint";
        westFreeSea_spawnpoint = "hanoi_west_free_sea_spawnpoint";

        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "hanoi_".
        objects[] = {};
    };
};

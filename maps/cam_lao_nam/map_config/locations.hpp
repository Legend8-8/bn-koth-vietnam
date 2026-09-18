class CfgBnKothSettings
{
    // Location ID used at server start when no override is provided.
    defaultLocationId = "saigon";

    // Optional future rotation list.
    locationRotation[] =
    {
	    "saigon",
	    "saigon_tower",
	    "hue",
	    "hanoi",
        "bao_ve",
        "son_tay_pow"
    };
};

class CfgBnKothLocations
{
    class son_tay_pow
    {
        displayName = "Son Tay POW Camp";
        description = "Compact compound fighting around the Son Tay POW camp.";
        image = "images\ui\lobby\son_tay_pow.jpg";
        minPlayers = 0;
        maxPlayers = 20;
        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "son_tay_pow_".
        objects[] = {};
    };

    class saigon
    {
        displayName = "Saigon";
        description = "Urban city center. Dense streets and close-quarters fighting.";
        image = "images\ui\lobby\saigon.jpg";
        minPlayers = 15;
        maxPlayers = -1;
        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "saigon_".
        objects[] = {};
    };

    class saigon_tower
    {
        displayName = "Saigon Tower";
        description = "Compact courtyard and seven-level tower fighting.";
        image = "";
        minPlayers = 0;
        maxPlayers = 10;
        objects[] = {};
        battlefieldPickupsEnabled = 0;
        airInsertionEnabled = 0;
        maximumControlHeight = 35;
        priorityMode = "VERTICAL_FLOORS";
        priorityFootprintMarker = "saigon_tower_priority_zone";
        priorityFloorAnchors[] = {
            "saigon_tower_floor_ground", "saigon_tower_floor_01",
            "saigon_tower_floor_02", "saigon_tower_floor_03",
            "saigon_tower_floor_04", "saigon_tower_floor_05",
            "saigon_tower_floor_roof"
        };
        priorityFloorLabels[] = {"GROUND", "01", "02", "03", "04", "05", "ROOF"};
        priorityFloorSurfaceTolerance = 0.35;
        priorityDwellSeconds = 25;
        priorityTransitionSeconds = 8;
        priorityContinueChance = 0.60;
    };

    class hue
    {
        displayName = "Hue";
        description = "Riverside city. Long sightlines and strong defensive positions.";
        image = "images\ui\lobby\hue.jpg";
        minPlayers = 15;
        maxPlayers = -1;
        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "hue_".
        objects[] = {};
    };

    class hanoi
    {
        displayName = "Hanoi";
        description = "Capital outskirts. Open areas and village combat.";
        image = "images\ui\lobby\hanoi.jpg";
        minPlayers = 15;
        maxPlayers = -1;
        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "hanoi_".
        objects[] = {};
    };

    class bao_ve
    {
        displayName = "Bao Ve";
        description = "Defensive position with fortified structures.";
        image = "images\ui\lobby\bao_ve.jpg";
        minPlayers = 0;
        maxPlayers = 20;
        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "bao_ve_".
        objects[] = {};
    };
};

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
        image = "images\ui\lobby\saigon.jpg";
        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "saigon_".
        objects[] = {};
    };

    class hue
    {
        displayName = "Hue";
        description = "Riverside city. Long sightlines and strong defensive positions.";
        image = "images\ui\lobby\hue.jpg";
        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "hue_".
        objects[] = {};
    };

    class hanoi
    {
        displayName = "Hanoi";
        description = "Capital outskirts. Open areas and village combat.";
        image = "images\ui\lobby\hanoi.jpg";
        // Optional explicit object list for this location.
        // Preferred convention is Eden variable names with prefix "hanoi_".
        objects[] = {};
    };
};

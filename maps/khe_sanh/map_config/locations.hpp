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
        description = "Highland combat around the airbase.";
        image = "images\ui\lobby\khe_sanh.jpg";

        // Use Eden variable prefix khe_sanh_ for map-specific objects.
        objects[] = {};
    };
};

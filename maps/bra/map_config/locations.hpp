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
        description = "Riverside valley combat.";
        image = "images\ui\lobby\bra.jpg";

        // Use Eden variable prefix bra_ for map-specific objects.
        objects[] = {};
    };
};

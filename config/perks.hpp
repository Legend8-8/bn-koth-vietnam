class CfgBnKothPerks
{
    maxActivePerks = 3;
    suppressorCleanupAckTimeoutSeconds = 10;

    class Perks
    {
        class suppressor
        {
            id = "suppressor";
            displayName = "Suppressor";
            description = "Allows suppressors in managed weapons and carried loadouts while active.";
            purchaseCost = 1;
            purchasable = 1;
            available = 1;

            // Managed-loadout restriction metadata. Validation reads this
            // generically; physical cleanup can remain perk-specific.
            restrictedTraits[] = {"suppressor"};
            restrictedClasses[] = {};
            restrictionCode = "ERR_PERK_SUPPRESSOR_INACTIVE";
            restrictionMessage = "Activate the Suppressor perk before applying a managed loadout containing suppressors.";
        };

        class field_medic_placeholder
        {
            id = "field_medic_placeholder";
            displayName = "Field Medic";
            description = "Placeholder for a future perk.";
            purchaseCost = -1;
            purchasable = 0;
            available = 0;
        };

        class logistics_placeholder
        {
            id = "logistics_placeholder";
            displayName = "Logistics";
            description = "Placeholder for a future perk.";
            purchaseCost = -1;
            purchasable = 0;
            available = 0;
        };
    };
};

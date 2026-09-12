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

        class cloak
        {
            id = "cloak";
            displayName = "Cloak";
            description = "Enemies are not notified when you successfully spot them.";
            purchaseCost = 1;
            purchasable = 1;
            available = 1;
        };

        class medic
        {
            id = "medic";
            displayName = "MEDIC";
            description = "Allows the S.O.G. Medikit in managed loadouts and enables S.O.G.'s Medic-trait revive behavior while deployed.";
            purchaseCost = 1;
            purchasable = 1;
            available = 1;

            restrictedTraits[] = {};
            restrictedClasses[] = {"vn_b_item_medikit_01"};
            restrictionCode = "ERR_PERK_MEDIC_INACTIVE";
            restrictionMessage = "Activate the MEDIC perk before applying a managed loadout containing the S.O.G. Medikit.";
        };

    };
};

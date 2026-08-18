class CfgBnKothCombat
{
    // "killfeed" = full detail, shown to everyone: "Killer [Weapon] Victim ~120m"
    // "deathfeed" = hardcore: only the victim's own team is notified
    //               ("Victim is down"). Killer identity, weapon, and range
    //               are never sent to any client - forces a manual kill
    //               check rather than relying on the feed.
    mode = "killfeed";

    // Per kill-method gate. 0 = no feed entry generated for that kill at
    // all, for anyone, in either mode - not filtered client-side, never
    // broadcast in the first place.
    showDirectKills = 1;    // infantry: rifles, launchers, grenades, melee
    showVehicleKills = 1;   // vehicle-mounted weapons (tank/car/boat/static)
    showCasKills = 1;       // aircraft-delivered kills
    showArtilleryKills = 1; // indirect fire: mortars/artillery
};

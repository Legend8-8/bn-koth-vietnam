class CfgBnKothZone
{
    maximumControlHeight = 50;

    // 0.10 means the Priority footprint occupies ten percent of the AO area.
    priorityAreaRatio = 0.10;
    // Degenerate-AO safety floor only; normal AOs remain governed by area ratio.
    priorityMinimumHalfSize = 1;

    battlefieldPickupWeapons[] = {"vn_rpg2", "vn_rpg7", "vn_m72"};
    battlefieldPickupCount = 5;
    battlefieldPickupMagazineCount = 1;
    battlefieldPickupPlacementAttemptsPerItem = 20;
    battlefieldPickupMinimumSeparation = 15;
    battlefieldPickupMaximumSurfaceOffset = 1.5;
    battlefieldPickupSurfaceClearance = 0.08;

    // Distance advanced per frame while the priority zone is active.
    priorityMoveDistancePerTick = 0.5;

    // A player in the priority zone contributes this total control weight.
    priorityControlWeight = 2;

    priorityMarkerAlpha = 0.75;
    priorityMarkerColor = "ColorGreen";
    priorityMarkerBrush = "Solid";
    priorityMarkerWestColor = "ColorBlue";
    priorityMarkerEastColor = "ColorRed";
    priorityMarkerTieColor = "ColorCIV";
    priorityMarkerTieBrush = "FDiagonal";

};

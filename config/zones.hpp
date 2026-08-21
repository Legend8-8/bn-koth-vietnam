class CfgBnKothZone
{
    maximumControlHeight = 50;

    // sqrt(2) linear scaling makes the footprint area twice the original size.
    prioritySizeRatio = 0.14142136;
    priorityMinimumHalfSize = 8.4852814;

    // Two server-time movement ticks per second, advancing 0.25 metres per tick.
    priorityMoveTickInterval = 0.1;
    priorityMoveDistancePerTick = 0.15;

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

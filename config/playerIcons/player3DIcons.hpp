class CfgBnKothPlayer3DIcons
{
    enabled = 1;
    includeLocalPlayer = 0;
    texture = "\A3\ui_f\data\map\markers\military\triangle_CA.paa";
    heightAboveUnit = .3;
    iconSize = 1;
    nameSize = 0.035;
    shadow = 4;
    shadowColor[] = {0.00, 0.00, 0.00, 1.00};
    maxDistance = 1000;
    // Candidate membership is refreshed at 10 Hz; cached units are still
    // positioned and drawn every frame for smooth presentation.
    candidateRefreshIntervalSeconds = 0.1;
    // Nearby friendlies remain visible through thin geometry and vegetation.
    proximityVisibilityDistance = 50;
    westColor[] = {0.00, 0.00, 1.00, 1.00};
    eastColor[] = {0.90, 0.00, 0.00, 1.00};
    sameGroupColor[] = {0.00, 0.80, 0.00, 1.00};
    casualtyHelpTexture = "\A3\ui_f\data\map\markers\military\warning_CA.paa";
    casualtyHelpColor[] = {1.00, 0.20, 0.15, 1.00};
    casualtyHelpSize = 0.85;
    temporaryEnemyMarkDuration = 10;
};

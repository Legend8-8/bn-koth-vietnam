/*
    File: traversal.hpp
    Author: Legend
    Description: Mission-owned advanced traversal tuning and diagnostics.
*/

class CfgBnKothTraversal
{
    enabled = 1;

    // Traversal classification.
    minObstacleHeight = 0.25;
    stepMaxHeight = 0.55;
    vaultMaxHeight = 1.15;
    lowMantleMaxHeight = 1.80;
    mediumMantleMaxHeight = 2.35;
    maxMantleHeight = 3.00;

    // Nine face-acquisition rays followed by a forward depth profile.
    faceProbeDistance = 1.45;
    faceProbeHeights[] = {0.35, 0.85, 1.35};
    faceProbeOffsets[] = {-0.22, 0.00, 0.22};
    topDepthSamples[] = {-0.03, 0.04, 0.16, 0.34, 0.62};
    topProbeMargin = 0.55;
    profileDepth = 0.82;
    exitDepth = 1.35;
    profileTolerance = 0.42;
    minSurfaceNormalZ = 0.42;
    maxDropBeyond = 2.20;

    // Destination volume.
    landingHeightOffset = 0.06;
    bodyHalfWidth = 0.28;
    landingHeadroom = 1.38;
    openingClearanceHeight = 0.24;

    // Cubic movement timing and interruption limits.
    traversalCooldown = 0.38;
    traversalSpeed = 1.00;
    executionOriginTolerance = 0.90;
    pathTick = 0.015;
    edgeClearance = 0.32;
    stepOverDuration = 0.78;
    vaultDuration = 0.96;
    lowMantleDuration = 1.20;
    mediumMantleDuration = 1.48;
    highMantleDuration = 1.78;
    weaponRestrictions[] = {};

    class Diagnostics
    {
        debugDraw = 0;
        verboseLogging = 0;
        persistTime = 10;
    };
};

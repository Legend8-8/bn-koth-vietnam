class BN_KOTH_RscKillFeed
{
    idd = -1;
    duration = 1e10;
    fadeIn = 0;
    fadeOut = 0;
    movingEnable = 0;
    enableSimulation = 1;

    // Deliberately independent of BN_KOTH_RscHud's show/hide lifecycle -
    // the kill feed should still be visible while dead/waiting to respawn,
    // not just while "gameplay ready". Entries are created dynamically by
    // ui_addKillFeedEntry.sqf; there are no static controls here.
    onLoad = "uiNamespace setVariable ['BN_KOTH_killFeedDisplay', _this select 0];";
    onUnload = "uiNamespace setVariable ['BN_KOTH_killFeedDisplay', displayNull];";

    class controls
    {};
};

class BN_KOTH_RscRewardFeed
{
    idd = -1;
    duration = 1e10;
    fadeIn = 0;
    fadeOut = 0;
    movingEnable = 0;
    enableSimulation = 1;

    // Deliberately independent of BN_KOTH_RscHud's show/hide lifecycle.
    // Reward entries are created dynamically by bn_koth_fnc_ui_addRewardFeedEntry.
    onLoad = "uiNamespace setVariable ['BN_KOTH_rewardFeedDisplay', _this select 0];";
    onUnload = "uiNamespace setVariable ['BN_KOTH_rewardFeedDisplay', displayNull];";

    class controls
    {};
};

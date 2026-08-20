class CfgBnKothPlayerMapIcons
{
    // Master switch for the local player map icon system.
    enabled = 1;

    // Refresh interval in seconds for local icon data rebuilds.
    refreshIntervalSeconds = 0.1;

    // Icon used for same-side player locations.
    iconTexture = "\A3\ui_f\data\map\markers\military\triangle_CA.paa";
    iconColor[] = {1, 1, 1, 1}; //ColorWhite
    groupIconColor[] = {0, .8, 0, 1}; //ColorGreen

    // Overall visibility for local map icons.
    iconAlpha = 1;

    // Local microphone overlay settings.
    micOverlayEnabled = 1;
    micTexture = "\a3\ui_f\data\igui\rscingameui\rscdisplayvoicechat\microphone_ca.paa";
    micColor[] = {.85, .4, 0, 1};  //ColorOrange
    micSize = 24;
    micNameSize = 0.04;
    micInputAction = "PushToTalk";
    micDisplayId = 12;
    micControlId = 51;

    // Local player icon behavior.
    showPassengerCount = 1;
    showDriverName = 1;
};

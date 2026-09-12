class BN_KOTH_Lobby_Background: BN_KOTH_RscText
{
    style = 0;
    text = "";
};

class BN_KOTH_Lobby_Picture: BN_KOTH_RscPicture
{
    text = "";
};

class BN_KOTH_Lobby_Title: BN_KOTH_RscText
{
    style = 0;
    sizeEx = "0.032 * safezoneH";
};

class BN_KOTH_Lobby_Subtitle: BN_KOTH_RscText
{
    style = 0;
    sizeEx = "0.021 * safezoneH";
    colorText[] = {1, 1, 1, 0.85};
};

class BN_KOTH_Lobby_Label: BN_KOTH_RscText
{
    style = 0;
    sizeEx = "0.02 * safezoneH";
    colorText[] = {1, 1, 1, 0.8};
};

class BN_KOTH_Lobby_SectionLabel: BN_KOTH_RscText
{
    style = 0;
    sizeEx = "0.017 * safezoneH";
    colorText[] = {0.88, 0.88, 0.88, 0.68};
};

class BN_KOTH_Lobby_Body: BN_KOTH_RscText
{
    style = 0;
    sizeEx = "0.019 * safezoneH";
    colorText[] = {1, 1, 1, 0.82};
};

class BN_KOTH_Lobby_FinePrint: BN_KOTH_RscText
{
    style = 0;
    sizeEx = "0.015 * safezoneH";
    colorText[] = {0.86, 0.86, 0.86, 0.55};
};

class BN_KOTH_Lobby_Value: BN_KOTH_RscText
{
    style = 1;
    sizeEx = "0.026 * safezoneH";
};

class BN_KOTH_Lobby_Emblem: BN_KOTH_RscPicture
{
    text = "";
    colorText[] = {1, 1, 1, 0.94};
};

class BN_KOTH_Lobby_Button: BN_KOTH_RscButton
{
    style = 2;
    sizeEx = "0.024 * safezoneH";
    colorText[] = {1, 1, 1, 0.95};
    colorFocused[] = {0.22, 0.22, 0.22, 1};
    colorBackgroundDisabled[] = {0.06, 0.06, 0.06, 0.55};
};

class BN_KOTH_Lobby_VoteButton: BN_KOTH_Lobby_Button
{
    style = 0;
    colorBackground[] = {0.13, 0.12, 0.1, 0.92};
    colorBackgroundActive[] = {0.26, 0.22, 0.12, 0.96};
    colorFocused[] = {0.26, 0.22, 0.12, 0.96};
};

class BN_KOTH_Lobby_Roster: BN_KOTH_RscListBox
{
    style = 16;
    sizeEx = "0.019 * safeZoneH";
    rowHeight = "0.027 * safeZoneH";
    colorSelectBackground[] = {0.18, 0.22, 0.26, 0.42};
    colorSelectBackground2[] = {0.18, 0.22, 0.26, 0.42};
    colorBackground[] = {0.03, 0.03, 0.03, 0.12};
};

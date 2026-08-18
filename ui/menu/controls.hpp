class BN_KOTH_Menu_Background: BN_KOTH_RscText
{
    style = 0;
    text = "";
};

class BN_KOTH_Menu_Title: BN_KOTH_RscText
{
    style = 0;
    font = "PuristaSemiBold";
    sizeEx = "0.032 * safeZoneH";
};

class BN_KOTH_Menu_Subtitle: BN_KOTH_RscText
{
    style = 0;
    sizeEx = "0.02 * safeZoneH";
    colorText[] = {0.92, 0.92, 0.90, 0.85};
};

class BN_KOTH_Menu_Label: BN_KOTH_RscText
{
    style = 0;
    sizeEx = "0.017 * safeZoneH";
    colorText[] = {0.80, 0.80, 0.77, 0.72};
};

class BN_KOTH_Menu_Value: BN_KOTH_RscText
{
    style = 0;
    sizeEx = "0.022 * safeZoneH";
    colorText[] = {0.95, 0.95, 0.93, 0.96};
};

class BN_KOTH_Menu_NavButton: BN_KOTH_RscButton
{
    style = 0;
    sizeEx = "0.042 * safeZoneH";
    font = "PuristaSemiBold";
    colorText[] = {0.92, 0.92, 0.88, 0.96};
    colorBackground[] = {0.08, 0.08, 0.07, 0.88};
    colorBackgroundActive[] = {0.18, 0.15, 0.09, 0.96};
    colorFocused[] = {0.18, 0.15, 0.09, 0.96};
};

class BN_KOTH_Menu_ExitButton: BN_KOTH_RscButton
{
    style = 2;
    font = "PuristaSemiBold";
    sizeEx = "0.022 * safeZoneH";
    colorText[] = {0.90, 0.90, 0.88, 0.96};
    colorBackground[] = {0.09, 0.09, 0.08, 0.90};
    colorBackgroundActive[] = {0.17, 0.12, 0.08, 0.96};
    colorFocused[] = {0.17, 0.12, 0.08, 0.96};
};

class BN_KOTH_Menu_List: BN_KOTH_RscListBox
{
    style = 16;
    sizeEx = "0.018 * safeZoneH";
    rowHeight = "0.03 * safeZoneH";
    colorBackground[] = {0.03, 0.03, 0.03, 0.65};
    colorSelectBackground[] = {0.19, 0.14, 0.07, 0.92};
    colorSelectBackground2[] = {0.19, 0.14, 0.07, 0.92};
};

class BN_KOTH_Menu_ActionButton: BN_KOTH_RscButton
{
    style = 2;
    font = "PuristaSemiBold";
    sizeEx = "0.02 * safeZoneH";
    colorText[] = {0.94, 0.92, 0.88, 0.98};
    colorBackground[] = {0.08, 0.08, 0.07, 0.90};
    colorBackgroundActive[] = {0.20, 0.15, 0.08, 0.96};
    colorFocused[] = {0.20, 0.15, 0.08, 0.96};
};

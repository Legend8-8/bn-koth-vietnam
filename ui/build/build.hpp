class BN_KOTH_RscBuildMenu
{
    idd = 6900;
    movingEnable = 0;
    enableSimulation = 1;

    class controlsBackground
    {
        class Background: BN_KOTH_RscText
        {
            x = safeZoneX + safeZoneW * 0.28;
            y = safeZoneY + safeZoneH * 0.18;
            w = safeZoneW * 0.44;
            h = safeZoneH * 0.62;
            colorBackground[] = {0.03, 0.03, 0.03, 0.96};
        };

        class Header: BN_KOTH_RscText
        {
            text = "BUILD MENU";
            x = safeZoneX + safeZoneW * 0.30;
            y = safeZoneY + safeZoneH * 0.20;
            w = safeZoneW * 0.38;
            h = safeZoneH * 0.04;
            colorText[] = {0.96, 0.90, 0.72, 1};
            sizeEx = "0.028 * safeZoneH";
        };
    };

    class controls
    {
        class ItemList: BN_KOTH_RscListBox
        {
            idc = 6901;
            x = safeZoneX + safeZoneW * 0.30;
            y = safeZoneY + safeZoneH * 0.27;
            w = safeZoneW * 0.38;
            h = safeZoneH * 0.38;
        };

        class InfoBox: BN_KOTH_RscStructuredText
        {
            idc = 6904;
            x = safeZoneX + safeZoneW * 0.30;
            y = safeZoneY + safeZoneH * 0.67;
            w = safeZoneW * 0.38;
            h = safeZoneH * 0.08;
            colorBackground[] = {0.09, 0.09, 0.08, 0.82};
            text = "<t size='0.7'>Select an item.</t>";
        };

        class PlaceButton: BN_KOTH_RscButton
        {
            idc = 6902;
            text = "PLACE";
            x = safeZoneX + safeZoneW * 0.30;
            y = safeZoneY + safeZoneH * 0.77;
            w = safeZoneW * 0.14;
            h = safeZoneH * 0.04;
        };

        class CloseButton: BN_KOTH_RscButton
        {
            idc = 6903;
            text = "CLOSE";
            x = safeZoneX + safeZoneW * 0.54;
            y = safeZoneY + safeZoneH * 0.77;
            w = safeZoneW * 0.14;
            h = safeZoneH * 0.04;
        };
    };
};

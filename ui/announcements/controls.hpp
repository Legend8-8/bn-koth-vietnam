#include "idcs.hpp"

class BN_KOTH_AnnouncementNotice: BN_KOTH_RscStructuredText
{
    idc = BN_KOTH_IDC_ANNOUNCEMENT_NOTICE;
    text = "";
    size = "0.026 * safeZoneH";
    colorBackground[] = {0.48, 0.12, 0.075, 0.96};
    tooltip = "Open announcement details";

    class Attributes
    {
        font = "RobotoCondensed";
        color = "#FFF4DF";
        align = "center";
        valign = "middle";
        shadow = 1;
    };
};

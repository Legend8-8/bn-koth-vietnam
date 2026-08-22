class BN_KOTH_RscText
{
    access = 0;
    type = 0;
    idc = -1;
    style = 0;
    linespacing = 1;
    colorBackground[] = {0, 0, 0, 0};
    colorText[] = {1, 1, 1, 1};
    text = "";
    shadow = 0;
    font = "RobotoCondensed";
    sizeEx = "0.024 * safeZoneH";
    fixedWidth = 0;
};

class BN_KOTH_RscStructuredText
{
    access = 0;
    type = 13;
    idc = -1;
    style = 0;
    x = 0;
    y = 0;
    h = 0.035;
    w = 0.1;
    text = "";
    size = "0.024 * safeZoneH";
    shadow = 0;
    class Attributes
    {
        font = "RobotoCondensed";
        color = "#FFFFFF";
        align = "left";
        shadow = 0;
    };
};

class BN_KOTH_RscPicture
{
    access = 0;
    type = 0;
    idc = -1;
    style = 48;
    colorBackground[] = {0, 0, 0, 0};
    colorText[] = {1, 1, 1, 1};
    font = "RobotoCondensed";
    sizeEx = "0.024 * safeZoneH";
    lineSpacing = 0;
    text = "";
    fixedWidth = 0;
    shadow = 0;
};

class BN_KOTH_RscButton
{
    access = 0;
    type = 1;
    idc = -1;
    text = "";
    colorText[] = {1, 1, 1, 1};
    colorDisabled[] = {1, 1, 1, 0.3};
    colorBackground[] = {0.08, 0.08, 0.08, 0.85};
    colorBackgroundDisabled[] = {0, 0, 0, 0.5};
    colorBackgroundActive[] = {0.15, 0.15, 0.15, 1};
    colorFocused[] = {0.15, 0.15, 0.15, 1};
    colorShadow[] = {0, 0, 0, 0};
    colorBorder[] = {0, 0, 0, 0};
    soundEnter[] = {"", 0.09, 1};
    soundPush[] = {"", 0.09, 1};
    soundClick[] = {"", 0.09, 1};
    soundEscape[] = {"", 0.09, 1};
    style = 2;
    x = 0;
    y = 0;
    w = 0.095589;
    h = 0.039216;
    shadow = 0;
    font = "RobotoCondensed";
    sizeEx = "0.024 * safeZoneH";
    offsetX = 0;
    offsetY = 0;
    offsetPressedX = 0;
    offsetPressedY = 0;
    borderSize = 0;
    action = "";
};

class BN_KOTH_RscListBox
{
    access = 0;
    type = 5;
    idc = -1;
    style = 16;
    x = 0;
    y = 0;
    w = 0.4;
    h = 0.4;
    font = "RobotoCondensed";
    sizeEx = "0.023 * safeZoneH";
    rowHeight = "0.028 * safeZoneH";
    colorDisabled[] = {1, 1, 1, 0.25};
    colorSelect[] = {1, 1, 1, 1};
    colorSelect2[] = {1, 1, 1, 1};
    colorSelectBackground[] = {0.2, 0.45, 0.75, 0.45};
    colorSelectBackground2[] = {0.2, 0.45, 0.75, 0.45};
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = {0, 0, 0, 0.35};
    colorScrollbar[] = {1, 1, 1, 0.6};
    period = 1;
    maxHistoryDelay = 1;
    autoScrollSpeed = -1;
    autoScrollDelay = 5;
    autoScrollRewind = 0;
    soundSelect[] = {"", 0.1, 1};
    class ListScrollBar
    {
        color[] = {1, 1, 1, 0.6};
        autoScrollEnabled = 1;
    };
};

class BN_KOTH_RscEdit
{
    access = 0;
    type = 2;
    idc = -1;
    style = 0;
    x = 0;
    y = 0;
    w = 0.2;
    h = 0.04;
    text = "";
    font = "RobotoCondensed";
    sizeEx = "0.022 * safeZoneH";
    colorText[] = {0.95, 0.95, 0.93, 1};
    colorDisabled[] = {0.6, 0.6, 0.58, 0.5};
    colorSelection[] = {0.32, 0.24, 0.10, 1};
    colorBackground[] = {0.035, 0.035, 0.03, 0.96};
    autocomplete = "";
    canModify = 1;
    shadow = 0;
};

class BN_KOTH_RscListNBox
{
    access = 0;
    type = 102;
    style = 16;
    idc = -1;
    x = 0;
    y = 0;
    w = 0.4;
    h = 0.4;
    font = "RobotoCondensed";
    sizeEx = "0.023 * safeZoneH";
    rowHeight = "0.030 * safeZoneH";
    color[] = {1, 1, 1, 1};
    colorDisabled[] = {1, 1, 1, 0.3};
    colorSelect[] = {1, 1, 1, 1};
    colorSelect2[] = {1, 1, 1, 1};
    colorSelectBackground[] = {0.19, 0.19, 0.17, 0.95};
    colorSelectBackground2[] = {0.19, 0.19, 0.17, 0.95};
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = {0.02, 0.02, 0.02, 0.88};
    colorScrollbar[] = {1, 1, 1, 0.6};
    soundSelect[] = {"", 0.1, 1};
    soundExpand[] = {"", 0.1, 1};
    soundCollapse[] = {"", 0.1, 1};
    drawSideArrows = 0;
    idcLeft = -1;
    idcRight = -1;
    period = 1;
    maxHistoryDelay = 1;
    autoScrollSpeed = -1;
    autoScrollDelay = 5;
    autoScrollRewind = 0;
    class ListScrollBar
    {
        color[] = {1, 1, 1, 0.6};
        autoScrollEnabled = 1;
    };
};

class BN_KOTH_RscSlider
{
    type = 3;
    style = 1024;
    idc = -1;
    x = 0;
    y = 0;
    w = 0.3;
    h = 0.025;
    color[] = {1, 1, 1, 0.8};
    colorActive[] = {0.95, 0.78, 0.28, 1};
    shadow = 0;
};

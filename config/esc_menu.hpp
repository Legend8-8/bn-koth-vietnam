#include "\a3\ui_f\hpp\definedikcodes.inc"

class CfgBnKothEscMenuKeybinds
{
    class earplugs_toggle
    {
        defaultKey = DIK_F1;
        shift = "false";
        ctrl = "false";
        alt = "false";
        down = 0;
        function = "bn_koth_fnc_escMenu_earplugs_toggle";
        displayName = "Toggle Earplugs";
        access = 1;
    };
};

class CfgBnKothEscMenuOptions
{
    class earplugVolumeGround
    {
        name = "Earplug Volume (On Ground)";
        type = "Slider";
        default = 0.5;
        range[] = {0, 1};
        step = 0.01;
        onChange = "missionNamespace setVariable ['BN_KOTH_earplugsVolumeGround', _newValue];";
    };

    class earplugVolumeVehicle
    {
        name = "Earplug Volume (In Vehicle)";
        type = "Slider";
        default = 0.5;
        range[] = {0, 1};
        step = 0.01;
        onChange = "missionNamespace setVariable ['BN_KOTH_earplugsVolumeVehicle', _newValue];";
    };
};

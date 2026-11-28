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

    class player3DIconsEnabled
    {
        name = "Player 3D Icons";
        type = "Toggle";
        default = 1;
        onChange = "missionNamespace setVariable ['BN_KOTH_player3DIconsEnabled', _newValue > 0];";
    };

    class player3DIconsAlpha
    {
        name = "Player 3D Icons Alpha";
        type = "Slider";
        default = 1;
        range[] = {0, 1};
        step = 0.05;
        onChange = "missionNamespace setVariable ['BN_KOTH_player3DIconsAlpha', (_newValue max 0) min 1];";
    };
};

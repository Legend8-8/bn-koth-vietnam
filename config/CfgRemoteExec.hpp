class CfgRemoteExec
{
    class Functions
    {
        mode = 1;
        jip = 1;

        class bn_koth_fnc_ui_requestState
        {
            allowedTargets = 1;
            jip = 0;
        };

        class bn_koth_fnc_ui_sendStateToClient
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_ui_receiveState
        {
            allowedTargets = 1;
            jip = 1;
        };

        class bn_koth_fnc_loadouts_request
        {
            allowedTargets = 2;
            jip = 0;
        };

        class bn_koth_fnc_vehicles_requestSpawn
        {
            allowedTargets = 2;
            jip = 0;
        };
    };

    class Commands
    {
        mode = 1;
        jip = 0;
    };
};

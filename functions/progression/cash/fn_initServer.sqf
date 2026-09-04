/*
    File: fn_initServer.sqf
    Author: Legend
    Description: Initializes server-owned session cash configuration.
    Execution: Server
    Parameters: None
    Returns: None
    Public: Yes
*/

if (!isServer) exitWith {};

private _economyCfg = missionConfigFile >> "CfgBnKothScoring" >> "economy";
private _readNonNegative = {
    params ["_name", "_fallback"];
    private _entry = _economyCfg >> _name;
    private _value = if (isNumber _entry) then {getNumber _entry} else {_fallback};
    _value max 0
};

missionNamespace setVariable ["BN_KOTH_startingCash", ["startingCash", 1000] call _readNonNegative];
missionNamespace setVariable ["BN_KOTH_cashPerKill", ["cashPerKill", 50] call _readNonNegative];
missionNamespace setVariable ["BN_KOTH_cashPerControlTick", ["cashPerControlTick", 10] call _readNonNegative];
missionNamespace setVariable ["BN_KOTH_cashPerPriorityTick", ["cashPerPriorityTick", 20] call _readNonNegative];

["Session cash economy initialized", "INFO"] call bn_koth_fnc_common_log;

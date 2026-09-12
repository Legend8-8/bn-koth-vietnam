/*
    File: fn_clearReviveRewardCycle.sqf
    Author: Legend
    Description: Clears server-owned revive reward state from one player representation.
    Execution: Server
    Parameters:
        0: Player representation <OBJECT>
        1: Cleanup reason <STRING>
    Returns: True when a representation was supplied <BOOL>
    Public: No
*/

params [
    ["_unit", objNull, [objNull]],
    ["_reason", "UNSPECIFIED", [""]]
];

if (!isServer) exitWith {false};
if (isNull _unit) exitWith {false};

private _cycle = _unit getVariable ["BN_KOTH_reviveRewardCycleServer", createHashMap];
if (_cycle isEqualType createHashMap && {(count _cycle) > 0}) then {
    [format [
        "Revive reward cycle cleared target=%1 token=%2 reason=%3",
        _cycle getOrDefault ["casualtyUid", ""],
        _cycle getOrDefault ["token", ""],
        _reason
    ], "INFO"] call bn_koth_fnc_common_log;
};

_unit setVariable ["BN_KOTH_reviveRewardCycleServer", nil, false];
true

/*
    File: fn_selectControlledUnit.sqf
    Author: Legend
    Description: Performs local player-unit handoff to a server-selected representation.
    Execution: Client
    Parameters:
        0: Target unit <OBJECT>
    Returns:
        True when switched or already on target, otherwise false <BOOL>
    Public: Yes
*/

params ["_targetUnit"];

if (!hasInterface) exitWith {false};
if (isNull _targetUnit) exitWith {
    diag_log "[BN_KOTH][WARN] ui_selectControlledUnit rejected null target unit";
    false
};

if (player isEqualTo _targetUnit) exitWith {true};

diag_log format ["[BN_KOTH][INFO] ui_selectControlledUnit switching from %1 to %2", typeOf player, typeOf _targetUnit];

selectPlayer _targetUnit;

diag_log format ["[BN_KOTH][INFO] ui_selectControlledUnit result switched=%1 current=%2", player isEqualTo _targetUnit, typeOf player];

player isEqualTo _targetUnit

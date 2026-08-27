/*
    File: fn_selectControlledUnit.sqf
    Author: Legend
    Edited: Mongo
    Description: Performs local player-unit handoff to a server-selected representation,
        then reports the observed local outcome back to the server so the transfer
        contract can commit only on a confirmed handoff rather than inferred locality.
    Execution: Client
    Parameters:
        0: Target unit <OBJECT>
        1: Server-issued transfer token (optional) <STRING>
    Returns:
        True when switched or already on target, otherwise false <BOOL>
    Public: Yes
*/

params ["_targetUnit", ["_token", "", [""]]];

if (!hasInterface) exitWith {false};

private _reportAck = {
    params ["_targetUnit", "_token", "_confirmed"];
    if (_token isEqualTo "") exitWith {};
    [_token, _targetUnit, _confirmed] remoteExecCall ["bn_koth_fnc_teams_receiveTransferHandoffAck", 2];
};

if (isNull _targetUnit) exitWith {
    diag_log "[BN_KOTH][WARN] ui_selectControlledUnit rejected null target unit";
    [_targetUnit, _token, false] call _reportAck;
    false
};

if (player isEqualTo _targetUnit) exitWith {
    [] call bn_koth_fnc_respawn_initPlayerLocal;
    [] call bn_koth_fnc_loadouts_initPlayerLocal;
    [] call bn_koth_fnc_escMenu_initPlayerLocal;
    [_targetUnit, _token, true] call _reportAck;
    true
};

diag_log format [
    "[BN_KOTH][INFO] ui_selectControlledUnit switching from %1 to %2",
    typeOf player,
    typeOf _targetUnit
];

selectPlayer _targetUnit;

private _switched = player isEqualTo _targetUnit;
diag_log format [
    "[BN_KOTH][INFO] ui_selectControlledUnit result switched=%1 current=%2",
    _switched,
    typeOf player
];

if (_switched) then {
    [] call bn_koth_fnc_respawn_initPlayerLocal;
    [] call bn_koth_fnc_loadouts_initPlayerLocal;
    [] call bn_koth_fnc_escMenu_initPlayerLocal;
    [] call bn_koth_fnc_ui_updateLobbyBlackout;
    [] call bn_koth_fnc_ui_evaluateStateReadiness;
    [] call bn_koth_fnc_ui_updateLobbyRepresentationContainment;
};

[_targetUnit, _token, _switched] call _reportAck;

_switched

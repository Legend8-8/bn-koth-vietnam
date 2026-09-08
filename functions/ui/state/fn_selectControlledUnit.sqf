/*
    File: fn_selectControlledUnit.sqf
    Author: Legend
    Edited: Mongo
    Description: Performs local player-unit handoff to a server-selected representation,
        then reports the observed local outcome back to the server so the transfer contract
        can commit only on a confirmed handoff rather than inferred locality.
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
    diag_log format [
        "[BN_KOTH][INFO] ui_selectControlledUnit result playerMatches=true localAtHandoff=%1 lifeState=%2 vnIncap=%3 current=%4 target=%5",
        local _targetUnit,
        lifeState _targetUnit,
        _targetUnit getVariable ["vn_revive_incapacitated", false],
        typeOf player,
        typeOf _targetUnit
    ];
    [] call bn_koth_fnc_respawn_initPlayerLocal;
    [] call bn_koth_fnc_loadouts_initPlayerLocal;
    [] call bn_koth_fnc_escMenu_initPlayerLocal;
    [_targetUnit, _token, true] call _reportAck;
    true
};

diag_log format [
    "[BN_KOTH][INFO] ui_selectControlledUnit switching from %1 to %2 targetLifeState=%3 targetVnIncap=%4",
    typeOf player,
    typeOf _targetUnit,
    lifeState _targetUnit,
    _targetUnit getVariable ["vn_revive_incapacitated", false]
];

private _enteringLobby = (side group _targetUnit) isEqualTo civilian;
if (_enteringLobby) then {
    [true] call bn_koth_fnc_ui_updateLobbyBlackout;
};

[true] call bn_koth_fnc_respawn_updateDownedPresentation;
selectPlayer _targetUnit;

private _switched = player isEqualTo _targetUnit;
diag_log format [
    "[BN_KOTH][INFO] ui_selectControlledUnit result playerMatches=%1 localAtHandoff=%2 lifeState=%3 vnIncap=%4 current=%5 target=%6",
    _switched,
    local _targetUnit,
    lifeState _targetUnit,
    _targetUnit getVariable ["vn_revive_incapacitated", false],
    typeOf player,
    typeOf _targetUnit
];

if (_switched) then {
    [] call bn_koth_fnc_respawn_updateDownedPresentation;
    [] call bn_koth_fnc_respawn_initPlayerLocal;
    [] call bn_koth_fnc_loadouts_initPlayerLocal;
    [] call bn_koth_fnc_escMenu_initPlayerLocal;
    [_enteringLobby] call bn_koth_fnc_ui_updateLobbyBlackout;
    [] call bn_koth_fnc_ui_evaluateStateReadiness;
    [] call bn_koth_fnc_ui_updateLobbyRepresentationContainment;
} else {
    if (_enteringLobby) then {
        [] call bn_koth_fnc_ui_updateLobbyBlackout;
    };
};

[_targetUnit, _token, _switched] call _reportAck;

_switched

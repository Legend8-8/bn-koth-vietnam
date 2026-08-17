/*
    File: fn_initTeleport.sqf
    Author: tylervip
    Description: Adds mapboard actions that request teleport into command vehicle.
    Execution: Client
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!hasInterface) exitWith {};

if (missionNamespace getVariable ["BN_KOTH_commandBoardActionLoopRunning", false]) exitWith {};
missionNamespace setVariable ["BN_KOTH_commandBoardActionLoopRunning", true];

private _resolveBoardTarget = {
    params ["_boardRef"];

    if (_boardRef isEqualTo "") exitWith {objNull};

    private _boardObj = missionNamespace getVariable [_boardRef, objNull];
    if (!isNull _boardObj) exitWith {_boardObj};

    if ((markerShape _boardRef) isEqualTo "") exitWith {objNull};

    private _markerPos = markerPos _boardRef;
    private _candidates = nearestObjects [_markerPos, ["Static", "Thing", "House", "LandVehicle"], 8];
    if (_candidates isEqualTo []) exitWith {objNull};

    _candidates = [_candidates, [], {_markerPos distance2D _x}, "ASCEND"] call BIS_fnc_sortBy;
    _candidates select 0
};

[_resolveBoardTarget] spawn {
    params ["_resolveBoardTarget"];

    while {hasInterface} do {
        private _defs = missionNamespace getVariable ["BN_KOTH_commandBoardDefs", []];

        {
            _x params ["_sideToken", "_boardRef"];
            if (_boardRef isEqualTo "") then {continue};

            private _side = switch (_sideToken) do {
                case "WEST": {west};
                case "EAST": {east};
                default {sideUnknown};
            };

            if (_side isEqualTo sideUnknown) then {continue};

            private _board = [_boardRef] call _resolveBoardTarget;
            if (isNull _board) then {continue};

            private _actionKey = format ["BN_KOTH_commandBoardAction_%1", _sideToken];
            if (_board getVariable [_actionKey, -1] >= 0) then {continue};

            private _actionId = _board addAction [
                "Teleport to Command Vehicle",
                {
                    params ["_target", "_caller", "_actionId", "_args"];
                    _args params ["_sideToken"];

                    [_sideToken] remoteExecCall ["bn_koth_fnc_vehicles_mobileRespawn_requestTeleport", 2];
                },
                [_sideToken],
                1.5,
                false,
                true,
                "",
                format ["alive _target && {_this distance _target < 5} && {(side _this) isEqualTo %1}", _side]
            ];

            _board setVariable [_actionKey, _actionId, false];

            private _menuActionKey = format ["BN_KOTH_commandBoardMenuAction_%1", _sideToken];
            if (_board getVariable [_menuActionKey, -1] < 0) then {
                private _menuActionId = _board addAction [
                    "Open Menu",
                    {
                        [] call bn_koth_fnc_menu_open;
                    },
                    nil,
                    1.5,
                    false,
                    true,
                    "",
                    "alive _target && {_this distance _target < 5}"
                ];

                _board setVariable [_menuActionKey, _menuActionId, false];
            };
        } forEach _defs;

        sleep 2;
    };
};

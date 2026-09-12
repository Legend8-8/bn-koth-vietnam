/*
    File: fn_initTeleport.sqf
    Author: tylervip
    Edited: Legend
    Description: Adds active team mapboard actions for the deployed menu, command teleport, and air insertion.
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

private _mapboardAccessDistance = (getNumber (missionConfigFile >> "CfgBnKothInteractions" >> "teamMapboardAccessDistance")) max 1;
private _resolveBoardTarget = {
    params ["_boardRef", "_mapboardAccessDistance"];

    if (_boardRef isEqualTo "") exitWith {objNull};

    private _boardObj = missionNamespace getVariable [_boardRef, objNull];
    if (!isNull _boardObj) exitWith {_boardObj};

    if ((markerShape _boardRef) isEqualTo "") exitWith {objNull};

    private _markerPos = markerPos _boardRef;
    private _candidates = nearestObjects [_markerPos, ["Static", "Thing", "House", "LandVehicle"], _mapboardAccessDistance];
    if (_candidates isEqualTo []) exitWith {objNull};

    _candidates = [_candidates, [], {_markerPos distance2D _x}, "ASCEND"] call BIS_fnc_sortBy;
    _candidates select 0
};

[_resolveBoardTarget, _mapboardAccessDistance] spawn {
    params ["_resolveBoardTarget", "_mapboardAccessDistance"];

    while {hasInterface} do {
        private _defs = missionNamespace getVariable ["BN_KOTH_commandBoardDefs", []];
        private _desired = createHashMap;
        {
            _x params ["_sideToken", "_boardRef", ["_teleportEnabled", true, [true]]];
            _desired set [_sideToken, [_boardRef, _teleportEnabled]];
        } forEach _defs;

        private _bindings = uiNamespace getVariable ["BN_KOTH_commandTeleportActionBindings", createHashMap];
        if !(_bindings isEqualType createHashMap) then {_bindings = createHashMap};
        {
            private _sideToken = _x;
            private _binding = _bindings getOrDefault [_sideToken, createHashMap];
            private _desiredState = _desired getOrDefault [_sideToken, ["", false]];
            private _boundBoard = _binding getOrDefault ["board", objNull];
            private _boundRef = _binding getOrDefault ["ref", ""];
            private _actionId = _binding getOrDefault ["actionId", -1];
            if (!(_desiredState select 1) || {!(_boundRef isEqualTo (_desiredState select 0))}) then {
                if (!isNull _boundBoard && {_actionId >= 0}) then {
                    _boundBoard removeAction _actionId;
                    _boundBoard setVariable [format ["BN_KOTH_commandBoardAction_%1", _sideToken], -1, false];
                };
                _bindings deleteAt _sideToken;
            };
        } forEach +(keys _bindings);

        {
            _x params ["_sideToken", "_boardRef", ["_teleportEnabled", true, [true]]];
            if (_boardRef isEqualTo "") then {continue};

            private _side = switch (_sideToken) do {
                case "WEST": {west};
                case "EAST": {east};
                default {sideUnknown};
            };

            if (_side isEqualTo sideUnknown) then {continue};

            private _board = [_boardRef, _mapboardAccessDistance] call _resolveBoardTarget;
            if (isNull _board) then {continue};

            private _actionKey = format ["BN_KOTH_commandBoardAction_%1", _sideToken];
            if (_teleportEnabled && {_board getVariable [_actionKey, -1] < 0}) then {
                private _actionId = _board addAction [
                    "Teleport to Command Vehicle",
                    {
                        params ["_target", "_caller", "_actionId", "_args"];
                        _args params ["_sideToken"];
                        [_sideToken] remoteExecCall ["bn_koth_fnc_vehicles_mobileRespawn_requestTeleport", 2];
                    },
                    [_sideToken], 1.5, false, true, "",
                    format ["alive _target && {_this distance _target < 5} && {(side _this) isEqualTo %1}", _side]
                ];
                _board setVariable [_actionKey, _actionId, false];
                _bindings set [_sideToken, createHashMapFromArray [
                    ["board", _board], ["ref", _boardRef], ["actionId", _actionId]
                ]];
            };

            private _menuActionKey = format ["BN_KOTH_commandBoardMenuAction_%1", _sideToken];
            if (_board getVariable [_menuActionKey, -1] < 0) then {
                private _menuActionId = _board addAction [
                    "Open Menu",
                    {
                        params ["_target"];
                        [true, _target] call bn_koth_fnc_menu_open;
                    },
                    nil,
                    1.5,
                    false,
                    true,
                    "",
                    format ["alive _target && {_this distance _target < 5} && {(side _this) isEqualTo %1}", _side]
                ];

                _board setVariable [_menuActionKey, _menuActionId, false];
            };

            private _insertionCfg = missionConfigFile >> "CfgBnKothAirInsertion";
            if (isClass _insertionCfg && {(getNumber (_insertionCfg >> "enabled")) > 0}) then {
                private _insertionCost = (getNumber (_insertionCfg >> "cost")) max 1;
                {
                    _x params ["_mode", "_label"];
                    private _key = format ["BN_KOTH_airInsertionBoardAction_%1_%2", _sideToken, _mode];
                    if (_board getVariable [_key, -1] < 0) then {
                        private _actionId = _board addAction [
                            format ["AIR INSERTION — %1 — $%2", _label, _insertionCost],
                            {
                                params ["_target", "_caller", "_actionId", "_args"];
                                [_args select 0, ""] remoteExecCall ["bn_koth_fnc_airInsertion_request", 2];
                            },
                            [_mode], 1.5, false, true, "",
                            format ["alive _target && {_this distance _target < 5} && {(side _this) isEqualTo %1}", _side]
                        ];
                        _board setVariable [_key, _actionId, false];
                    };
                } forEach [["START_SOLO", "SOLO"], ["START_GROUP", "GROUP"]];
            };
        } forEach _defs;

        uiNamespace setVariable ["BN_KOTH_commandTeleportActionBindings", _bindings];

        sleep 2;
    };
};

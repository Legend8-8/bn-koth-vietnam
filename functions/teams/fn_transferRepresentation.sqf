/*
    File: fn_transferRepresentation.sqf
    Author: Legend
    Description: Transfers a connected human to a server-selected representation unit.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Target unit <OBJECT>
        2: Target logical state <STRING>
        3: Delete previous unit on success <BOOL>
    Returns:
        True on successful ownership handoff, otherwise false <BOOL>
    Public: Yes
*/

params ["_uid", "_targetUnit", ["_targetState", "LOBBY", [""]], ["_deletePrevious", true, [true]]];

if (!isServer) exitWith {false};
if (_uid isEqualTo "") exitWith {false};
if (isNull _targetUnit) exitWith {false};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {false};

private _ownerId = _record getOrDefault ["ownerId", -1];
if (_ownerId <= 0) exitWith {false};

private _oldUnit = _record getOrDefault ["currentUnit", objNull];
if (isNull _oldUnit) then {
    _oldUnit = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
};

[format ["transferRepresentation dispatch uid=%1 owner=%2 target=%3 state=%4", _uid, _ownerId, typeOf _targetUnit, _targetState], "INFO"] call bn_koth_fnc_common_log;
[_targetUnit] remoteExecCall ["bn_koth_fnc_ui_selectControlledUnit", _ownerId];

private _deadline = serverTime + 5;
waitUntil {
    (serverTime >= _deadline)
    || {(owner _targetUnit) isEqualTo _ownerId}
};

if (!isNull _targetUnit && {(owner _targetUnit) isEqualTo _ownerId}) exitWith {
    [format ["Representation handoff success for UID %1 to unit %2 owner=%3", _uid, _targetUnit, owner _targetUnit], "INFO"] call bn_koth_fnc_common_log;

    if (_deletePrevious && {!isNull _oldUnit} && {!(_oldUnit isEqualTo _targetUnit)} && {!isPlayer _oldUnit}) then {
        private _oldGroup = group _oldUnit;
        deleteVehicle _oldUnit;

        if (!isNull _oldGroup && {(count units _oldGroup) isEqualTo 0}) then {
            deleteGroup _oldGroup;
        };
    };

    _record set ["currentUnit", _targetUnit];
    _record set ["state", _targetState];
    _records set [_uid, _record];
    missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

    [_targetUnit, _uid] call bn_koth_fnc_curator_init;
    [_targetUnit] remoteExecCall ["bn_koth_fnc_playerMapIcons_initPlayerLocal", _ownerId];
    [_targetUnit] remoteExecCall ["bn_koth_fnc_player3DIcons_initPlayerLocal", _ownerId];
    [_targetUnit] remoteExecCall ["bn_koth_fnc_escMenu_initPlayerLocal", _ownerId];

    true
};

if (serverTime >= _deadline) exitWith {
    [format ["Representation handoff failed for UID %1 to unit %2 owner=%3", _uid, _targetUnit, owner _targetUnit], "ERROR"] call bn_koth_fnc_common_log;
    false
};

[format ["Representation handoff failed for UID %1 to unit %2 owner=%3", _uid, _targetUnit, owner _targetUnit], "ERROR"] call bn_koth_fnc_common_log;
false

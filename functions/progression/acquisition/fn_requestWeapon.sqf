/*
    File: fn_requestWeapon.sqf
    Author: Legend
    Description: Accepts one client weapon acquisition intent, derives the
        authoritative caller, delegates to the existing transaction owner,
        and returns the structured result only to that requester.
    Execution: Client/Server
    Parameters:
        0: Operation token (PURCHASE or RENT) <STRING>
        1: Canonical weapon classname <STRING>
    Returns: None
    Public: Yes
*/

params [
    ["_operation", "", [""]],
    ["_weaponClass", "", [""]]
];

if (hasInterface && {!isServer}) exitWith {
    [_operation, _weaponClass] remoteExecCall ["bn_koth_fnc_progression_requestWeaponAcquisition", 2];
};
if (hasInterface && {isServer} && {remoteExecutedOwner <= 0}) exitWith {
    [_operation, _weaponClass] remoteExecCall ["bn_koth_fnc_progression_requestWeaponAcquisition", 2];
};
if (!isServer) exitWith {};

private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {
    ["Rejected Store acquisition request without valid remoteExecutedOwner.", "WARN"] call bn_koth_fnc_common_log;
};

private _rejectRequest = {
    params ["_code", "_message"];
    private _result = createHashMapFromArray [
        ["success", false], ["code", _code], ["message", _message],
        ["operation", toUpper _operation], ["requestedClass", toLower _weaponClass],
        ["committed", false], ["charged", 0]
    ];
    [_result] remoteExecCall ["bn_koth_fnc_ui_receiveWeaponAcquisitionResult", _ownerId];
    _result
};

private _playerObj = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _playerObj) exitWith {
    [format ["Rejected Store acquisition request: no player for owner %1.", _ownerId], "WARN"] call bn_koth_fnc_common_log;
    ["PLAYER_NOT_REGISTERED", "Store player state is not ready."] call _rejectRequest;
};

private _uid = getPlayerUID _playerObj;
if (_uid isEqualTo "") exitWith {
    [format ["Rejected Store acquisition request: owner %1 has no UID.", _ownerId], "WARN"] call bn_koth_fnc_common_log;
    ["INVALID_UID", "Store player identity is not ready."] call _rejectRequest;
};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {
    [format ["Rejected Store acquisition request: player records unavailable for owner %1.", _ownerId], "WARN"] call bn_koth_fnc_common_log;
    ["PLAYER_RECORDS_UNAVAILABLE", "Store player records are not ready."] call _rejectRequest;
};
if (isNil {_records get _uid}) exitWith {
    [format ["Rejected Store acquisition request: UID %1 is not registered.", _uid], "WARN"] call bn_koth_fnc_common_log;
    ["PLAYER_NOT_REGISTERED", "Store player state is not ready."] call _rejectRequest;
};
private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {
    [format ["Rejected Store acquisition request: UID %1 is not registered.", _uid], "WARN"] call bn_koth_fnc_common_log;
    ["PLAYER_NOT_REGISTERED", "Store player state is not ready."] call _rejectRequest;
};

private _now = serverTime;
private _lastRequestAt = _record getOrDefault ["lastWeaponAcquisitionRequestAt", -999];
if ((_now - _lastRequestAt) < 0.25) exitWith {
    [format ["Throttled rapid Store acquisition request from UID %1.", _uid], "WARN"] call bn_koth_fnc_common_log;
    ["REQUEST_THROTTLED", "Store request was sent too quickly."] call _rejectRequest;
};
_record set ["lastWeaponAcquisitionRequestAt", _now];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

private _normalizedOperation = toUpper _operation;
private _result = switch (_normalizedOperation) do {
    case "PURCHASE": {[_uid, _weaponClass] call bn_koth_fnc_progression_purchaseWeapon};
    case "RENT": {[_uid, _weaponClass] call bn_koth_fnc_progression_rentWeapon};
    default {
        createHashMapFromArray [
            ["success", false], ["code", "INVALID_OPERATION"],
            ["message", "Weapon acquisition operation is invalid."],
            ["operation", _normalizedOperation], ["requestedClass", toLower _weaponClass],
            ["committed", false], ["charged", 0]
        ]
    };
};

[_result] remoteExecCall ["bn_koth_fnc_ui_receiveWeaponAcquisitionResult", _ownerId];

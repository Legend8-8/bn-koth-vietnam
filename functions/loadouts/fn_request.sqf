/*
    File: fn_request.sqf
    Author: Legend
    Description: Accepts client loadout intent, resolves the authoritative caller, validates it on the server, and returns only the validated payload to that player's machine.
    Execution: Client/Server
    Parameters:
        0: Loadout request <HASHMAP|ARRAY>
    Returns:
        None
    Public: Yes
*/

params [
    ["_request", createHashMap, [createHashMap, []]]
];

// Client entry point: send intent only. Never send a player object or side as authority.
if (hasInterface && {!isServer}) exitWith {
    [_request] remoteExecCall ["bn_koth_fnc_loadouts_request", 2];
};

// Hosted-server player entry point: force the same remote-exec path so
// remoteExecutedOwner is authoritative exactly as it will be on dedicated.
if (hasInterface && {isServer} && {remoteExecutedOwner <= 0}) exitWith {
    [_request] remoteExecCall ["bn_koth_fnc_loadouts_request", 2];
};

if (!isServer) exitWith {};

private _ownerId = remoteExecutedOwner;
if (_ownerId <= 0) exitWith {
    ["Rejected loadout request without valid remoteExecutedOwner.", "WARN"] call bn_koth_fnc_common_log;
};

private _playerObj = [_ownerId] call bn_koth_fnc_teams_getPlayerByOwner;
if (isNull _playerObj) exitWith {
    [format ["Rejected loadout request: no connected player for owner %1.", _ownerId], "WARN"] call bn_koth_fnc_common_log;
};

private _uid = getPlayerUID _playerObj;
if (_uid isEqualTo "") exitWith {
    [format ["Rejected loadout request: resolved owner %1 has no UID.", _ownerId], "WARN"] call bn_koth_fnc_common_log;
};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_records isEqualType createHashMap) exitWith {
    [format ["Rejected loadout request for UID %1: player records unavailable.", _uid], "WARN"] call bn_koth_fnc_common_log;
};

private _record = _records getOrDefault [_uid, createHashMap];
if !(_record isEqualType createHashMap) exitWith {
    [format ["Rejected loadout request for UID %1: player not registered.", _uid], "WARN"] call bn_koth_fnc_common_log;
};

// Narrow server-side anti-spam guard. This is request hygiene, not gameplay entitlement.
private _now = serverTime;
private _lastRequestAt = _record getOrDefault ["lastLoadoutRequestAt", -999];
if ((_now - _lastRequestAt) < 0.25) exitWith {
    [format ["Throttled rapid loadout request from UID %1.", _uid], "WARN"] call bn_koth_fnc_common_log;
};

_record set ["lastLoadoutRequestAt", _now];
_records set [_uid, _record];
missionNamespace setVariable ["BN_KOTH_playerRecords", _records];

private _validation = [
    _playerObj,
    _request
] call bn_koth_fnc_loadouts_validateLoadout;

if !(_validation getOrDefault ["success", false]) exitWith {
    [
        format [
            "Rejected loadout request UID=%1 code=%2 message=%3",
            _uid,
            _validation getOrDefault ["code", "ERR_VALIDATION"],
            _validation getOrDefault ["message", "Loadout validation failed."]
        ],
        "WARN"
    ] call bn_koth_fnc_common_log;

    [
        createHashMapFromArray [
            ["success", false],
            ["code", _validation getOrDefault ["code", "ERR_VALIDATION"]],
            ["message", _validation getOrDefault ["message", "Loadout validation failed."]],
            ["loadoutId", _validation getOrDefault ["loadoutId", ""]]
        ]
    ] remoteExecCall ["bn_koth_fnc_loadouts_receiveValidatedLoadout", _ownerId];
};

private _validatedLoadout = _validation getOrDefault ["validatedLoadout", []];
if !(_validatedLoadout isEqualType [] && {(count _validatedLoadout) > 0}) exitWith {
    [format ["Rejected validated loadout for UID %1: validator returned no complete loadout.", _uid], "WARN"] call bn_koth_fnc_common_log;
};

private _loadoutStateByUid = missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap];
if !(_loadoutStateByUid isEqualType createHashMap) then {
    _loadoutStateByUid = createHashMap;
};

_loadoutStateByUid set [_uid, createHashMapFromArray [
    ["intendedLoadout", +_validatedLoadout],
    ["sideToken", toUpper (_validation getOrDefault ["sideToken", ""])]
]];

missionNamespace setVariable ["BN_KOTH_playerLoadoutState", _loadoutStateByUid];

[
    format [
        "Accepted loadout request UID=%1 loadoutId=%2",
        _uid,
        _validation getOrDefault ["loadoutId", ""]
    ],
    "INFO"
] call bn_koth_fnc_common_log;

// The client receiver only accepts packets that originate from the server.
// It then applies through the existing single local application path.
[_validation] remoteExecCall ["bn_koth_fnc_loadouts_receiveValidatedLoadout", _ownerId];

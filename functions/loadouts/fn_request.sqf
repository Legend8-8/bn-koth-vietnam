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
    if (_request isEqualType createHashMap) then {
        _request set ["arsenalBoardNetId", uiNamespace getVariable ["BN_KOTH_menuArsenalBoardNetId", ""]];
    };
    [_request] remoteExecCall ["bn_koth_fnc_loadouts_request", 2];
};

// Hosted-server player entry point: force the same remote-exec path so
// remoteExecutedOwner is authoritative exactly as it will be on dedicated.
if (hasInterface && {isServer} && {remoteExecutedOwner <= 0}) exitWith {
    if (_request isEqualType createHashMap) then {
        _request set ["arsenalBoardNetId", uiNamespace getVariable ["BN_KOTH_menuArsenalBoardNetId", ""]];
    };
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

// Every operation capable of changing or storing loadout state requires
// authoritative access at the player's active team mapboard. The client-side
// menu capability flag is presentation only and is never trusted here.
private _requiresArsenalAccess = true;

// Snapshot intent contains no client inventory. The server reads the player
// object and returns that observation without applying equipment.
if (_request isEqualType createHashMap) then {
    private _mutation = _request getOrDefault ["mutation", createHashMap];
    if (_mutation isEqualType createHashMap) then {
        _requiresArsenalAccess = !((toLower (_mutation getOrDefault ["op", ""])) isEqualTo "snapshot");
    };
};

private _arsenalBoardNetId = if (_request isEqualType createHashMap) then {_request getOrDefault ["arsenalBoardNetId", ""]} else {""};
if (_request isEqualType createHashMap) then {_request deleteAt "arsenalBoardNetId";};

private _arsenalAccessFailure = "";

if (_requiresArsenalAccess) then {
    if (!alive _playerObj) then {
        _arsenalAccessFailure = "player_not_alive";
    };

    private _deployed = _record getOrDefault ["deployed", false];
    private _playerState = _record getOrDefault ["state", ""];

    if ((_arsenalAccessFailure isEqualTo "") && {!_deployed || {!(_playerState isEqualTo "ACTIVE")}}) then {
        _arsenalAccessFailure = "player_not_deployed_active";
    };

    private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];

    if ((_arsenalAccessFailure isEqualTo "") && {!([_assignedSide] call bn_koth_fnc_teams_validateSide)}) then {
        _arsenalAccessFailure = "invalid_assigned_side";
    };

    private _activeLocationId = "";
    private _activeCfg = configNull;
    private _boardRef = "";
    private _boardTarget = objNull;

    if (_arsenalAccessFailure isEqualTo "") then {
        _activeLocationId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
        _activeCfg = missionConfigFile >> "CfgBnKothLocations" >> _activeLocationId;

        if !(isClass _activeCfg) then {
            _arsenalAccessFailure = "active_location_unavailable";
        };
    };

    if (_arsenalAccessFailure isEqualTo "") then {
        _boardRef = switch (_assignedSide) do {
            case west: {getText (_activeCfg >> "westCommand_mapboard")};
            case east: {getText (_activeCfg >> "eastCommand_mapboard")};
            default {""};
        };

        if (_boardRef isEqualTo "") then {
            _arsenalAccessFailure = "team_mapboard_unconfigured";
        };
    };

    if (_arsenalAccessFailure isEqualTo "") then {
        if (_arsenalBoardNetId isEqualType "" && {!(_arsenalBoardNetId isEqualTo "")}) then {
            _boardTarget = objectFromNetId _arsenalBoardNetId;
        };

        private _configuredBoard = missionNamespace getVariable [_boardRef, objNull];
        if (!isNull _boardTarget && {!isNull _configuredBoard} && {!(_boardTarget isEqualTo _configuredBoard)}) then {
            _boardTarget = objNull;
        };

        if (!isNull _boardTarget && {!((markerShape _boardRef) isEqualTo "")} && {(_boardTarget distance2D (markerPos _boardRef)) > 8}) then {
            _boardTarget = objNull;
        };

        if (isNull _boardTarget) then {_boardTarget = _configuredBoard;};

        if (isNull _boardTarget && {!((markerShape _boardRef) isEqualTo "")}) then {
            private _boardPos = markerPos _boardRef;
            private _boardCandidates = nearestObjects [
                _boardPos,
                ["Static", "Thing", "House", "LandVehicle"],
                8
            ];

            if !(_boardCandidates isEqualTo []) then {
                _boardCandidates = [
                    _boardCandidates,
                    [],
                    {_boardPos distance2D _x},
                    "ASCEND"
                ] call BIS_fnc_sortBy;

                _boardTarget = _boardCandidates select 0;
            };
        };

        if (isNull _boardTarget) then {
            _arsenalAccessFailure = "team_mapboard_not_resolved";
        };
    };

    // addAction uses <5 m client-side. The server keeps a small tolerance for
    // movement/network timing while remaining authoritative.
    if (
        (_arsenalAccessFailure isEqualTo "") &&
        {(_playerObj distance2D _boardTarget) > 8}
    ) then {
        _arsenalAccessFailure = "player_not_at_team_mapboard";
    };
};

if !(_arsenalAccessFailure isEqualTo "") exitWith {
    [
        format [
            "Rejected arsenal request UID=%1 reason=%2",
            _uid,
            _arsenalAccessFailure
        ],
        "WARN"
    ] call bn_koth_fnc_common_log;

    [
        createHashMapFromArray [
            ["success", false],
            ["code", "ERR_ARSENAL_ACCESS"],
            ["message", "Loadout changes require access through your active team mapboard."],
            ["loadoutId", ""]
        ]
    ] remoteExecCall ["bn_koth_fnc_loadouts_receiveValidatedLoadout", _ownerId];
};

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

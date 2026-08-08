/*
    File: fn_requestState.sqf
    Author: tylervip
    Description: Client requests state; server validates caller and responds.
    Execution: Client/Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (hasInterface && {!isServer}) exitWith {
    [] remoteExec ["bn_koth_fnc_ui_requestState", 2];
};

if (hasInterface && {isServer}) exitWith {
    [player] call bn_koth_fnc_ui_sendStateToClient;
};

if (!isServer) exitWith {};

private _requestOwner = remoteExecutedOwner;
if (_requestOwner <= 0) exitWith {
    ["Rejected state request without valid remoteExecutedOwner.", "WARN"] call bn_koth_fnc_common_log;
};

private _requester = objNull;
{
    if (owner _x isEqualTo _requestOwner) exitWith {
        _requester = _x;
    };
} forEach allPlayers;

if (isNull _requester) exitWith {
    [format ["Rejected state request: no player for owner %1", _requestOwner], "WARN"] call bn_koth_fnc_common_log;
};

private _uid = getPlayerUID _requester;
if !(_uid isEqualTo "") then {
    private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
    private _record = _records getOrDefault [_uid, objNull];

    if (_record isEqualTo objNull) then {
        [format ["ui_requestState fallback: missing player record for UID=%1 owner=%2; attempting registration.", _uid, _requestOwner], "WARN"] call bn_koth_fnc_common_log;
        private _registered = [_requester] call bn_koth_fnc_teams_registerPlayer;

        if (!_registered) then {
            [format ["ui_requestState fallback registration deferred/failed UID=%1 owner=%2", _uid, _requestOwner], "WARN"] call bn_koth_fnc_common_log;
        };
    };
};

private _now = serverTime;
private _lastRequest = _requester getVariable ["BN_KOTH_lastStateRequestAt", -999];
if ((_now - _lastRequest) < 1) exitWith {
    [format ["Throttled state request from owner %1", _requestOwner], "WARN"] call bn_koth_fnc_common_log;
};

_requester setVariable ["BN_KOTH_lastStateRequestAt", _now];
[_requester] call bn_koth_fnc_ui_sendStateToClient;

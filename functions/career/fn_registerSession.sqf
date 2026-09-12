/*
    File: fn_registerSession.sqf
    Author: Legend
    Description: Upserts latest profile identity and starts connected playtime accounting for one UID.
    Execution: Server
    Public: Yes
*/
params [["_uid", "", [""]], ["_profileName", "", [""]]];
if (!isServer || {_uid isEqualTo ""}) exitWith {createHashMapFromArray [["success", false], ["code", "INVALID_IDENTITY"]]};
private _safeName = ((_profileName splitString ":") joinString " ");
private _identities = missionNamespace getVariable ["BN_KOTH_careerIdentityPending", createHashMap];
_identities set [_uid, _safeName];
missionNamespace setVariable ["BN_KOTH_careerIdentityPending", _identities];
private _query = ["upsertCareerIdentity", [_uid, _safeName]] call bn_koth_fnc_persistence_extdbCall;
if (_query getOrDefault ["success", false]) then {
    _identities deleteAt _uid;
    missionNamespace setVariable ["BN_KOTH_careerIdentityPending", _identities];
};
private _sessions = missionNamespace getVariable ["BN_KOTH_careerSessions", createHashMap];
if ((_sessions getOrDefault [_uid, -1]) < 0) then {_sessions set [_uid, serverTime]};
missionNamespace setVariable ["BN_KOTH_careerSessions", _sessions];
_query

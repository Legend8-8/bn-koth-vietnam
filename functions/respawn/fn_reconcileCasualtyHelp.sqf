/*
    File: fn_reconcileCasualtyHelp.sqf
    Author: Legend
    Description: Removes casualty help requests whose authoritative player lifecycle is no longer valid.
    Execution: Server
    Parameters:
        0: Force a client projection refresh even when state is unchanged <BOOL>
    Returns:
        True when authoritative help state changed <BOOL>
    Public: No
*/

params [["_forcePublish", false, [false]]];

if (!isServer) exitWith {false};

private _requests = missionNamespace getVariable ["BN_KOTH_casualtyHelpRequests", createHashMap];
if !(_requests isEqualType createHashMap) then {_requests = createHashMap};
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _roundActive = ([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE";
private _valid = createHashMap;

if (_roundActive && {_records isEqualType createHashMap}) then {
    {
        private _uid = _x;
        private _request = _requests get _uid;
        _request params ["_unit", "_side"];
        private _record = _records getOrDefault [_uid, createHashMap];

        if (
            _record isEqualType createHashMap
            && {!isNull _unit}
            && {alive _unit}
            && {isPlayer _unit}
            && {[_side] call bn_koth_fnc_teams_validateSide}
            && {(_record getOrDefault ["assignedSide", sideUnknown]) isEqualTo _side}
            && {(_record getOrDefault ["state", ""]) isEqualTo "ACTIVE"}
            && {_record getOrDefault ["deployed", false]}
            && {(_record getOrDefault ["currentUnit", objNull]) isEqualTo _unit}
            && {[_unit] call bn_koth_fnc_respawn_isIncapacitated}
        ) then {
            _valid set [_uid, _request];
        };
    } forEach (keys _requests);
};

private _changed = (count _valid) isNotEqualTo (count _requests);
if (!_changed) then {
    {
        private _before = _requests getOrDefault [_x, []];
        private _after = _valid getOrDefault [_x, []];
        if !(_before isEqualTo _after) exitWith {_changed = true};
    } forEach (keys _requests);
};
missionNamespace setVariable ["BN_KOTH_casualtyHelpRequests", _valid];

if (_changed || {_forcePublish}) then {
    [] call bn_koth_fnc_respawn_publishCasualtyHelpState;
};

_changed

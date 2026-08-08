/*
    File: fn_publishState.sqf
    Author: Legend
    Description: Publishes replicated team/lobby/player state from authoritative records.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
if ((count _playableSides) < 2) then {
    _playableSides = [west, east];
};

private _stateMap = createHashMap;
private _assignmentMap = createHashMap;
private _countsMap = createHashMapFromArray [[_playableSides select 0, 0], [_playableSides select 1, 0]];

{
    private _uid = _x;
    private _record = _records get _uid;

    if (_record isEqualType createHashMap) then {
        private _state = _record getOrDefault ["state", "LOBBY"];
        private _assignedSide = _record getOrDefault ["assignedSide", sideUnknown];

        _stateMap set [_uid, _state];
        _assignmentMap set [_uid, _assignedSide];

        if (_assignedSide in _playableSides) then {
            private _currentCount = _countsMap getOrDefault [_assignedSide, 0];
            _countsMap set [_assignedSide, _currentCount + 1];
        };
    };
} forEach (keys _records);

["BN_KOTH_playerStates", _stateMap] call bn_koth_fnc_common_publicState;
["BN_KOTH_playerTeamAssignments", _assignmentMap] call bn_koth_fnc_common_publicState;
["BN_KOTH_teamCounts", _countsMap] call bn_koth_fnc_common_publicState;

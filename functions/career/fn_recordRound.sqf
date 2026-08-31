/* File: fn_recordRound.sqf | Author: Legend | Description: Records one authoritative completed-round result for its participant snapshot. | Execution: Server | Public: No */
params [["_winningSide", sideUnknown, [sideUnknown]]];
if (!isServer || {!([_winningSide] call bn_koth_fnc_teams_validateSide)}) exitWith {0};
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _participants = +(missionNamespace getVariable ["BN_KOTH_activeParticipants", []]);
private _count = 0;
{
    private _record = _records getOrDefault [_x, createHashMap];
    if (_record isEqualType createHashMap) then {
        private _won = if ((_record getOrDefault ["assignedSide", sideUnknown]) isEqualTo _winningSide) then {1} else {0};
        [_x, createHashMapFromArray [["roundsPlayed", 1], ["wins", _won]], "round_complete"] call bn_koth_fnc_career_mutate;
        _count = _count + 1;
    };
} forEach _participants;
_count

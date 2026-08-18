/*
    File: fn_cleanupRuntimeObjects.sqf
    Author: tylervip
    Description: Removes runtime AO debris that should not persist across location changes, including mines and dead bodies.
    Execution: Server
    Parameters:
        None
    Returns:
        Number of runtime objects deleted <NUMBER>
    Public: Yes
*/

if (!isServer) exitWith {0};

private _candidates = [];
{
    _candidates pushBackUnique _x;
} forEach (allMissionObjects "MineBase");
{
    _candidates pushBackUnique _x;
} forEach (allMissionObjects "UnderwaterMine");
{
    _candidates pushBackUnique _x;
} forEach (allMissionObjects "TimeBombCore");
{
    _candidates pushBackUnique _x;
} forEach allDeadMen;

private _deletedCount = 0;
{
    private _obj = _x;
    if (isNull _obj) then {continue};

    if ((_obj isKindOf "Man") && {alive _obj}) then {continue};

    if ((_obj isKindOf "MineBase") || {_obj isKindOf "UnderwaterMine"} || {(typeOf _obj) isEqualTo "TimeBombCore"}) then {
        deleteVehicle _obj;
        _deletedCount = _deletedCount + 1;
        continue;
    };

    if ((_obj isKindOf "Man") && {!alive _obj}) then {
        deleteVehicle _obj;
        _deletedCount = _deletedCount + 1;
    };
} forEach _candidates;

_deletedCount

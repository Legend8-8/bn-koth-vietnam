/*
    File: fn_resetRound.sqf
    Author: Tylervip
    Description: Resets all connected players to level one and zero XP.
    Execution: Server
    Parameters:
        None
    Returns:
        None
    Public: Yes
*/

if (!isServer) exitWith {};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if (_records isEqualType createHashMap) then {
    {
        private _record = _records get _x;
        if (_record isEqualType createHashMap) then {
            _record set ["xp", 0];
            _record set ["level", 1];
            _records set [_x, _record];
        };
    } forEach (keys _records);
    missionNamespace setVariable ["BN_KOTH_playerRecords", _records];
};

["XP progression reset for round", "INFO"] call bn_koth_fnc_common_log;

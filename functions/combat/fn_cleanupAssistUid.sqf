/*
    File: fn_cleanupAssistUid.sqf
    Author: Legend
    Description: Removes a disconnected player from bounded assist contributor state.
    Execution: Server
    Parameters: 0: Player UID <STRING>
    Returns: Number of victim entries changed <NUMBER>
    Public: No
*/

params [["_uid", "", [""]]];
if (!isServer || {_uid isEqualTo ""}) exitWith {0};
private _victims = missionNamespace getVariable ["BN_KOTH_combatAssistVictims", []];
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _changed = 0;
{
    if (!isNull _x) then {
        private _victimUid = if (_records isEqualType createHashMap) then {
            [_x, _records] call bn_koth_fnc_common_resolvePlayerUid
        } else {""};
        private _contributors = _x getVariable ["BN_KOTH_assistContributors", createHashMap];
        if (_victimUid isEqualTo _uid) then {
            _x setVariable ["BN_KOTH_assistContributors", nil, false];
            _x setVariable ["BN_KOTH_assistLastObservedDamage", nil, false];
            _changed = _changed + 1;
        } else {
        if (_contributors isEqualType createHashMap && {_uid in keys _contributors}) then {
            _contributors deleteAt _uid;
            _x setVariable ["BN_KOTH_assistContributors", _contributors, false];
            _changed = _changed + 1;
        };
        };
    };
} forEach _victims;
missionNamespace setVariable ["BN_KOTH_combatAssistVictims", _victims select {
    !isNull _x && {!(([_x, _records] call bn_koth_fnc_common_resolvePlayerUid) isEqualTo _uid)}
}];
_changed

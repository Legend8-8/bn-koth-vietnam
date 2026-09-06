/*
    File: fn_cleanup.sqf
    Author: Legend
    Description: Removes bounded insertion candidates for a player, vehicle,
        or all candidates. An optional phase filter supports vehicle controller
        invalidation without cancelling completed transport legs. Pair cooldowns
        survive every ordinary cleanup and expire in the zone consumer.
    Execution: Server
    Parameters:
        0: Player UID, or empty for no UID filter <STRING>
        1: Vehicle, or objNull for no vehicle filter <OBJECT>
        2: Candidate phase to remove, or empty for every phase <STRING>
    Returns: Number of candidates removed <NUMBER>
    Public: No
*/

params [
    ["_uid", "", [""]],
    ["_vehicle", objNull, [objNull]],
    ["_phase", "", [""]]
];
if (!isServer) exitWith {0};

private _candidates = missionNamespace getVariable ["BN_KOTH_transportCandidates", createHashMap];
private _removeAll = _uid isEqualTo "" && {isNull _vehicle};
private _removed = 0;
{
    private _candidate = _candidates get _x;
    private _matchesUid = !(_uid isEqualTo "") && {
        _x isEqualTo _uid || {(_candidate getOrDefault ["pilotUid", ""]) isEqualTo _uid}
    };
    private _matchesVehicle = !isNull _vehicle && {(_candidate getOrDefault ["vehicle", objNull]) isEqualTo _vehicle};
    private _matchesPhase = _phase isEqualTo "" || {(_candidate getOrDefault ["phase", ""]) isEqualTo _phase};
    if ((_removeAll || {_matchesUid} || {_matchesVehicle}) && {_matchesPhase}) then {
        _candidates deleteAt _x;
        _removed = _removed + 1;
    };
} forEach +(keys _candidates);
missionNamespace setVariable ["BN_KOTH_transportCandidates", _candidates];
_removed

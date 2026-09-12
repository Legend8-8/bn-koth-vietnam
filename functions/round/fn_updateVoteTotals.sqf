/*
    File: fn_updateVoteTotals.sqf
    Author: Legend
    Description: Recomputes authoritative vote totals from per-UID votes.
    Execution: Server
    Parameters:
        None
    Returns:
        Vote totals map <HASHMAP>
    Public: Yes
*/

if (!isServer) exitWith {createHashMap};

private _candidates = missionNamespace getVariable ["BN_KOTH_voteCandidates", []];
private _totals = createHashMap;
{
    _totals set [_x, 0];
} forEach _candidates;

private _votesByUid = missionNamespace getVariable ["BN_KOTH_votesByUid", createHashMap];
if (_votesByUid isEqualType createHashMap) then {
    {
        private _uid = _x;
        private _locationId = _votesByUid get _uid;

        if (_locationId in _candidates) then {
            private _current = _totals getOrDefault [_locationId, 0];
            _totals set [_locationId, _current + 1];
        };
    } forEach (keys _votesByUid);
};

["BN_KOTH_voteTotals", _totals] call bn_koth_fnc_common_publicState;
_totals

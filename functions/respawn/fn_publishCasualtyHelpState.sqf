/*
    File: fn_publishCasualtyHelpState.sqf
    Author: Legend
    Description: Sends each connected player only their same-team approved casualty help projection.
    Execution: Server
    Parameters:
        0: Optional single target owner ID; -1 publishes to all players <NUMBER>
    Returns:
        Number of client owners updated <NUMBER>
    Public: No
*/

params [["_targetOwner", -1, [0]]];

if (!isServer) exitWith {0};

private _requests = missionNamespace getVariable ["BN_KOTH_casualtyHelpRequests", createHashMap];
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_requests isEqualType createHashMap && {_records isEqualType createHashMap}) exitWith {0};

private _sent = 0;
private _roundActive = ([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE";
{
    private _viewer = _x;
    private _ownerId = owner _viewer;
    if (_ownerId <= 0 || {(_targetOwner > 0) && {_ownerId isNotEqualTo _targetOwner}}) then {
        continue;
    };

    private _viewerUid = [_viewer, _records] call bn_koth_fnc_common_resolvePlayerUid;
    private _viewerRecord = _records getOrDefault [_viewerUid, createHashMap];
    if !(_viewerRecord isEqualType createHashMap) then {continue};

    private _viewerSide = _viewerRecord getOrDefault ["assignedSide", sideUnknown];
    private _entries = [];
    private _ownRequestActive = false;
    private _viewerIdentityValid = (_viewerRecord getOrDefault ["ownerId", -1]) isEqualTo _ownerId
        && {(_viewerRecord getOrDefault ["currentUnit", objNull]) isEqualTo _viewer};
    private _viewerCanReceiveIntel = _viewerIdentityValid
        && {alive _viewer}
        && {!([_viewer] call bn_koth_fnc_respawn_isIncapacitated)}
        && {(_viewerRecord getOrDefault ["state", ""]) isEqualTo "ACTIVE"}
        && {_viewerRecord getOrDefault ["deployed", false]}
        && {_roundActive};

    if (_viewerIdentityValid && {[_viewerSide] call bn_koth_fnc_teams_validateSide}) then {
        {
            private _casualtyUid = _x;
            private _request = _requests get _casualtyUid;
            _request params ["_casualty", "_casualtySide"];

            if (_casualtyUid isEqualTo _viewerUid) then {
                _ownRequestActive = true;
            } else {
                if (_viewerCanReceiveIntel && {_casualtySide isEqualTo _viewerSide}) then {
                    private _casualtyRecord = _records getOrDefault [_casualtyUid, createHashMap];
                    private _casualtyName = if (_casualtyRecord isEqualType createHashMap) then {
                        _casualtyRecord getOrDefault ["name", "Teammate"]
                    } else {
                        "Teammate"
                    };
                    _entries pushBack [_casualtyUid, _casualty, _casualtyName];
                };
            };
        } forEach (keys _requests);
    };

    [_entries, _ownRequestActive] remoteExecCall ["bn_koth_fnc_respawn_receiveCasualtyHelpState", _ownerId];
    _sent = _sent + 1;
} forEach allPlayers;

_sent

/*
    File: fn_clearPlayerState.sqf
    Author: Legend
    Description: Clears one player's loadouts-owned session state by UID.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
    Returns:
        True when cleared or already absent, otherwise false <BOOL>
    Public: Yes
*/

params [["_uid", "", [""]]];

if (!isServer) exitWith {false};
if (_uid isEqualTo "") exitWith {false};

private _stateByUid = missionNamespace getVariable ["BN_KOTH_playerLoadoutState", createHashMap];
if !(_stateByUid isEqualType createHashMap) then {
    _stateByUid = createHashMap;
};

_stateByUid deleteAt _uid;
missionNamespace setVariable ["BN_KOTH_playerLoadoutState", _stateByUid];

private _pendingCleanup = missionNamespace getVariable ["BN_KOTH_pendingPerkCleanup", createHashMap];
if (_pendingCleanup isEqualType createHashMap) then {
    _pendingCleanup deleteAt _uid;
    missionNamespace setVariable ["BN_KOTH_pendingPerkCleanup", _pendingCleanup];
};

true

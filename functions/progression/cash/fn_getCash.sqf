/*
    File: fn_getCash.sqf
    Author: Legend
    Description: Reads server-owned session cash without mutating state.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
    Returns:
        Current cash, or -1 for invalid/missing state <NUMBER>
    Public: Yes
*/

params [["_uid", "", [""]]];

if (!isServer) exitWith {-1};
if (_uid isEqualTo "") exitWith {-1};

private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_progressionByUid isEqualType createHashMap) exitWith {-1};

private _progression = _progressionByUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) exitWith {-1};

private _cash = _progression getOrDefault ["cash", -1];
if !(_cash isEqualType 0) exitWith {-1};
if !(finite _cash) exitWith {-1};

_cash max 0

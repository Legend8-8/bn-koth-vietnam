/*
    File: fn_publishUpdate.sqf
    Author: Legend
    Description: Sends one authoritative progression presentation update to
        the client currently registered for a UID.
    Execution: Server
    Parameters:
        0: Player UID <STRING>
        1: Reward resource (xp or cash) <STRING>
        2: Signed reward delta <NUMBER>
        3: Reward reason <STRING>
    Returns:
        True when an update target was available, otherwise false <BOOL>
    Public: No
*/

params [
    ["_uid", "", [""]],
    ["_rewardType", "", [""]],
    ["_rewardAmount", 0, [0]],
    ["_rewardReason", "", [""]]
];

if (!isServer) exitWith {false};
if (_uid isEqualTo "") exitWith {false};

private _progressionByUid = missionNamespace getVariable ["BN_KOTH_playerProgression", createHashMap];
if !(_progressionByUid isEqualType createHashMap) exitWith {false};

private _progression = _progressionByUid getOrDefault [_uid, createHashMap];
if !(_progression isEqualType createHashMap) exitWith {false};

private _payload = [_uid, _progression] call bn_koth_fnc_progression_buildPresentationState;
_payload set ["rewardType", toLower _rewardType];
_payload set ["rewardAmount", _rewardAmount];
_payload set ["rewardReason", _rewardReason];

private _playerRecords = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
if !(_playerRecords isEqualType createHashMap) exitWith {false};

private _playerRecord = _playerRecords getOrDefault [_uid, createHashMap];
if !(_playerRecord isEqualType createHashMap) exitWith {false};

private _ownerId = _playerRecord getOrDefault ["ownerId", -1];
if (_ownerId > 2) exitWith {
    [_payload] remoteExecCall ["bn_koth_fnc_ui_receiveProgression", _ownerId];
    true
};

if (_ownerId isEqualTo 2 && {hasInterface}) exitWith {
    [_payload] call bn_koth_fnc_ui_receiveProgression;
    true
};

false

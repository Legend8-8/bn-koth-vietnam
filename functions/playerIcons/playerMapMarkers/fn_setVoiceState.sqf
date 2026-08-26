/*
    File: fn_setVoiceState.sqf
    Author: tylervip
    Description: Stores a client-reported voice state for local map marker presentation.
    Execution: Client, called on all clients through remote execution.
    Parameters:
        0: Speaking player <OBJECT>
        1: Speaking state <BOOL>
    Returns:
        True when the state is stored, otherwise false <BOOL>
    Public: Yes
*/

params ["_unit", ["_isTalking", false, [true]]];

if (!hasInterface || {isNull _unit} || {!isPlayer _unit}) exitWith {false};

private _uid = getPlayerUID _unit;
if (_uid isEqualTo "") exitWith {false};

private _voiceStates = missionNamespace getVariable ["BN_KOTH_playerMapMarkersVoiceStates", createHashMap];
if !(_voiceStates isEqualType createHashMap) then {
    _voiceStates = createHashMap;
};

_voiceStates set [_uid, _isTalking];
missionNamespace setVariable ["BN_KOTH_playerMapMarkersVoiceStates", _voiceStates];
true
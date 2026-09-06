/*
    File: fn_handleGetOut.sqf
    Author: Legend
    Description: Qualifies a completed transport leg and opens its short AO
        entry confirmation window.
    Execution: Server vehicle event handler
    Parameters: Arma GetOut event arguments
    Returns: None
    Public: No
*/

params ["_vehicle", "_role", "_unit", "_turret", ["_isEject", false, [false]]];
if (!isServer || {!isPlayer _unit}) exitWith {};

private _candidates = missionNamespace getVariable ["BN_KOTH_transportCandidates", createHashMap];
private _isAttributedPilot = (keys _candidates) findIf {
    private _candidate = _candidates get _x;
    (_candidate getOrDefault ["phase", ""]) isEqualTo "BOARDED"
    && {(_candidate getOrDefault ["vehicle", objNull]) isEqualTo _vehicle}
    && {(_candidate getOrDefault ["pilotUnit", objNull]) isEqualTo _unit}
} >= 0;
if (_isAttributedPilot) exitWith {
    ["", _vehicle, "BOARDED"] call bn_koth_fnc_progression_transport_cleanup;
};
if !(_role isEqualTo "cargo") exitWith {};

private _uid = getPlayerUID _unit;
private _candidate = _candidates getOrDefault [_uid, createHashMap];
if !(_candidate isEqualType createHashMap && {(count _candidate) > 0}) exitWith {};
if !((_candidate getOrDefault ["phase", ""]) isEqualTo "BOARDED") exitWith {};
if !((_candidate getOrDefault ["vehicle", objNull]) isEqualTo _vehicle) exitWith {};

private _pilot = currentPilot _vehicle;
private _samePilot = !isNull _pilot && {_pilot isEqualTo (_candidate getOrDefault ["pilotUnit", objNull])};
private _sameAo = (_candidate getOrDefault ["aoId", ""]) isEqualTo (missionNamespace getVariable ["BN_KOTH_activeLocationId", ""]);
private _elapsed = serverTime - (_candidate getOrDefault ["boardAt", serverTime]);
private _distance = (_candidate getOrDefault ["boardPosition", getPosWorld _vehicle]) distance2D (getPosWorld _vehicle);
private _minimumSeconds = missionNamespace getVariable ["BN_KOTH_transportMinimumSeconds", 20];
private _minimumDistance = missionNamespace getVariable ["BN_KOTH_transportMinimumDistance", 500];

if (_isEject || {!isTouchingGround _vehicle} || {!_samePilot} || {!_sameAo} || {_elapsed < _minimumSeconds} || {_distance < _minimumDistance}) exitWith {
    _candidates deleteAt _uid;
    missionNamespace setVariable ["BN_KOTH_transportCandidates", _candidates];
};

_candidate set ["phase", "AWAITING_AO"];
_candidate set ["exitAt", serverTime];
_candidate set ["expiresAt", serverTime + (missionNamespace getVariable ["BN_KOTH_transportConfirmationWindow", 30])];
_candidates set [_uid, _candidate];
missionNamespace setVariable ["BN_KOTH_transportCandidates", _candidates];

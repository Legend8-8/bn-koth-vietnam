/*
    File: fn_handleGetIn.sqf
    Author: Legend
    Description: Records a human cargo passenger boarding an eligible,
        player-piloted transport outside the active AO.
    Execution: Server vehicle event handler
    Parameters: Arma GetIn event arguments
    Returns: None
    Public: No
*/

params ["_vehicle", "_role", "_unit", "_turret"];
if (!isServer || {!(_role isEqualTo "cargo")} || {!isPlayer _unit}) exitWith {};
if !(([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE") exitWith {};

private _passengerUid = getPlayerUID _unit;
private _pilot = currentPilot _vehicle;
if (isNull _pilot || {!isPlayer _pilot} || {_pilot isEqualTo _unit}) exitWith {};
private _pilotUid = getPlayerUID _pilot;
if (_passengerUid isEqualTo "" || {_pilotUid isEqualTo ""} || {_pilotUid isEqualTo _passengerUid}) exitWith {};

private _marker = missionNamespace getVariable ["BN_KOTH_activeZoneMarker", ""];
private _aoId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
if (_marker isEqualTo "" || {_aoId isEqualTo ""} || {_vehicle inArea _marker}) exitWith {};

private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _passengerRecord = _records getOrDefault [_passengerUid, createHashMap];
private _pilotRecord = _records getOrDefault [_pilotUid, createHashMap];
private _isCurrentActive = {
    params ["_record", "_expectedUnit"];
    private _ownerId = _record getOrDefault ["ownerId", -1];
    _record isEqualType createHashMap
    && {_ownerId > 0}
    && {(owner _expectedUnit) isEqualTo _ownerId}
    && {(_record getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
    && {_record getOrDefault ["deployed", false]}
    && {(_record getOrDefault ["currentUnit", objNull]) isEqualTo _expectedUnit}
};
if !([_passengerRecord, _unit] call _isCurrentActive) exitWith {};
if !([_pilotRecord, _pilot] call _isCurrentActive) exitWith {};
private _passengerSide = _passengerRecord getOrDefault ["assignedSide", sideUnknown];
private _pilotSide = _pilotRecord getOrDefault ["assignedSide", sideUnknown];
if !([_passengerSide] call bn_koth_fnc_teams_validateSide) exitWith {};
if !([_pilotSide] call bn_koth_fnc_teams_validateSide) exitWith {};
if !(_pilotSide isEqualTo _passengerSide) exitWith {};

private _pairKey = format ["%1|%2", _pilotUid, _passengerUid];
private _cooldowns = missionNamespace getVariable ["BN_KOTH_transportPairCooldowns", createHashMap];
if (serverTime < (_cooldowns getOrDefault [_pairKey, 0])) exitWith {};

private _candidates = missionNamespace getVariable ["BN_KOTH_transportCandidates", createHashMap];
_candidates set [_passengerUid, createHashMapFromArray [
    ["phase", "BOARDED"],
    ["pilotUid", _pilotUid],
    ["pilotUnit", _pilot],
    ["assignedSide", _pilotSide],
    ["passengerUid", _passengerUid],
    ["vehicle", _vehicle],
    ["vehicleNetId", netId _vehicle],
    ["aoId", _aoId],
    ["boardAt", serverTime],
    ["boardPosition", getPosWorld _vehicle]
]];
missionNamespace setVariable ["BN_KOTH_transportCandidates", _candidates];

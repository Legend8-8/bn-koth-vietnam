/*
    File: fn_handleAircraftGetOut.sqf
    Author: Legend
    Description: Removes a manifested player from aircraft occupancy after a native exit without intercepting freefall or parachute deployment.
    Execution: Server vehicle event handler
    Parameters: Arma GetOut event payload <ARRAY>
    Returns: None
    Public: No
*/

params ["_aircraft", "_role", "_unit", "_turretPath", ["_isEject", false, [true]]];
if (!isServer || {isNull _aircraft} || {isNull _unit} || {!isPlayer _unit}) exitWith {};

private _sessionId = _aircraft getVariable ["BN_KOTH_airInsertionSessionId", ""];
private _uid = getPlayerUID _unit;
if (_uid isEqualTo "") then {
    _uid = [_unit, missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap]] call bn_koth_fnc_common_resolvePlayerUid;
};
if (_sessionId isEqualTo "" || {_uid isEqualTo ""}) exitWith {};

private _session = (missionNamespace getVariable ["BN_KOTH_airInsertionSessions", createHashMap]) getOrDefault [_sessionId, createHashMap];
if !(_session isEqualType createHashMap && {(_session getOrDefault ["state", ""]) isEqualTo "AIRBORNE"}) exitWith {};
if !(_uid in (_session getOrDefault ["aboardUids", []])) exitWith {};

private _preserveParachute = _isEject || {!isTouchingGround _aircraft};
[_uid, if (_preserveParachute) then {"AIRCRAFT_EJECT"} else {"NORMAL_AIRCRAFT_EXIT"}] call bn_koth_fnc_airInsertion_cleanupPlayer;

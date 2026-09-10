/*
    File: test_airInsertion.sqf
    Author: Legend
    Description: Focused config, transform, security-boundary, loadout-isolation, and cleanup checks for air insertion.
    Execution: Server after mission function initialization
    Parameters: None
    Returns: Failure messages; empty means pass <ARRAY>
    Public: No
*/

if (!isServer) exitWith {["Air insertion tests must run on the server."]};

private _failures = [];
private _check = {params ["_condition", "_message"]; if (!_condition) then {_failures pushBack _message}};
private _cfg = missionConfigFile >> "CfgBnKothAirInsertion";
[isClass _cfg, "CfgBnKothAirInsertion is missing"] call _check;
[(getNumber (_cfg >> "enabled")) isEqualTo 1, "Service enabled default is not 1"] call _check;
[(getNumber (_cfg >> "cost")) isEqualTo 500, "Default cost is not 500"] call _check;
[(getNumber (_cfg >> "joinDuration")) isEqualTo 15, "Default join duration is not 15 seconds"] call _check;
[(getNumber (_cfg >> "abandonedCleanupDelay")) isEqualTo 20, "Default abandoned-aircraft cleanup delay is not 20 seconds"] call _check;
[(getText (_cfg >> "aircraftClass")) isEqualTo "C_Plane_Civil_01_F", "Configured aircraft class is incorrect"] call _check;
[(getText (_cfg >> "parachuteBackpackClass")) isEqualTo "B_Parachute", "Configured parachute backpack class is incorrect"] call _check;
[isClass (configFile >> "CfgVehicles" >> getText (_cfg >> "aircraftClass")), "Configured aircraft is unavailable"] call _check;
[isClass (configFile >> "CfgVehicles" >> getText (_cfg >> "parachuteBackpackClass")), "Configured parachute backpack is unavailable"] call _check;
private _aircraftClass = getText (_cfg >> "aircraftClass");
private _aircraftCfg = configFile >> "CfgVehicles" >> _aircraftClass;
private _configuredCapacity = (if ((getNumber (_aircraftCfg >> "hasDriver")) > 0) then {1} else {0})
    + count ([_aircraftClass, false] call BIS_fnc_allTurrets)
    + ((getNumber (_aircraftCfg >> "transportSoldier")) max 0);
[_configuredCapacity isEqualTo 4, "Production Caesar does not expose four configured human positions"] call _check;
private _invalidPlayer = [objNull, sideUnknown] call bn_koth_fnc_airInsertion_evaluatePlayer;
[!(_invalidPlayer getOrDefault ["success", true]) && {(_invalidPlayer getOrDefault ["code", ""]) isEqualTo "INVALID_PLAYER"}, "Invalid player was not rejected"] call _check;

private _minDistance = getNumber (_cfg >> "minDistance");
private _maxDistance = getNumber (_cfg >> "maxDistance");
private _ao = [5000, 5000, 0];
private _transform = [_ao, 90, _minDistance] call bn_koth_fnc_airInsertion_getTransform;
private _spawn = _transform getOrDefault ["spawnASL", []];
[(count _spawn) isEqualTo 3, "Transform did not return an ASL spawn"] call _check;
private _resolvedDistance = [_spawn select 0, _spawn select 1] distance2D _ao;
[(_resolvedDistance >= (_minDistance - 0.1)) && {_resolvedDistance <= (_maxDistance + 0.1)}, "Insertion distance is outside configured bounds"] call _check;
private _expectedHeading = [_spawn select 0, _spawn select 1] getDir _ao;
private _headingDelta = abs ((((_transform get "heading") - _expectedHeading + 540) mod 360) - 180);
[_headingDelta < 0.1, "Aircraft heading does not target the AO"] call _check;
[abs (((_spawn select 2) - (_transform get "terrainASL")) - getNumber (_cfg >> "altitudeAGL")) < 0.1, "AGL transform is not terrain-relative"] call _check;

private _requestSource = preprocessFileLineNumbers "functions\airInsertion\fn_request.sqf";
private _commitSource = preprocessFileLineNumbers "functions\airInsertion\fn_commitSession.sqf";
private _backpackApplySource = preprocessFileLineNumbers "functions\airInsertion\fn_applyBackpack.sqf";
private _backpackRequestSource = preprocessFileLineNumbers "functions\airInsertion\fn_backpackRequest.sqf";
[(_backpackRequestSource find "lastAcknowledgementAt") >= 0
    && {(_backpackRequestSource find "lastAcknowledgementOperation") >= 0},
    "Backpack acknowledgement endpoint must throttle same-operation replays without suppressing the next valid phase."] call _assert;
private _backpackCleanupSource = preprocessFileLineNumbers "functions\airInsertion\fn_cleanupBackpack.sqf";
private _moveSource = preprocessFileLineNumbers "functions\airInsertion\fn_applyPassengerMove.sqf";
private _eligibilitySource = preprocessFileLineNumbers "functions\airInsertion\fn_evaluatePlayer.sqf";
private _getOutSource = preprocessFileLineNumbers "functions\airInsertion\fn_handleAircraftGetOut.sqf";
private _presentationSource = preprocessFileLineNumbers "functions\airInsertion\fn_receiveState.sqf";
private _publishSource = preprocessFileLineNumbers "functions\airInsertion\fn_publishSession.sqf";
private _cleanupSource = preprocessFileLineNumbers "functions\airInsertion\fn_cleanupSession.sqf";
private _playerCleanupSource = preprocessFileLineNumbers "functions\airInsertion\fn_cleanupPlayer.sqf";
private _boardSource = preprocessFileLineNumbers "functions\vehicles\mobile_respawn\fn_initTeleport.sqf";
private _hudSource = preprocessFileLineNumbers "functions\ui\hud\fn_refreshHud.sqf";
private _roundSource = preprocessFileLineNumbers "functions\round\fn_setState.sqf";
private _deathSource = preprocessFileLineNumbers "functions\respawn\fn_handlePlayerDeath.sqf";
private _disconnectSource = preprocessFileLineNumbers "functions\teams\fn_removePlayer.sqf";
[((_requestSource find "remoteExecutedOwner") >= 0), "Request does not derive the remote owner"] call _check;
[((_requestSource find "BN_KOTH_airInsertionEnabled") >= 0), "Disabled-service request gate is absent"] call _check;
[((_requestSource find "bn_koth_fnc_progression_cash_getCash") >= 0), "Start affordability check is absent"] call _check;
[((_requestSource find "bn_koth_fnc_airInsertion_evaluatePlayer") >= 0), "Start/join does not use shared server eligibility"] call _check;
[((_requestSource find "state isEqualTo ""OPEN""") >= 0), "Join/leave/cancel OPEN-state boundary is absent"] call _check;
[((_requestSource find "count _passengers") >= 0), "Join capacity boundary is absent"] call _check;
[((_requestSource find "_uid in _passengers") >= 0), "Duplicate-join boundary is absent"] call _check;
[((_requestSource find "passengerUids"", [_uid]") >= 0), "Solo session is not initialized with only the initiator"] call _check;
[((_requestSource find "_passengers - [_uid]") >= 0), "OPEN passenger leave path is absent"] call _check;
[((_requestSource find "INITIATOR_CANCELLED") >= 0), "OPEN initiator cancellation path is absent"] call _check;
[((_eligibilitySource find "WRONG_SIDE") >= 0), "Wrong-side eligibility rejection is absent"] call _check;
[((_eligibilitySource find "bn_koth_fnc_respawn_getSafeZoneMembership") >= 0), "Authoritative safe-zone eligibility check is absent"] call _check;
[((_commitSource find "bn_koth_fnc_progression_cash_spendCash") > (_commitSource find "createVehicle")), "Cash is not spent after insertion asset creation"] call _check;
[((_commitSource find "_allBoarded") < (_commitSource find "bn_koth_fnc_progression_cash_spendCash")), "Cash is spent before boarding validation"] call _check;
[((_commitSource find "fullCrew [_aircraft, """", true]") >= 0), "Commit does not resolve every real human seat"] call _check;
[((_commitSource find "_seatPlan = [_driverSeat]") >= 0) && {(_moveSource find "moveInDriver _aircraft") >= 0}, "Initiator pilot-seat ownership is absent"] call _check;
[((_commitSource find "_crewSeats = [_crewSeats") >= 0) && {(_commitSource find "_cargoSeats = [_cargoSeats") >= 0}, "Copilot/cargo seat ordering is not deterministic"] call _check;
[((_moveSource find "moveInTurret") >= 0) && {(_moveSource find "moveInCargo") >= 0}, "Crew/cargo seat topology is not supported"] call _check;
[((_commitSource find "createVehicleCrew") < 0) && {(_commitSource find "addWaypoint") < 0}, "AI pilot or waypoint flight ownership remains"] call _check;
[((_commitSource find " lock ") < 0) && {(_commitSource find "lockDriver") < 0} && {(_commitSource find "lockCargo") < 0}, "Aircraft locking still suppresses native human use"] call _check;
[((_commitSource find "setVelocityModelSpace") < (_commitSource find """BOARD""")) && {(_commitSource find """BOARD""") < (_commitSource find "enableSimulationGlobal true")}, "One-time flight initialization can race or override pilot control after boarding"] call _check;
[((_requestSource find "JUMP") < 0) && {(_presentationSource find "EJECT / PARACHUTE") < 0}, "Custom jump intent remains the primary interaction"] call _check;
[((_moveSource find "remoteExecutedOwner isNotEqualTo 2") >= 0), "Passenger locality endpoint does not reject non-server callers"] call _check;
[((_backpackApplySource find "parachuteBackpackClass") >= 0) && {(_backpackApplySource find "[_parachuteClass, []]") >= 0}, "Owner-local configured parachute backpack preparation is absent"] call _check;
[((_commitSource find "getUnitLoadout _unit") >= 0) && {(_commitSource find "_physicalLoadout select 5") >= 0}, "Current physical backpack slot is not captured before preparation"] call _check;
[((_backpackApplySource find "_updatedLoadout = getUnitLoadout player") >= 0) && {(_backpackApplySource find "_updatedLoadout set [5, +_backpackSlot]") >= 0}, "Backpack restoration does not replace slot 5 in the current full physical loadout"] call _check;
[((_backpackApplySource find "_expectedUnit isEqualTo player") >= 0), "Backpack endpoint is not bound to the server-authoritative player representation"] call _check;
[((_commitSource find "PREPARE") < (_commitSource find """BOARD""")) && {(_commitSource find """BOARD""") < (_commitSource find "bn_koth_fnc_progression_cash_spendCash")}, "Parachute preparation/boarding/payment ordering is incorrect"] call _check;
[((_backpackRequestSource find "PREPARED") >= 0) && {(_backpackRequestSource find "backpack _unit") >= 0}, "Server does not verify parachute backpack preparation"] call _check;
[((_backpackApplySource find "GetOutMan") >= 0) && {(_backpackApplySource find "ParachuteBase") >= 0} && {(_backpackApplySource find "isTouchingGround") >= 0}, "Landing restoration trigger is absent or not ground-bounded"] call _check;
[((_backpackRequestSource find "objectParent _unit") >= 0) && {(_backpackRequestSource find "isTouchingGround _unit") >= 0}, "Server does not validate completed parachute descent before restoration"] call _check;
[((_backpackRequestSource find "originalSlot") >= 0) && {(_backpackRequestSource find "deleteAt _uid") >= 0}, "Restored temporary backpack state is not verified and cleared"] call _check;
[((_backpackRequestSource find "_reportedRestoreMatch && {_serverMatch}") >= 0) && {(_backpackRequestSource find "_states deleteAt _uid") >= 0}, "Restore success is not gated by owner acknowledgement and server physical verification"] call _check;
[((_backpackRequestSource find "restore mismatch") >= 0) && {(_backpackRequestSource find "RESTORE_FAILED") >= 0} && {(_backpackCleanupSource find "ACK_TIMEOUT") >= 0}, "Restore failure is not reported and retained through bounded retry"] call _check;
[((_getOutSource find "_isEject || {!isTouchingGround _aircraft}") >= 0) && {(_playerCleanupSource find "case ""AIRCRAFT_EJECT""") < 0}, "An airborne aircraft exit can prematurely consume the saved backpack state"] call _check;
[((_getOutSource find "bn_koth_fnc_airInsertion_deployParachute") < 0) && {(_moveSource find "moveInDriver _parachute") < 0} && {(_cleanupSource find "Steerable_Parachute_F") < 0}, "Forced immediate parachute deployment remains"] call _check;
[((_backpackApplySource find "BN_KOTH_playerLoadoutState") < 0) && {(_backpackRequestSource find "BN_KOTH_playerLoadoutState") < 0} && {(_backpackCleanupSource find "BN_KOTH_playerLoadoutState") < 0}, "Temporary parachute state reaches intended loadout ownership"] call _check;
[((_commitSource find "set [""currentUnit""") < 0) && {(_backpackApplySource find "set [""currentUnit""") < 0} && {(_backpackRequestSource find "set [""currentUnit""") < 0}, "Insertion code mutates authoritative currentUnit"] call _check;
[((_deathSource find "PLAYER_DIED") >= 0) && {(_disconnectSource find "PLAYER_DISCONNECTED") >= 0} && {(_backpackCleanupSource find """CLEAR""") >= 0}, "Death/disconnect temporary-backpack cleanup boundary is absent"] call _check;
[((_roundSource find "BN_KOTH_airInsertionBackpacks") >= 0) && {(_roundSource find "ROUND_RESETTING") >= 0}, "Round transitions do not clear temporary backpack state"] call _check;
[((_commitSource find "bn_koth_fnc_respawn_forceExitVehicle") >= 0), "Manifest-only GetIn enforcement is absent"] call _check;
[((_roundSource find "ROUND_ENDING") >= 0) && {(_roundSource find "ROUND_RESETTING") >= 0}, "Round transitions do not clean insertion sessions"] call _check;
[((_commitSource find "BN_KOTH_vehicleActiveRentals") < 0), "Insertion aircraft enters rental state"] call _check;
[((_boardSource find "AIR INSERTION — %1 — $%2") >= 0), "Mapboard insertion actions do not use the production SOLO/GROUP price wording"] call _check;
[((_hudSource find "Departing in %1") >= 0) && {(_hudSource find "case ""COMMITTING""") >= 0} && {(_hudSource find "DEPARTING") >= 0}, "Countdown/departing presentation is absent"] call _check;
[((_presentationSource find "_enteringAirborne") >= 0) && {(_presentationSource find "You are the pilot") >= 0} && {(_presentationSource find "deploy your parachute") >= 0}, "One-time pilot/passenger airborne feedback is absent"] call _check;
[((_backpackApplySource find "BN_KOTH_AirInsertionTransition") >= 0) && {(_presentationSource find "BN_KOTH_AirInsertionTransition") >= 0}, "Preparation/departure transition does not remain covered until AIRBORNE publication"] call _check;
[((_cleanupSource find "ABANDONED") >= 0) && {(_cleanupSource find "abandonedCleanupDelay") >= 0}, "Empty insertion aircraft still has immediate cleanup"] call _check;
[((_playerCleanupSource find "aboardUids") >= 0) && {(_playerCleanupSource find "isEqualTo []") >= 0}, "Aircraft cleanup does not wait for every manifested occupant to leave"] call _check;
[((_cleanupSource find "HARD_TIMEOUT") >= 0) && {(_cleanupSource find """EJECT""") >= 0} && {(_cleanupSource find "sleep 2") >= 0}, "Hard timeout does not provide bounded safe egress before deletion"] call _check;
[((_commitSource find "backpack CAPTURE") < 0) && {(_backpackApplySource find "PARACHUTE APPLIED") < 0} && {(_backpackCleanupSource find "RESTORE REQUEST") < 0} && {(_backpackRequestSource find "RESTORE SUCCESS") < 0}, "Temporary successful-path backpack diagnostics remain"] call _check;
[((_requestSource find "sideToken") < 0) && {(_requestSource find "createdAt") < 0} && {(_publishSource find "aircraftNetId") < 0}, "Unused insertion presentation/session fields remain"] call _check;
[((_requestSource find '["mode", if (_isGroup) then {"GROUP"} else {"SOLO"}]') >= 0) && {(_publishSource find '["cost", _session getOrDefault ["cost", 0]]') >= 0}, "Insertion presentation omits authoritative SOLO/GROUP or price state"] call _check;

private _savedSessions = missionNamespace getVariable ["BN_KOTH_airInsertionSessions", createHashMap];
private _savedPlayerSessions = missionNamespace getVariable ["BN_KOTH_airInsertionPlayerSessions", createHashMap];
private _savedBackpacks = missionNamespace getVariable ["BN_KOTH_airInsertionBackpacks", createHashMap];
missionNamespace setVariable ["BN_KOTH_airInsertionSessions", createHashMapFromArray [["TEST", createHashMapFromArray [
    ["id", "TEST"], ["state", "OPEN"], ["initiatorUid", "TEST_UID"], ["passengerUids", ["TEST_UID"]],
    ["invitedUids", []], ["aboardUids", []], ["aircraft", objNull]
]]]];
missionNamespace setVariable ["BN_KOTH_airInsertionPlayerSessions", createHashMapFromArray [["TEST_UID", "TEST"]]];
missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", createHashMapFromArray [["TEST_UID", createHashMapFromArray [
    ["uid", "TEST_UID"], ["sessionId", "TEST"], ["unit", objNull],
    ["originalSlot", ["B_AssaultPack_khk", [["FirstAidKit", 2]]]], ["phase", "READY"]
]]]];
[(["TEST", "TEST_CLEANUP", "NONE"] call bn_koth_fnc_airInsertion_cleanupSession), "Cleanup rejected a valid test session"] call _check;
[(count (missionNamespace getVariable ["BN_KOTH_airInsertionSessions", createHashMap])) isEqualTo 0, "Cleanup left session state"] call _check;
[(count (missionNamespace getVariable ["BN_KOTH_airInsertionPlayerSessions", createHashMap])) isEqualTo 0, "Cleanup left player membership"] call _check;
[["TEST_UID", "CLEAR", "TEST_CLEANUP"] call bn_koth_fnc_airInsertion_cleanupBackpack, "Temporary backpack cleanup rejected valid test state"] call _check;
[(count (missionNamespace getVariable ["BN_KOTH_airInsertionBackpacks", createHashMap])) isEqualTo 0, "Cleanup left temporary backpack state"] call _check;
[!(["TEST_UID", "CLEAR", "TEST_CLEANUP_REPEAT"] call bn_koth_fnc_airInsertion_cleanupBackpack), "Cleanup accepted already-cleared temporary backpack state"] call _check;
missionNamespace setVariable ["BN_KOTH_airInsertionSessions", _savedSessions];
missionNamespace setVariable ["BN_KOTH_airInsertionPlayerSessions", _savedPlayerSessions];
missionNamespace setVariable ["BN_KOTH_airInsertionBackpacks", _savedBackpacks];

_failures

/*
    File: fn_receiveState.sqf
    Author: Legend
    Description: Receives targeted insertion presentation, installs the applicable local intent action, and gives one-time departure feedback.
    Execution: Client (server RemoteExec only)
    Parameters: 0: Presentation state <HASHMAP>
    Returns: None
    Public: Yes
*/

params [["_state", createHashMap, [createHashMap]]];
if (!hasInterface || {!isRemoteExecuted} || {remoteExecutedOwner isNotEqualTo 2}) exitWith {};

private _previousState = missionNamespace getVariable ["BN_KOTH_airInsertionLocalState", createHashMap];
private _binding = uiNamespace getVariable ["BN_KOTH_airInsertionActionBinding", [objNull, []]];
_binding params [["_oldUnit", objNull, [objNull]], ["_oldActions", [], [[]]]];
if (!isNull _oldUnit) then {{_oldUnit removeAction _x} forEach _oldActions};
uiNamespace setVariable ["BN_KOTH_airInsertionActionBinding", [objNull, []]];

if !(_state isEqualType createHashMap) then {_state = createHashMap};
missionNamespace setVariable ["BN_KOTH_airInsertionLocalState", _state];
if ((count _state) <= 0 || {isNull player}) exitWith {
    if (_previousState isEqualType createHashMap && {(count _previousState) > 0}) then {
        private _previousRole = _previousState getOrDefault ["role", ""];
        private _closedMessage = switch (_previousRole) do {
            case "INVITED": {"AIR INSERTION INVITATION CLOSED."};
            case "PASSENGER": {"YOU LEFT THE AIR INSERTION."};
            case "INITIATOR": {"AIR INSERTION SESSION CLOSED."};
            default {""};
        };
        if !(_closedMessage isEqualTo "") then {[_closedMessage] call bn_koth_fnc_ui_notify};
    };
    [] call bn_koth_fnc_ui_refreshHud
};

private _sessionId = _state getOrDefault ["id", ""];
private _sessionState = _state getOrDefault ["state", ""];
private _role = _state getOrDefault ["role", ""];
private _mode = _state getOrDefault ["mode", "GROUP"];
private _cost = _state getOrDefault ["cost", 0];
private _enteringOpenRole = _sessionState isEqualTo "OPEN" && {
    !(_previousState isEqualType createHashMap)
        || {!((_previousState getOrDefault ["id", ""]) isEqualTo _sessionId)}
        || {!((_previousState getOrDefault ["role", ""]) isEqualTo _role)}
};
if (_enteringOpenRole) then {
    private _remaining = ceil (((_state getOrDefault ["departureAt", serverTime]) - serverTime) max 0);
    private _openMessage = switch (_role) do {
        case "INVITED": {format ["GROUP AIR INSERTION INVITATION — Pilot: %1. Departing in %2 seconds. Passengers are not charged.", _state getOrDefault ["initiatorName", "Teammate"], _remaining]};
        case "PASSENGER": {format ["JOINED GROUP AIR INSERTION — %1 / %2 seats filled. Passengers are not charged.", _state getOrDefault ["passengerCount", 0], _state getOrDefault ["capacity", 0]]};
        case "INITIATOR": {format ["%1 AIR INSERTION OPEN — Departing in %2 seconds. You pay $%3 only if departure succeeds.", _mode, _remaining, _cost]};
        default {""};
    };
    if !(_openMessage isEqualTo "") then {[_openMessage] call bn_koth_fnc_ui_notify};
};
private _enteringCommitting = _sessionState isEqualTo "COMMITTING" && {
    !(_previousState isEqualType createHashMap) || {!((_previousState getOrDefault ["state", ""]) isEqualTo "COMMITTING")}
};
if (_enteringCommitting && {_role in ["INITIATOR", "PASSENGER"]}) then {
    ["AIR INSERTION DEPARTING — Preparing parachutes and boarding aircraft."] call bn_koth_fnc_ui_notify;
};
private _enteringAirborne = _sessionState isEqualTo "AIRBORNE" && {
    !(_previousState isEqualType createHashMap)
        || {!((_previousState getOrDefault ["id", ""]) isEqualTo _sessionId)}
        || {!((_previousState getOrDefault ["state", ""]) isEqualTo "AIRBORNE")}
};
if (_enteringAirborne) then {
    private _transitionLayer = "BN_KOTH_AirInsertionTransition" call BIS_fnc_rscLayer;
    _transitionLayer cutText ["", "BLACK IN", 0.45];
    private _passengerCount = _state getOrDefault ["passengerCount", 0];
    private _capacity = _state getOrDefault ["capacity", 4];
    private _message = if (_role isEqualTo "INITIATOR") then {
        format ["AIR INSERTION — You are the pilot. Passengers: %1 / %2. Fly the approach; eject when ready.", _passengerCount, _capacity]
    } else {
        format ["AIR INSERTION — Pilot: %1. Eject and deploy your parachute when ready.", _state getOrDefault ["initiatorName", "Teammate"]]
    };
    [_message] call bn_koth_fnc_ui_notify;
};

private _actions = [];
private _addIntent = {
    params ["_title", "_operation", ["_condition", "alive _this", [""]]];
    _actions pushBack (player addAction [
        _title,
        {
            params ["_target", "_caller", "_actionId", "_args"];
            _args remoteExecCall ["bn_koth_fnc_airInsertion_request", 2];
        },
        [_operation, _sessionId], 4, false, true, "", _condition
    ]);
};

if (_sessionState isEqualTo "OPEN") then {
    switch (_role) do {
        case "INVITED": {
            if ((_state getOrDefault ["passengerCount", 0]) < (_state getOrDefault ["capacity", 0])) then {
                ["JOIN AIR INSERTION", "JOIN"] call _addIntent;
            };
        };
        case "INITIATOR": {["CANCEL AIR INSERTION", "CANCEL"] call _addIntent};
        case "PASSENGER": {["LEAVE AIR INSERTION", "LEAVE"] call _addIntent};
    };
};
uiNamespace setVariable ["BN_KOTH_airInsertionActionBinding", [player, _actions]];
[] call bn_koth_fnc_ui_refreshHud;

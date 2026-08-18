/*
    File: fn_refresh.sqf
    Author: tylervip
    Description: Rebuilds local map icon data for same-side active players only.
    Execution: Client
    Parameters:
        None
    Returns:
        Number of active local map icon entries after refresh <NUMBER>
    Public: Yes
*/

if (!hasInterface) exitWith {0};
if (isNull player) exitWith {0};

if !(missionNamespace getVariable ["BN_KOTH_playerIconsEnabled", true]) exitWith {
    uiNamespace setVariable ["BN_KOTH_playerIconsDrawData", []];
    0
};

private _myUid = getPlayerUID player;
if (_myUid isEqualTo "") exitWith {
    uiNamespace setVariable ["BN_KOTH_playerIconsDrawData", []];
    0
};

private _playerAssignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
if !(_playerAssignments isEqualType createHashMap) then {
    _playerAssignments = createHashMap;
};

private _mySide = _playerAssignments getOrDefault [_myUid, sideUnknown];
if !([_mySide] call bn_koth_fnc_teams_validateSide) then {
    _mySide = side group player;
};
if !([_mySide] call bn_koth_fnc_teams_validateSide) exitWith {
    uiNamespace setVariable ["BN_KOTH_playerIconsDrawData", []];
    0
};

private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
private _lastDrawData = uiNamespace getVariable ["BN_KOTH_playerIconsLastDrawData", []];
private _lastDrawAt = uiNamespace getVariable ["BN_KOTH_playerIconsLastDrawAt", -1];

if !(_playerStates isEqualType createHashMap) then {
    _playerStates = createHashMap;
};

private _activeLookup = createHashMap;
{
    _activeLookup set [_x, true];
} forEach _activeParticipants;

private _iconTexture = missionNamespace getVariable ["BN_KOTH_playerIconsTexture", "\A3\ui_f\data\map\markers\military\triangle_CA.paa"];
private _iconColor = missionNamespace getVariable ["BN_KOTH_playerIconsColorArray", [1, 1, 1, 1]];
private _groupIconColor = missionNamespace getVariable ["BN_KOTH_playerIconsGroupColorArray", [0, 1, 0, 1]];
private _voiceStates = missionNamespace getVariable ["BN_KOTH_playerIconsVoiceStates", createHashMap];
if !(_voiceStates isEqualType createHashMap) then {
    _voiceStates = createHashMap;
};
private _showPassengerCount = missionNamespace getVariable ["BN_KOTH_playerIconsShowPassengerCount", true];
private _showDriverName = missionNamespace getVariable ["BN_KOTH_playerIconsShowDriverName", true];

private _eligiblePlayers = allPlayers select {
    private _unit = _x;
    if (isNull _unit) exitWith {false};

    private _uid = getPlayerUID _unit;

    if (_uid isEqualTo "") exitWith {false};
    if !(alive _unit) exitWith {false};
    private _assignedSide = _playerAssignments getOrDefault [_uid, sideUnknown];
    if !([_assignedSide] call bn_koth_fnc_teams_validateSide) then {
        _assignedSide = side group _unit;
    };
    if !([_assignedSide] call bn_koth_fnc_teams_validateSide) exitWith {false};

    private _isActiveParticipant = _activeLookup getOrDefault [_uid, false];
    private _isActiveState = (_playerStates getOrDefault [_uid, "LOBBY"]) isEqualTo "ACTIVE";
    if !(_isActiveParticipant || {_isActiveState}) exitWith {false};

    _assignedSide isEqualTo _mySide
};
if !(_eligiblePlayers isEqualType []) then {
    _eligiblePlayers = [];
};

private _drawData = [];
private _vehicleGroups = createHashMap;

{
    private _unit = _x;
    private _unitVehicle = vehicle _unit;

    if (_unitVehicle isEqualTo _unit) then {
        private _uid = getPlayerUID _unit;
        private _label = if (_showDriverName) then {name _unit} else {""};
        private _hasOtherGroupPlayer = ({isPlayer _x} count units group player) > 1;
        private _isSameGroupPlayer = _hasOtherGroupPlayer && {group _unit isEqualTo group player};
        private _playerColor = if (_isSameGroupPlayer) then {_groupIconColor} else {_iconColor};
        private _isTalking = _voiceStates getOrDefault [_uid, false];
        _drawData pushBack [getPosVisual _unit, getDir _unit, _label, _iconTexture, _playerColor, _unit isEqualTo player, _isTalking];
    } else {
        private _vehicleKey = netId _unitVehicle;
        if (_vehicleKey isEqualTo "") then {
            _vehicleKey = str _unitVehicle;
        };
        _vehicleKey = (_vehicleKey splitString ":") joinString "_";

        private _existingGroup = _vehicleGroups getOrDefault [_vehicleKey, []];
        _existingGroup pushBack _unit;
        _vehicleGroups set [_vehicleKey, _existingGroup];
    };
} forEach _eligiblePlayers;

{
    private _vehicleKey = _x;
    private _occupants = _vehicleGroups getOrDefault [_vehicleKey, []];
    if ((count _occupants) < 1) then {
        continue;
    };

    private _vehicle = vehicle (_occupants select 0);
    if (isNull _vehicle) then {
        continue;
    };

    private _driver = driver _vehicle;
    if (isNull _driver || {!(_driver in _occupants)}) then {
        _driver = _occupants select 0;
    };

    private _extraCount = (count _occupants) - 1;
    private _label = if (_showDriverName) then {name _driver} else {""};
    if (_showPassengerCount && {_extraCount > 0}) then {
        _label = format ["%1 +%2", _label, _extraCount];
    };

    private _hasOtherGroupPlayer = ({isPlayer _x} count units group player) > 1;
    private _hasSameGroupPlayer = _hasOtherGroupPlayer && {{group _x isEqualTo group player} count _occupants > 0};
    private _vehicleColor = if (_hasSameGroupPlayer) then {_groupIconColor} else {_iconColor};
    private _hasLocalPlayer = false;
    private _isTalking = false;
    {
        if (_x isEqualTo player) then {
            _hasLocalPlayer = true;
        };
        if (_voiceStates getOrDefault [getPlayerUID _x, false]) then {
            _isTalking = true;
        };
    } forEach _occupants;
    _drawData pushBack [getPosVisual _vehicle, getDir _vehicle, _label, _iconTexture, _vehicleColor, _hasLocalPlayer, _isTalking];
} forEach (keys _vehicleGroups);

uiNamespace setVariable ["BN_KOTH_playerIconsDrawData", _drawData];

if ((count _drawData) > 0) then {
    uiNamespace setVariable ["BN_KOTH_playerIconsLastDrawData", _drawData];
    uiNamespace setVariable ["BN_KOTH_playerIconsLastDrawAt", diag_tickTime];
} else {
    private _roundState = missionNamespace getVariable ["BN_KOTH_roundState", "WAITING"];
    if (_roundState isEqualTo "ACTIVE" && {_lastDrawAt >= 0} && {(diag_tickTime - _lastDrawAt) < 1}) then {
        uiNamespace setVariable ["BN_KOTH_playerIconsDrawData", _lastDrawData];
    };
};

count (uiNamespace getVariable ["BN_KOTH_playerIconsDrawData", []])
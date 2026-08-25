/*
    File: fn_refresh.sqf
    Author: tylervip
    Description: Rebuilds client-local map markers for same-side active players.
    Execution: Client
    Parameters: None
    Returns: Number of active local map markers <NUMBER>
    Public: Yes
*/

if (!hasInterface) exitWith {0};

private _markers = missionNamespace getVariable ["BN_KOTH_playerMapMarkersMarkers", createHashMap];
if !(_markers isEqualType createHashMap) then {
    _markers = createHashMap;
};

private _deleteAllMarkers = {
    {
        deleteMarkerLocal _x;
    } forEach (values _markers);
    {
        _markers deleteAt _x;
    } forEach (keys _markers);
};

if (isNull player || {!alive player} || {!(missionNamespace getVariable ["BN_KOTH_playerMapMarkersEnabled", true])}) exitWith {
    call _deleteAllMarkers;
    missionNamespace setVariable ["BN_KOTH_playerMapMarkersMarkers", _markers];
    0
};

private _myUid = getPlayerUID player;
if (_myUid isEqualTo "") exitWith {
    call _deleteAllMarkers;
    missionNamespace setVariable ["BN_KOTH_playerMapMarkersMarkers", _markers];
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
    call _deleteAllMarkers;
    missionNamespace setVariable ["BN_KOTH_playerMapMarkersMarkers", _markers];
    0
};

private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
if !(_playerStates isEqualType createHashMap) then {
    _playerStates = createHashMap;
};

private _activeLookup = createHashMap;
{
    _activeLookup set [_x, true];
} forEach _activeParticipants;

private _voiceStates = missionNamespace getVariable ["BN_KOTH_playerMapMarkersVoiceStates", createHashMap];
if !(_voiceStates isEqualType createHashMap) then {
    _voiceStates = createHashMap;
};

private _markerType = missionNamespace getVariable ["BN_KOTH_playerMapMarkersType", "mil_triangle"];
private _markerColor = missionNamespace getVariable ["BN_KOTH_playerMapMarkersColor", "ColorWhite"];
private _groupMarkerColor = missionNamespace getVariable ["BN_KOTH_playerMapMarkersGroupColor", "ColorGreen"];
private _micMarkerType = missionNamespace getVariable ["BN_KOTH_playerMapMarkersMicType", "mil_triangle"];
private _micMarkerColor = missionNamespace getVariable ["BN_KOTH_playerMapMarkersMicColor", "ColorOrange"];
private _micEnabled = missionNamespace getVariable ["BN_KOTH_playerMapMarkersMicEnabled", true];
private _alpha = missionNamespace getVariable ["BN_KOTH_playerMapMarkersAlpha", 1];
private _showPassengerCount = missionNamespace getVariable ["BN_KOTH_playerMapMarkersShowPassengerCount", true];
private _showDriverName = missionNamespace getVariable ["BN_KOTH_playerMapMarkersShowDriverName", true];
private _markerShadow = missionNamespace getVariable ["BN_KOTH_playerMapMarkersShadow", false];

private _eligiblePlayers = allPlayers select {
    private _unit = _x;
    private _uid = getPlayerUID _unit;
    private _assignedSide = _playerAssignments getOrDefault [_uid, sideUnknown];
    if !([_assignedSide] call bn_koth_fnc_teams_validateSide) then {
        _assignedSide = side group _unit;
    };
    private _isActiveParticipant = _activeLookup getOrDefault [_uid, false];
    private _isActiveState = (_playerStates getOrDefault [_uid, "LOBBY"]) isEqualTo "ACTIVE";

    !isNull _unit
    && {_uid isNotEqualTo ""}
    && {alive _unit}
    && {[_assignedSide] call bn_koth_fnc_teams_validateSide}
    && {_isActiveParticipant || {_isActiveState}}
    && {_assignedSide isEqualTo _mySide}
};

private _markerEntries = [];
private _micDrawEntries = [];
private _vehicleGroups = createHashMap;
{
    private _unit = _x;
    private _unitVehicle = vehicle _unit;
    if (_unitVehicle isEqualTo _unit) then {
        private _uid = getPlayerUID _unit;
        private _hasOtherGroupPlayer = ({isPlayer _x} count units group player) > 1;
        private _isSameGroupPlayer = _hasOtherGroupPlayer && {group _unit isEqualTo group player};
        private _isTalking = _micEnabled && {_voiceStates getOrDefault [_uid, false]};
        private _color = if (_isTalking) then {_micMarkerColor} else {if (_isSameGroupPlayer) then {_groupMarkerColor} else {_markerColor}};
        private _type = if (_isTalking) then {_micMarkerType} else {_markerType};
        private _label = if (_showDriverName) then {name _unit} else {""};
        _markerEntries pushBack [_uid, getPosVisual _unit, getDir _unit, _label, _type, _color];
        if (_isTalking) then {_micDrawEntries pushBack [getPosVisual _unit];};
    } else {
        private _vehicleKey = netId _unitVehicle;
        if (_vehicleKey isEqualTo "") then {_vehicleKey = str _unitVehicle};
        _vehicleKey = (_vehicleKey splitString ":") joinString "_";
        private _occupants = _vehicleGroups getOrDefault [_vehicleKey, []];
        _occupants pushBack _unit;
        _vehicleGroups set [_vehicleKey, _occupants];
    };
} forEach _eligiblePlayers;

{
    private _vehicleKey = _x;
    private _occupants = _vehicleGroups getOrDefault [_vehicleKey, []];
    if ((count _occupants) < 1) then {continue};

    private _vehicle = vehicle (_occupants select 0);
    if (isNull _vehicle) then {continue};

    private _driver = driver _vehicle;
    if (isNull _driver || {!(_driver in _occupants)}) then {_driver = _occupants select 0};

    private _extraCount = (count _occupants) - 1;
    private _label = if (_showDriverName) then {name _driver} else {""};
    if (_showPassengerCount && {_extraCount > 0}) then {
        _label = format ["%1 +%2", _label, _extraCount];
    };

    private _hasOtherGroupPlayer = ({isPlayer _x} count units group player) > 1;
    private _hasSameGroupPlayer = _hasOtherGroupPlayer && {{group _x isEqualTo group player} count _occupants > 0};
    private _isTalking = _micEnabled && {{_voiceStates getOrDefault [getPlayerUID _x, false]} count _occupants > 0};
    private _color = if (_isTalking) then {_micMarkerColor} else {if (_hasSameGroupPlayer) then {_groupMarkerColor} else {_markerColor}};
    private _type = if (_isTalking) then {_micMarkerType} else {_markerType};
    _markerEntries pushBack [_vehicleKey, getPosVisual _vehicle, getDir _vehicle, _label, _type, _color];
    if (_isTalking) then {_micDrawEntries pushBack [getPosVisual _vehicle];};
} forEach (keys _vehicleGroups);

private _activeKeys = [];
{
    _x params ["_key", "_position", "_direction", "_label", "_type", "_color"];
    _activeKeys pushBack _key;
    private _markerName = _markers getOrDefault [_key, ""];
    if (_markerName isEqualTo "") then {
        private _safeKey = (_key splitString ":" joinString "_");
        _markerName = format ["BN_KOTH_playerMapMarkers_%1", _safeKey];
        createMarkerLocal [_markerName, _position];
        _markers set [_key, _markerName];
        _markerName setMarkerShapeLocal "ICON";
        _markerName setMarkerSizeLocal [1, 1];
    };
    _markerName setMarkerPosLocal _position;
    _markerName setMarkerDirLocal _direction;
    _markerName setMarkerTypeLocal _type;
    _markerName setMarkerTextLocal _label;
    _markerName setMarkerColorLocal _color;
    _markerName setMarkerAlphaLocal _alpha;
    _markerName setMarkerShadowLocal (if (_markerShadow isEqualType true) then {_markerShadow} else {(_markerShadow > 0)});
} forEach _markerEntries;

{
    if !(_x in _activeKeys) then {
        deleteMarkerLocal (_markers get _x);
        _markers deleteAt _x;
    };
} forEach (keys _markers);

missionNamespace setVariable ["BN_KOTH_playerMapMarkersMarkers", _markers];
uiNamespace setVariable ["BN_KOTH_playerMapMarkersMicDrawEntries", _micDrawEntries];
count _markerEntries

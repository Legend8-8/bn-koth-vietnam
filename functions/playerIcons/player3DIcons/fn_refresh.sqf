/*
    File: fn_refresh.sqf
    Author: tylervip
    Description: Rebuilds the client-local 3D-friendly same-side player icon list.
    Execution: Client
    Parameters: None
    Returns: Number of cached friendly icons <NUMBER>
    Public: Yes
*/

if (!hasInterface || {isNull player} || {!alive player}) exitWith {0};
if !(missionNamespace getVariable ["BN_KOTH_player3DIconsEnabled", true]) exitWith {0};

private _playerAssignments = missionNamespace getVariable ["BN_KOTH_playerTeamAssignments", createHashMap];
if !(_playerAssignments isEqualType createHashMap) then {
    _playerAssignments = createHashMap;
};

private _myUid = getPlayerUID player;
private _mySide = _playerAssignments getOrDefault [_myUid, side group player];
if !([_mySide] call bn_koth_fnc_teams_validateSide) then {
    _mySide = side group player;
};
if !([_mySide] call bn_koth_fnc_teams_validateSide) exitWith {0};

private _activeParticipants = missionNamespace getVariable ["BN_KOTH_activeParticipants", []];
private _playerStates = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
if !(_playerStates isEqualType createHashMap) then {
    _playerStates = createHashMap;
};

private _activeLookup = createHashMap;
{
    _activeLookup set [_x, true];
} forEach _activeParticipants;

private _maxDistance = missionNamespace getVariable ["BN_KOTH_player3DIconsMaxDistance", 250];
if (_maxDistance <= 0) then {_maxDistance = 250;};
private _westColor = missionNamespace getVariable ["BN_KOTH_player3DIconsWestColor", [0.2, 0.55, 1.0, 0.95]];
private _eastColor = missionNamespace getVariable ["BN_KOTH_player3DIconsEastColor", [0.95, 0.2, 0.15, 0.95]];
private _sameGroupColor = missionNamespace getVariable ["BN_KOTH_player3DIconsSameGroupColor", [0.95, 0.9, 0.3, 0.9]];
private _friendlyTexture = missionNamespace getVariable ["BN_KOTH_player3DIconsTexture", "\A3\ui_f\data\map\markers\military\triangle_CA.paa"];
private _height = missionNamespace getVariable ["BN_KOTH_player3DIconsHeight", 2.2];
private _drawEntries = [];
private _debugLocalSelf = missionNamespace getVariable ["BN_KOTH_player3DIconsDebugLocalSelf", false];

if (_debugLocalSelf && {!isNull player} && {alive player}) then {
    private _playerHeadPos = player modelToWorldVisual (player selectionPosition "neck");
    _drawEntries pushBack [
        _playerHeadPos,
        180,
        "",
        _friendlyTexture,
        [1, 1, 1, 1],
        false
    ];
};

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
    && {_assignedSide isEqualTo _mySide}
    && {_isActiveParticipant || {_isActiveState}}
    && {player distance2D _unit <= _maxDistance}
};

{
    private _unit = _x;
    private _unitPos = _unit modelToWorldVisual (_unit selectionPosition "neck");

    private _sameGroup = group _unit isEqualTo group player;
    private _color = if (_sameGroup) then {_sameGroupColor} else {
        if (side group _unit isEqualTo west) then {_westColor} else {_eastColor}
    };

    _drawEntries pushBack [
        _unitPos,
        180,
        "",
        _friendlyTexture,
        _color,
        false
    ];
} forEach _eligiblePlayers;

uiNamespace setVariable ["BN_KOTH_player3DIconsDrawData", _drawEntries];
count _drawEntries
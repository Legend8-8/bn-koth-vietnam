/*
    File: fn_startPlacement.sqf
    Author: tylervip
    Description: Creates a local ghost object and handles placement preview, rotation, and confirm/cancel.
    Execution: Client
    Parameters: None
    Returns: None
    Public: Yes
*/

if (!hasInterface) exitWith {};
if !(call bn_koth_fnc_build_canBuild) exitWith {};

private _className = missionNamespace getVariable ["BN_KOTH_buildPlacementClass", ""];
if (_className isEqualTo "") exitWith {hint "No build item selected.";};

private _ghost = createVehicleLocal [_className, [0,0,0], [], 0, "CAN_COLLIDE"];
_ghost setDamage 0;
_ghost allowDamage false;
_ghost enableSimulation false;
_ghost setVariable ["BN_KOTH_buildGhost", true, true];
_ghost hideObject false;

missionNamespace setVariable ["BN_KOTH_buildGhost", _ghost];
missionNamespace setVariable ["BN_KOTH_buildPlacementRotation", 0];

private _loop = [_ghost, _className] spawn {
    params ["_ghost", "_className"];

    private _cancel = false;
    private _placed = false;

    while {missionNamespace getVariable ["BN_KOTH_buildPlacementActive", false] && {!isNull _ghost}} do {
        if !(alive player) exitWith {
            missionNamespace setVariable ["BN_KOTH_buildPlacementActive", false];
            if !(isNull _ghost) then {deleteVehicle _ghost;};
            missionNamespace setVariable ["BN_KOTH_buildGhost", objNull];
        };

        private _eyePos = eyePos player;
        private _dir = direction player;
        private _intersection = screenToWorld [(0.5 * safeZoneW + safeZoneX), (0.5 * safeZoneH + safeZoneY)];
        private _rayDir = vectorNormalized (_intersection vectorDiff _eyePos);
        private _target = _eyePos vectorAdd (_rayDir vectorMultiply 5);
        private _groundPos = lineIntersectsSurfaces [_eyePos, _target, player, objNull, true, 1, "GEOM", "NONE"];

        private _previewPos = _eyePos vectorAdd (_rayDir vectorMultiply 4);
        private _canPlace = false;

        if !(_groundPos isEqualTo []) then {
            private _hit = _groundPos select 0;
            private _pos = _hit select 0;
            private _distance = player distance2D _pos;
            private _minDistance = getNumber (missionConfigFile >> "CfgBnKothBuild" >> "placeDistanceMin");
            private _maxDistance = getNumber (missionConfigFile >> "CfgBnKothBuild" >> "placeDistanceMax");

            if (_distance >= _minDistance && {_distance <= _maxDistance}) then {
                _previewPos = [_pos select 0, _pos select 1, (_pos select 2) + 0.05];
                _canPlace = true;
            };
        };

        private _dirOffset = missionNamespace getVariable ["BN_KOTH_buildPlacementRotation", 0];
        _ghost setPosATL _previewPos;
        _ghost setDir (_dir + _dirOffset);
        _ghost hideObject !(_canPlace);

        if (inputAction "reload" > 0) then {
            private _rotation = missionNamespace getVariable ["BN_KOTH_buildPlacementRotation", 0];
            missionNamespace setVariable ["BN_KOTH_buildPlacementRotation", (_rotation + 15) % 360];
            waitUntil {inputAction "reload" <= 0;};
        };

        if (inputAction "pushToTalk" > 0) then {
            _cancel = true;
            missionNamespace setVariable ["BN_KOTH_buildPlacementActive", false];
            break;
        };

        if (inputAction "MenuBack" > 0) then {
            _cancel = true;
            missionNamespace setVariable ["BN_KOTH_buildPlacementActive", false];
            break;
        };

        if ((inputAction "Action" > 0) || {inputAction "fire" > 0}) then {
            if (_canPlace) then {
                _placed = true;
                missionNamespace setVariable ["BN_KOTH_buildPlacementActive", false];
                break;
            };
        };

        sleep 0.05;
    };

    if (_cancel || {!_placed}) then {
        [] call bn_koth_fnc_build_cancelPlacement;
    } else {
        private _position = getPosATL _ghost;
        private _direction = getDir _ghost;
        private _catalogKey = missionNamespace getVariable ["BN_KOTH_buildPlacementKey", ""];
        [_className, _position, _direction, _catalogKey] call bn_koth_fnc_build_requestPlace;
    };
};

missionNamespace setVariable ["BN_KOTH_buildPlacementLoop", _loop];

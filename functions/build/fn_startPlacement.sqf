/*
    File: fn_startPlacement.sqf
    Author: tylervip
    Description: Creates a local ghost object and handles placement preview, rotation, height, and confirm/cancel.
    Execution: Client
    Parameters: None
    Returns: None
    Public: Yes
*/

if (!hasInterface) exitWith {};
if !(call bn_koth_fnc_build_canBuild) exitWith {};

private _className = missionNamespace getVariable ["BN_KOTH_buildPlacementClass", ""];
if (_className isEqualTo "") exitWith {hint "No build item selected.";};

private _selectedKey = missionNamespace getVariable ["BN_KOTH_buildPlacementKey", ""];

// Clean up any previous placement state without losing the newly selected key/class.
[] call bn_koth_fnc_build_cancelPlacement;
missionNamespace setVariable ["BN_KOTH_buildPlacementKey", _selectedKey];
missionNamespace setVariable ["BN_KOTH_buildPlacementClass", _className];

private _ghostModel = getText (configFile >> "CfgVehicles" >> _className >> "model");
if (_ghostModel isEqualTo "") exitWith {hint "Selected build item has no preview model.";};
private _ghost = createSimpleObject [_ghostModel, [0,0,0], true];
_ghost setDamage 0;
_ghost allowDamage false;
_ghost enableSimulation false;
_ghost setVariable ["BN_KOTH_buildGhost", true]; // local only
_ghost hideObject false;

private _placementHeightMin = getNumber (missionConfigFile >> "CfgBnKothBuild" >> "placementHeightMin");
private _placementHeightMax = getNumber (missionConfigFile >> "CfgBnKothBuild" >> "placementHeightMax");
private _placementHeightStep = getNumber (missionConfigFile >> "CfgBnKothBuild" >> "placementHeightStep");
private _placementHeightStepShift = getNumber (missionConfigFile >> "CfgBnKothBuild" >> "placementHeightStepShift");
private _placementRotationStep = getNumber (missionConfigFile >> "CfgBnKothBuild" >> "placementRotationStep");
private _placementRotationStepShift = getNumber (missionConfigFile >> "CfgBnKothBuild" >> "placementRotationStepShift");
if (_placementHeightMin >= _placementHeightMax) then {
    _placementHeightMin = -0.5;
    _placementHeightMax = 2;
};
if (_placementHeightStep <= 0) then {_placementHeightStep = 0.05};
if (_placementHeightStepShift <= 0) then {_placementHeightStepShift = 0.25};
if (_placementRotationStep <= 0) then {_placementRotationStep = 15};
if (_placementRotationStepShift <= 0) then {_placementRotationStepShift = 45};

missionNamespace setVariable ["BN_KOTH_buildGhost", _ghost];
missionNamespace setVariable ["BN_KOTH_buildPlacementHeightStep", _placementHeightStep];
missionNamespace setVariable ["BN_KOTH_buildPlacementHeightStepShift", _placementHeightStepShift];
missionNamespace setVariable ["BN_KOTH_buildPlacementRotationStep", _placementRotationStep];
missionNamespace setVariable ["BN_KOTH_buildPlacementRotationStepShift", _placementRotationStepShift];
missionNamespace setVariable ["BN_KOTH_buildPlacementRotation", 0];
missionNamespace setVariable ["BN_KOTH_buildPlacementHeight", 0];
missionNamespace setVariable ["BN_KOTH_buildPlacementHeightOffset", 0];
missionNamespace setVariable ["BN_KOTH_buildPlacementHeightMin", _placementHeightMin];
missionNamespace setVariable ["BN_KOTH_buildPlacementHeightMax", _placementHeightMax];
missionNamespace setVariable ["BN_KOTH_buildPlacementActive", true];
missionNamespace setVariable ["BN_KOTH_buildPlacementCanPlace", false];
missionNamespace setVariable ["BN_KOTH_buildPlacementConfirmRequested", false];
missionNamespace setVariable ["BN_KOTH_buildPlacementCancelRequested", false];

// KeyDown handler for rotation + height
private _display = findDisplay 46;
private _eh = -1;

if (!isNull _display) then {
    private _oldEh = missionNamespace getVariable ["BN_KOTH_buildPlacementKeyDownEh", -1];
    if (_oldEh >= 0) then {
        _display displayRemoveEventHandler ["KeyDown", _oldEh];
    };

    _eh = _display displayAddEventHandler ["KeyDown", {
        params ["_display", "_key", "_shift", "_ctrl", "_alt"];

        if !(missionNamespace getVariable ["BN_KOTH_buildPlacementActive", false]) exitWith {false};

        switch (_key) do {
            case 0x01: { // DIK_ESCAPE
                missionNamespace setVariable ["BN_KOTH_buildPlacementCancelRequested", true];
                true
            };
            case 0x39: { // DIK_SPACE
                if (missionNamespace getVariable ["BN_KOTH_buildPlacementCanPlace", false]) then {
                    missionNamespace setVariable ["BN_KOTH_buildPlacementConfirmRequested", true];
                    true
                } else {
                    false
                };
            };
            case 0x10: { // DIK_Q
                private _rot = missionNamespace getVariable ["BN_KOTH_buildPlacementRotation", 0];
                private _step = if (_shift) then {missionNamespace getVariable ["BN_KOTH_buildPlacementRotationStepShift", 45]} else {missionNamespace getVariable ["BN_KOTH_buildPlacementRotationStep", 15]};
                missionNamespace setVariable ["BN_KOTH_buildPlacementRotation", _rot - _step];
                true
            };
            case 0x12: { // DIK_E
                private _rot = missionNamespace getVariable ["BN_KOTH_buildPlacementRotation", 0];
                private _step = if (_shift) then {missionNamespace getVariable ["BN_KOTH_buildPlacementRotationStepShift", 45]} else {missionNamespace getVariable ["BN_KOTH_buildPlacementRotationStep", 15]};
                missionNamespace setVariable ["BN_KOTH_buildPlacementRotation", _rot + _step];
                true
            };
            case 0x2C: { // DIK_Z
                private _h = missionNamespace getVariable ["BN_KOTH_buildPlacementHeight", 0];
                private _min = missionNamespace getVariable ["BN_KOTH_buildPlacementHeightMin", -0.5];
                private _step = if (_shift) then {missionNamespace getVariable ["BN_KOTH_buildPlacementHeightStepShift", 0.25]} else {missionNamespace getVariable ["BN_KOTH_buildPlacementHeightStep", 0.05]};
                missionNamespace setVariable ["BN_KOTH_buildPlacementHeight", ((_h - _step) max _min)];
                missionNamespace setVariable ["BN_KOTH_buildPlacementHeightOffset", missionNamespace getVariable ["BN_KOTH_buildPlacementHeight", 0]];
                true
            };
            case 0x2D: { // DIK_X
                private _h = missionNamespace getVariable ["BN_KOTH_buildPlacementHeight", 0];
                private _max = missionNamespace getVariable ["BN_KOTH_buildPlacementHeightMax", 2];
                private _step = if (_shift) then {missionNamespace getVariable ["BN_KOTH_buildPlacementHeightStepShift", 0.25]} else {missionNamespace getVariable ["BN_KOTH_buildPlacementHeightStep", 0.05]};
                missionNamespace setVariable ["BN_KOTH_buildPlacementHeight", ((_h + _step) min _max)];
                missionNamespace setVariable ["BN_KOTH_buildPlacementHeightOffset", missionNamespace getVariable ["BN_KOTH_buildPlacementHeight", 0]];
                true
            };
            default { false };
        };
    }];

    missionNamespace setVariable ["BN_KOTH_buildPlacementKeyDownEh", _eh];
};

private _loop = [_ghost, _className] spawn {
    params ["_ghost", "_className"];

    private _cancel = false;
    private _placed = false;

    private _minDistance = getNumber (missionConfigFile >> "CfgBnKothBuild" >> "placeDistanceMin");
    private _maxDistance = getNumber (missionConfigFile >> "CfgBnKothBuild" >> "placeDistanceMax");
    if (_minDistance <= 0) then {_minDistance = 2};
    if (_maxDistance <= 0) then {_maxDistance = 12};

    while {missionNamespace getVariable ["BN_KOTH_buildPlacementActive", false] && {!isNull _ghost}} do {
        if !(alive player) exitWith {
            missionNamespace setVariable ["BN_KOTH_buildPlacementActive", false];
            if !(isNull _ghost) then {deleteVehicle _ghost};
            missionNamespace setVariable ["BN_KOTH_buildGhost", objNull];
        };

        private _eyePos = eyePos player;
        private _playerDir = getDir player;
        private _screenPos = screenToWorld [0.5, 0.5];
        private _rayDir = if ((_screenPos distance2D _eyePos) > 0.001) then {vectorNormalized (_screenPos vectorDiff _eyePos)} else {[0,0,0]};
        private _placementDistance = (_minDistance + _maxDistance) / 2;
        private _horizontalRayDir = vectorNormalized [_rayDir select 0, _rayDir select 1, 0];
        private _previewPos = _eyePos vectorAdd (_horizontalRayDir vectorMultiply _placementDistance);
        private _canPlace = false;
        private _surfaceHit = false;

        private _intersections = lineIntersectsSurfaces [
            _eyePos,
            _eyePos vectorAdd (_rayDir vectorMultiply (_maxDistance + 3)),
            player,
            _ghost,
            true,
            1,
            "GEOM",
            "NONE"
        ];

        if (_intersections isNotEqualTo []) then {
            _surfaceHit = true;
            private _hit = _intersections select 0;
            private _posASL = _hit select 0;
            private _posATL = ASLToATL _posASL;
            private _distance = player distance2D _posATL;

            if (_distance >= _minDistance && {_distance <= _maxDistance}) then {
                private _heightOffset = missionNamespace getVariable ["BN_KOTH_buildPlacementHeight", 0];
                missionNamespace setVariable ["BN_KOTH_buildPlacementHeightOffset", _heightOffset];
                _previewPos = [
                    _posATL select 0,
                    _posATL select 1,
                    (_posATL select 2) + 0.02 + _heightOffset
                ];
                _canPlace = true;
            } else {
                _canPlace = false;
            };
        } else {
            // If nothing is hit in front of the camera, the player is effectively looking at empty sky.
            // Treat that as invalid placement rather than allowing a preview to float in mid-air.
            _canPlace = false;
            _surfaceHit = false;
        };

        // Keep the actual placement validity explicit for confirm logic.
        if !(_surfaceHit) then {_canPlace = false};

        missionNamespace setVariable ["BN_KOTH_buildPlacementCanPlace", _canPlace];

        private _dirOffset = missionNamespace getVariable ["BN_KOTH_buildPlacementRotation", 0];
        _ghost setPosATL _previewPos;
        _ghost setDir (_playerDir + _dirOffset);

        // Placement validity gates Space confirmation; it does not hide the preview.
    _ghost hideObject !(_canPlace);

        if (missionNamespace getVariable ["BN_KOTH_buildPlacementCancelRequested", false]) then {
            missionNamespace setVariable ["BN_KOTH_buildPlacementCancelRequested", false];
            _cancel = true;
            missionNamespace setVariable ["BN_KOTH_buildPlacementActive", false];
            break;
        };

        if (missionNamespace getVariable ["BN_KOTH_buildPlacementConfirmRequested", false]) then {
            missionNamespace setVariable ["BN_KOTH_buildPlacementConfirmRequested", false];
            _placed = true;
            missionNamespace setVariable ["BN_KOTH_buildPlacementActive", false];
            break;
        };

        sleep 0.03;
    };

    private _display = findDisplay 46;
    private _eh = missionNamespace getVariable ["BN_KOTH_buildPlacementKeyDownEh", -1];
    if (!isNull _display && {_eh >= 0}) then {
        _display displayRemoveEventHandler ["KeyDown", _eh];
    };
    missionNamespace setVariable ["BN_KOTH_buildPlacementKeyDownEh", -1];

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
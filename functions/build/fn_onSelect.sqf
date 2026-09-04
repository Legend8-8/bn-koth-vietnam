/*
    File: fn_onSelect.sqf
    Author: tylervip
    Description: Handles a wheel-menu selection and begins placement preview.
    Execution: Client
    Parameters:
        0: Catalog key <STRING>
    Returns: None
    Public: Yes
*/

params ["_selection"];

private _catalogKey = "";
private _catalogKeys = missionNamespace getVariable ["BN_KOTH_buildCatalogKeys", []];

diag_log format ["[BN_KOTH Build] fn_onSelect selection=%1", _selection];

private _resolveByIndex = {
    params ["_value", "_keys"];

    if !(_value isEqualType 0) exitWith {""};
    if (_value < 0 || {_value >= count _keys}) exitWith {""};
    _keys select _value
};

if (_selection isEqualType "") then {
    _catalogKey = _selection;
} else {
    if (_selection isEqualType 0) then {
        _catalogKey = [_selection, _catalogKeys] call _resolveByIndex;
    } else {
        if (_selection isEqualType []) then {
            private _queue = +_selection;

            while {(count _queue) > 0 && {_catalogKey isEqualTo ""}} do {
                private _entry = _queue deleteAt 0;

                if (_entry isEqualType "") then {
                    private _candidate = _entry;
                    if (_candidate isNotEqualTo "") then {
                        if (isClass (missionConfigFile >> "CfgBnKothBuild" >> "Objects" >> _candidate)) then {
                            _catalogKey = _candidate;
                        };
                    };
                } else {
                    if (_entry isEqualType 0) then {
                        _catalogKey = [_entry, _catalogKeys] call _resolveByIndex;
                    } else {
                        if (_entry isEqualType []) then {
                            _queue append _entry;
                        };
                    };
                };
            };
        };
    };
};

if !(_catalogKey isEqualType "") exitWith {
    diag_log format ["[BN_KOTH Build] Invalid catalog key type: %1", typeName _catalogKey];
    hint "Selected build item is not configured.";
};

if (_catalogKey isEqualTo "") exitWith {
    diag_log "[BN_KOTH Build] fn_onSelect rejected empty catalog key.";
    hint "No valid build item selected.";
};
if !(call bn_koth_fnc_build_canBuild) exitWith {};
if (missionNamespace getVariable ["BN_KOTH_buildPlacementActive", false]) exitWith {};

private _root = missionConfigFile >> "CfgBnKothBuild" >> "Objects" >> _catalogKey;
if !(isClass _root) exitWith {
    diag_log format ["[BN_KOTH Build] Catalog key not configured: %1", _catalogKey];
    hint "Selected build item is not configured.";
};

private _className = getText (_root >> "classname");
if (_className isEqualTo "") exitWith {
    diag_log format ["[BN_KOTH Build] Missing classname for key: %1", _catalogKey];
    hint "Selected build item has no class name.";
};

diag_log format ["[BN_KOTH Build] Resolved build key=%1 class=%2", _catalogKey, _className];
missionNamespace setVariable ["BN_KOTH_buildPlacementActive", true];
missionNamespace setVariable ["BN_KOTH_buildPlacementKey", _catalogKey];
missionNamespace setVariable ["BN_KOTH_buildPlacementClass", _className];

[] call bn_koth_fnc_build_startPlacement;

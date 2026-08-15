/*
    File: fn_initPlayerLocal.sqf
    Author: Mongo
    Description: Installs local safe-zone physical-inventory enforcement on the current player representation.
    Execution: Client
    Parameters:
        None
    Returns:
        True when the current player representation is initialized <BOOL>
    Public: Yes
*/

if (!hasInterface) exitWith {false};
if (isNull player) exitWith {false};

private _unit = player;

if !(_unit getVariable ["BN_KOTH_inventoryOpenedEhLocal", false]) then {
    _unit addEventHandler ["InventoryOpened", {
        params ["_unit", "_primaryContainer", "_secondaryContainer"];

        private _locked = [_unit, _primaryContainer, _secondaryContainer] call bn_koth_fnc_loadouts_isInventoryLocked;
        if (_locked) then {
            [true] call bn_koth_fnc_loadouts_forceCloseInventory;
        } else {
            private _sessionId = (uiNamespace getVariable ["BN_KOTH_inventorySessionId", 0]) + 1;
            uiNamespace setVariable ["BN_KOTH_inventorySessionId", _sessionId];

            [_unit, _primaryContainer, _secondaryContainer, _sessionId] spawn {
                params ["_unit", "_primaryContainer", "_secondaryContainer", "_sessionId"];

                private _openDeadline = diag_tickTime + 1;
                waitUntil {
                    uiSleep 0.01;
                    !isNull (findDisplay 602)
                        || {diag_tickTime >= _openDeadline}
                        || {(uiNamespace getVariable ["BN_KOTH_inventorySessionId", -1]) != _sessionId}
                };

                while {
                    !isNull (findDisplay 602)
                        && {(uiNamespace getVariable ["BN_KOTH_inventorySessionId", -1]) isEqualTo _sessionId}
                } do {
                    if ([_unit, _primaryContainer, _secondaryContainer] call bn_koth_fnc_loadouts_isInventoryLocked) exitWith {
                        [true] call bn_koth_fnc_loadouts_forceCloseInventory;
                    };

                    uiSleep 0.1;
                };
            };
        };

        _locked
    }];
    _unit setVariable ["BN_KOTH_inventoryOpenedEhLocal", true, false];
};

if !(_unit getVariable ["BN_KOTH_inventoryClosedEhLocal", false]) then {
    _unit addEventHandler ["InventoryClosed", {
        uiNamespace setVariable [
            "BN_KOTH_inventorySessionId",
            (uiNamespace getVariable ["BN_KOTH_inventorySessionId", 0]) + 1
        ];
    }];
    _unit setVariable ["BN_KOTH_inventoryClosedEhLocal", true, false];
};

if !(_unit getVariable ["BN_KOTH_inventoryPutEhLocal", false]) then {
    _unit addEventHandler ["Put", {
        params ["_unit", "_container"];

        if ([_unit, _container, objNull] call bn_koth_fnc_loadouts_isInventoryLocked) then {
            [true] call bn_koth_fnc_loadouts_forceCloseInventory;
        };
    }];
    _unit setVariable ["BN_KOTH_inventoryPutEhLocal", true, false];
};

if !(_unit getVariable ["BN_KOTH_inventoryTakeEhLocal", false]) then {
    _unit addEventHandler ["Take", {
        params ["_unit", "_container"];

        if ([_unit, _container, objNull] call bn_koth_fnc_loadouts_isInventoryLocked) then {
            [true] call bn_koth_fnc_loadouts_forceCloseInventory;
        };
    }];
    _unit setVariable ["BN_KOTH_inventoryTakeEhLocal", true, false];
};

if !(missionNamespace getVariable ["BN_KOTH_loadoutsLocalMissionEhAdded", false]) then {
    private _eventId = addMissionEventHandler ["EntityRespawned", {
        params ["_newEntity"];

        if (hasInterface && {!isNull _newEntity} && {_newEntity isEqualTo player}) then {
            [] call bn_koth_fnc_loadouts_initPlayerLocal;
        };
    }];

    missionNamespace setVariable ["BN_KOTH_loadoutsLocalMissionEhAdded", true];
    missionNamespace setVariable ["BN_KOTH_loadoutsLocalMissionEhId", _eventId];
};

true

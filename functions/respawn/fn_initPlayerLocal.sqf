/*
    File: fn_initPlayerLocal.sqf
    Author: Mongo
    Description: Installs locality-safe player enforcement for active base safe zones.
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

if !(_unit getVariable ["BN_KOTH_safeZoneDamageEhLocal", false]) then {
    _unit addEventHandler ["HandleDamage", {
        _this call bn_koth_fnc_respawn_handleDamage
    }];
    _unit setVariable ["BN_KOTH_safeZoneDamageEhLocal", true, false];
};

if !(_unit getVariable ["BN_KOTH_safeZoneFiredEhLocal", false]) then {
    _unit addEventHandler ["FiredMan", {
        _this call bn_koth_fnc_respawn_handleFired
    }];
    _unit setVariable ["BN_KOTH_safeZoneFiredEhLocal", true, false];
};

if !(_unit getVariable ["BN_KOTH_safeZoneGetInEhLocal", false]) then {
    _unit addEventHandler ["GetInMan", {
        params ["_unit"];

        if (_unit getVariable ["BN_KOTH_enemySafeZoneIntruder", false]) then {
            moveOut _unit;

            private _now = diag_tickTime;
            private _nextMessageAt = uiNamespace getVariable ["BN_KOTH_safeZoneNextBlockedMessageAt", -1];
            if (_now >= _nextMessageAt) then {
                private _cooldown = missionNamespace getVariable ["BN_KOTH_safeZoneMessageCooldownSeconds", 1];
                uiNamespace setVariable ["BN_KOTH_safeZoneNextBlockedMessageAt", _now + _cooldown];
                ["Enemy safe zone: weapons and vehicles are disabled."] call bn_koth_fnc_ui_notify;
            };
        };
    }];
    _unit setVariable ["BN_KOTH_safeZoneGetInEhLocal", true, false];
};

if !(missionNamespace getVariable ["BN_KOTH_respawnLocalMissionEhAdded", false]) then {
    private _eventId = addMissionEventHandler ["EntityRespawned", {
        params ["_newEntity"];

        if (hasInterface && {!isNull _newEntity} && {_newEntity isEqualTo player}) then {
            [] call bn_koth_fnc_respawn_initPlayerLocal;
        };
    }];

    missionNamespace setVariable ["BN_KOTH_respawnLocalMissionEhAdded", true];
    missionNamespace setVariable ["BN_KOTH_respawnLocalMissionEhId", _eventId];
};

true

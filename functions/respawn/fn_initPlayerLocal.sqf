/*
    File: fn_initPlayerLocal.sqf
    Author: Mongo
    Edited: Legend
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
[_unit] call bn_koth_fnc_progression_perks_applyMedicTraitLocal;

// S.O.G. completes Resuscitate on the acting client. Preserve the native
// function as the sole revive/item owner and observe only its genuine hold-
// action completion callback so the server can validate a reward candidate.
if !(missionNamespace getVariable ["BN_KOTH_reviveRewardObserverInstalledLocal", false]) then {
    if (isNil "VN_fnc_revive_action_revive") then {
        ["S.O.G. revive reward observer could not find VN_fnc_revive_action_revive", "WARN"] call bn_koth_fnc_common_log;
    } else {
        missionNamespace setVariable ["BN_KOTH_nativeReviveActionReviveLocal", VN_fnc_revive_action_revive];
        missionNamespace setVariable ["VN_fnc_revive_action_revive", {
            params [
                ["_object", objNull, [objNull]],
                ["_type", -1, [0]]
            ];

            private _nativeCaller = if (isNil "_caller") then {objNull} else {_caller};
            private _nativeTarget = if (isNil "_target") then {objNull} else {_target};
            private _nativeActionId = if (isNil "_actionID") then {-1} else {_actionID};
            private _nativeActionIds = if (isNull _object) then {
                []
            } else {
                _object getVariable ["_vn_revive_actions_local_array", []]
            };
            private _isNativeCompletion = _type isEqualTo 3
                && {!isNull _object}
                && {_object isEqualTo _nativeTarget}
                && {!isNull _nativeCaller}
                && {_nativeCaller isEqualTo player}
                && {_nativeActionIds isEqualType []}
                && {_nativeActionId in _nativeActionIds};

            private _nativeFunction = missionNamespace getVariable ["BN_KOTH_nativeReviveActionReviveLocal", {}];
            private _result = _this call _nativeFunction;

            if (_isNativeCompletion) then {
                [_object] remoteExecCall ["bn_koth_fnc_respawn_reportReviveState", 2];
            };

            _result
        }];
        missionNamespace setVariable ["BN_KOTH_reviveRewardObserverInstalledLocal", true];
    };
};

if !(_unit getVariable ["BN_KOTH_safeZoneDamageEhLocal", false]) then {
    private _damageEhId = _unit addEventHandler ["HandleDamage", {
        _this call bn_koth_fnc_respawn_handleDamage
    }];
    _unit setVariable ["BN_KOTH_safeZoneDamageEhLocal", true, false];
    _unit setVariable ["BN_KOTH_safeZoneDamageEhIdLocal", _damageEhId, false];
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

if !(_unit getVariable ["BN_KOTH_downedKilledEhLocal", false]) then {
    _unit addEventHandler ["Killed", {
        params ["_killed"];
        if (_killed isEqualTo player) then {
            [true] call bn_koth_fnc_respawn_updateDownedPresentation;
        };
    }];
    _unit setVariable ["BN_KOTH_downedKilledEhLocal", true, false];
};

if !(missionNamespace getVariable ["BN_KOTH_respawnLocalMissionEhAdded", false]) then {
    private _eventId = addMissionEventHandler ["EntityRespawned", {
        params ["_newEntity"];

        if (hasInterface && {!isNull _newEntity} && {_newEntity isEqualTo player}) then {
            [true] call bn_koth_fnc_respawn_updateDownedPresentation;
            [] call bn_koth_fnc_respawn_initPlayerLocal;
        };
    }];

    missionNamespace setVariable ["BN_KOTH_respawnLocalMissionEhAdded", true];
    missionNamespace setVariable ["BN_KOTH_respawnLocalMissionEhId", _eventId];
};

true

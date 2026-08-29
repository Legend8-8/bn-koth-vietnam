/*
    File: fn_refreshLobbyLeaders.sqf
    Author: Legend
    Description: Renders the server-owned Live Leaders projection into the existing lobby cards.
    Execution: Client
    Parameters:
        0: Lobby display <DISPLAY>
    Returns:
        None
    Public: No
*/

#include "..\..\..\ui\lobby\idcs.hpp"

params [["_display", displayNull, [displayNull]]];

if (!hasInterface) exitWith {};
if (isNull _display) exitWith {};

private _leaders = missionNamespace getVariable ["BN_KOTH_liveLeaders", createHashMap];
if !(_leaders isEqualType createHashMap) then {_leaders = createHashMap};

private _renderLeader = {
    params ["_key", "_nameIdc", "_valueIdc", "_suffixSingular", "_suffixPlural"];

    private _entry = _leaders getOrDefault [_key, createHashMap];
    if !(_entry isEqualType createHashMap) then {_entry = createHashMap};

    private _name = _entry getOrDefault ["name", ""];
    private _value = _entry getOrDefault ["value", 0];

    private _nameCtrl = _display displayCtrl _nameIdc;
    private _valueCtrl = _display displayCtrl _valueIdc;

    if (_name isEqualTo "" || {_value <= 0}) then {
        _nameCtrl ctrlSetText "NO LEADER";
        _valueCtrl ctrlSetText format ["0 %1", _suffixPlural];
    } else {
        _nameCtrl ctrlSetText ([_nameCtrl, _name] call bn_koth_fnc_ui_fitLobbyName);
        _valueCtrl ctrlSetText format [
            "%1 %2",
            _value,
            if (_value isEqualTo 1) then {_suffixSingular} else {_suffixPlural}
        ];
    };
};

["mostDeadly", BN_KOTH_IDC_BOTTOM_LEADER_1_NAME, BN_KOTH_IDC_BOTTOM_LEADER_1_VALUE, "KILL", "KILLS"] call _renderLeader;
["objective", BN_KOTH_IDC_BOTTOM_LEADER_2_NAME, BN_KOTH_IDC_BOTTOM_LEADER_2_VALUE, "PT", "PTS"] call _renderLeader;
["bestStreak", BN_KOTH_IDC_BOTTOM_LEADER_3_NAME, BN_KOTH_IDC_BOTTOM_LEADER_3_VALUE, "KILL", "KILLS"] call _renderLeader;

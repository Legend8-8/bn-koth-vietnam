/*
    File: fn_applyMedicTraitLocal.sqf
    Author: Legend
    Description: Mirrors the server-projected MEDIC perk onto the current local,
        deployed gameplay representation as Arma's derived Medic trait.
    Execution: Client, where the current player unit is local
    Parameters:
        0: Representation to update (optional, default: player) <OBJECT>
    Returns:
        True when Medic is enabled on the representation <BOOL>
    Public: No
*/

params [["_unit", player, [objNull]]];

if (!hasInterface || {isNull _unit} || {!local _unit}) exitWith {false};

private _isCurrent = _unit isEqualTo player;
private _uid = if (_isCurrent) then {getPlayerUID _unit} else {""};
private _states = missionNamespace getVariable ["BN_KOTH_playerStates", createHashMap];
if !(_states isEqualType createHashMap) then {_states = createHashMap};
private _playableSides = missionNamespace getVariable ["BN_KOTH_playableSides", [west, east]];
if ((count _playableSides) < 2) then {_playableSides = [west, east]};

private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
if !(_progression isEqualType createHashMap) then {_progression = createHashMap};
private _activePerks = _progression getOrDefault ["activePerks", []];
if !(_activePerks isEqualType []) then {_activePerks = []};
_activePerks = _activePerks apply {toLower _x};

private _enabled = _isCurrent
    && {_uid isNotEqualTo ""}
    && {(side group _unit) in _playableSides}
    && {(_states getOrDefault [_uid, "LOBBY"]) isEqualTo "ACTIVE"}
    && {"medic" in _activePerks};

_unit setUnitTrait ["Medic", _enabled];
_enabled

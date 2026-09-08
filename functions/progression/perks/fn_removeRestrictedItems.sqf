/*
    File: fn_removeRestrictedItems.sqf
    Author: Legend
    Description: Returns a managed Unit Loadout with one perk's explicitly
        restricted item classes removed from weapon slots and container cargo.
    Execution: Any
    Parameters:
        0: Unit loadout <ARRAY>
        1: Perk id <STRING>
    Returns:
        Sanitized Unit Loadout, or empty array for invalid input <ARRAY>
    Public: No
*/

params [
    ["_loadout", [], [[]]],
    ["_perkId", "", [""]]
];

private _metadata = [_perkId] call bn_koth_fnc_progression_perks_getConfig;
private _restricted = _metadata getOrDefault ["restrictedClasses", []];
if !(_metadata getOrDefault ["success", false] && {_restricted isEqualType []}) exitWith {[]};

_restricted = _restricted apply {toLower _x};
private _result = +_loadout;
if ((count _result) < 6) exitWith {[]};

{
    private _slot = +(_result param [_x, []]);
    if (_slot isEqualType []) then {
        for "_index" from 1 to ((count _slot) - 1) do {
            private _value = _slot select _index;
            if (_value isEqualType "" && {(toLower _value) in _restricted}) then {
                _slot set [_index, ""];
            };
        };
        _result set [_x, _slot];
    };
} forEach [0, 1, 2];

{
    private _container = +(_result param [_x, []]);
    if (_container isEqualType [] && {(count _container) > 1}) then {
        private _cargo = +(_container select 1);
        _cargo = _cargo select {
            !(
                _x isEqualType []
                && {(count _x) > 0}
                && {(_x select 0) isEqualType ""}
                && {(toLower (_x select 0)) in _restricted}
            )
        };
        _container set [1, _cargo];
        _result set [_x, _container];
    };
} forEach [3, 4, 5];

_result

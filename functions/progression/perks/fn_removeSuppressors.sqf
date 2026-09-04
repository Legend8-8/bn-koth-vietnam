/*
    File: fn_removeSuppressors.sqf
    Author: Legend
    Description: Returns a managed Unit Loadout with all factual suppressors removed.
    Execution: Any
    Public: No
*/
params [["_loadout", [], [[]]]];
private _result = +_loadout;
if ((count _result) < 6) exitWith {[]};
{
    private _slot = +(_result param [_x, []]);
    if (_slot isEqualType []) then {
        for "_index" from 1 to ((count _slot) - 1) do {
            private _value = _slot select _index;
            if (_value isEqualType "" && {[_value] call bn_koth_fnc_progression_perks_isSuppressor}) then {
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
            !(_x isEqualType [] && {(count _x) > 0} && {(_x select 0) isEqualType ""} && {[(_x select 0)] call bn_koth_fnc_progression_perks_isSuppressor})
        };
        _container set [1, _cargo];
        _result set [_x, _container];
    };
} forEach [3, 4, 5];
_result

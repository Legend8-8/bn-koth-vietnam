/*
    File: fn_findSuppressors.sqf
    Author: Legend
    Description: Finds factual suppressor attachments in every managed Unit Loadout weapon and cargo slot.
    Execution: Any
    Public: No
*/
params [["_loadout", [], [[]]]];
private _found = [];
if ((count _loadout) < 6) exitWith {_found};
{
    private _slot = _loadout param [_x, []];
    if (_slot isEqualType []) then {
        {
            if (_x isEqualType "" && {[_x] call bn_koth_fnc_progression_perks_isSuppressor}) then {
                _found pushBackUnique (toLower _x);
            };
        } forEach _slot;
    };
} forEach [0, 1, 2];
{
    private _container = _loadout param [_x, []];
    if (_container isEqualType [] && {(count _container) > 1}) then {
        private _cargo = _container select 1;
        if (_cargo isEqualType []) then {
            {
                if (_x isEqualType [] && {(count _x) > 0}) then {
                    private _class = _x select 0;
                    if (_class isEqualType "" && {[_class] call bn_koth_fnc_progression_perks_isSuppressor}) then {
                        _found pushBackUnique (toLower _class);
                    };
                };
            } forEach _cargo;
        };
    };
} forEach [3, 4, 5];
_found

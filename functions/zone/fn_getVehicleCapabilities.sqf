/*
    File: fn_getVehicleCapabilities.sqf
    Author: Legend
    Description: Resolves side-specific vehicle capability from actual convention-owned spawn roles.
    Execution: Server/Client
    Parameters:
        0: Resolved location data from bn_koth_fnc_zone_getLocationData <HASHMAP>
    Returns: Side-specific role and vehicle-family capability <HASHMAP>
    Public: Yes
*/

params [["_locationData", createHashMap, [createHashMap]]];

if ((count _locationData) <= 0) exitWith {createHashMapFromArray [["success", false], ["sides", createHashMap]]};

private _resolveRole = {
    params ["_roleRef"];

    private _result = createHashMapFromArray [
        ["exists", false], ["ref", _roleRef], ["kind", ""],
        ["position", []], ["direction", 0], ["object", objNull]
    ];
    if (_roleRef isEqualTo "") exitWith {_result};

    if ((markerShape _roleRef) isNotEqualTo "") exitWith {
        _result set ["exists", true];
        _result set ["kind", "MARKER"];
        _result set ["position", markerPos _roleRef];
        _result set ["direction", markerDir _roleRef];
        _result
    };

    private _candidate = missionNamespace getVariable [_roleRef, objNull];
    private _object = objNull;
    if (_candidate isEqualType objNull) then {
        _object = _candidate;
    } else {
        if (_candidate isEqualType []) then {
            private _index = _candidate findIf {_x isEqualType objNull && {!isNull _x}};
            if (_index >= 0) then {_object = _candidate select _index};
        };
    };

    if (!isNull _object) then {
        _result set ["exists", true];
        _result set ["kind", "OBJECT"];
        _result set ["position", getPosATL _object];
        _result set ["direction", getDir _object];
        _result set ["object", _object];
    };

    _result
};

private _sides = createHashMap;
{
    _x params ["_sideToken", "_prefix"];

    private _roles = createHashMap;
    {
        _x params ["_roleName", "_locationKey"];
        _roles set [_roleName, [_locationData getOrDefault [_locationKey, ""]] call _resolveRole];
    } forEach [
        ["FREE_GROUND", format ["%1FreeGround_spawnpoint", _prefix]],
        ["PAID_GROUND", format ["%1PaidGround_spawnpoint", _prefix]],
        ["FREE_AIR", format ["%1FreeAir_spawnpoint", _prefix]],
        ["PAID_AIR", format ["%1PaidAir_spawnpoint", _prefix]],
        ["FREE_SEA", format ["%1FreeSea_spawnpoint", _prefix]],
        ["PAID_SEA", format ["%1PaidSea_spawnpoint", _prefix]],
        ["COMMAND", format ["%1Command_spawnpoint", _prefix]]
    ];

    private _makeFamily = {
        params ["_freeRole", "_paidRole"];
        private _free = (_roles getOrDefault [_freeRole, createHashMap]) getOrDefault ["exists", false];
        private _paid = (_roles getOrDefault [_paidRole, createHashMap]) getOrDefault ["exists", false];
        createHashMapFromArray [["free", _free], ["paid", _paid], ["any", _free || _paid]]
    };

    private _families = createHashMapFromArray [
        ["GROUND", ["FREE_GROUND", "PAID_GROUND"] call _makeFamily],
        ["ROTARY", ["FREE_AIR", "PAID_AIR"] call _makeFamily],
        ["FIXED_WING", ["FREE_AIR", "PAID_AIR"] call _makeFamily],
        ["SEA", ["FREE_SEA", "PAID_SEA"] call _makeFamily],
        ["COMMAND", createHashMapFromArray [["spawn", (_roles get "COMMAND") getOrDefault ["exists", false]]]]
    ];

    _sides set [_sideToken, createHashMapFromArray [["roles", _roles], ["families", _families]]];
} forEach [["WEST", "west"], ["EAST", "east"]];

createHashMapFromArray [
    ["success", true],
    ["locationId", _locationData getOrDefault ["id", ""]],
    ["sides", _sides]
]

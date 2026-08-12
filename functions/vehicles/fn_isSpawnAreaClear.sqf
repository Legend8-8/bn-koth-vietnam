/*
    File: fn_isSpawnAreaClear.sqf
    Author: tylervip
    Description: Evaluates whether a vehicle spawn position is clear of nearby blocking players/vehicles.
    Execution: Server
    Parameters:
        0: Spawn position ATL/ASL position array <ARRAY>
        1: Blocking radius in meters <NUMBER>
        2: Vehicle to exclude from checks <OBJECT> (default: objNull)
        3: Include player blockers <BOOL> (default: true)
        4: Include vehicle blockers <BOOL> (default: true)
    Returns:
        Spawn-clear result map <HASHMAP>
    Public: Yes
*/

params [
    ["_spawnPos", [0, 0, 0], [[]]],
    ["_radius", 0, [0]],
    ["_excludedVehicle", objNull, [objNull]],
    ["_includePlayers", true, [true]],
    ["_includeVehicles", true, [true]]
];

if (!isServer) exitWith {
    createHashMapFromArray [
        ["isClear", true],
        ["playerBlockers", []],
        ["vehicleBlockers", []],
        ["playerDetails", []],
        ["vehicleDetails", []]
    ]
};

private _effectiveRadius = _radius max 0;
private _playerBlockers = [];
private _vehicleBlockers = [];
private _playerDetails = [];
private _vehicleDetails = [];

if (_includePlayers) then {
    _playerBlockers = allPlayers select {
        alive _x
        && {_x isKindOf "CAManBase"}
        && {_x distance2D _spawnPos <= _effectiveRadius}
    };

    {
        _playerDetails pushBack (createHashMapFromArray [
            ["name", name _x],
            ["uid", getPlayerUID _x],
            ["side", str (side group _x)],
            ["distance", _x distance2D _spawnPos]
        ]);
    } forEach _playerBlockers;
};

if (_includeVehicles) then {
    _vehicleBlockers = vehicles select {
        alive _x
        && {_x isKindOf "AllVehicles"}
        && {!(_x isKindOf "CAManBase")}
        && {_x distance2D _spawnPos <= _effectiveRadius}
        && {!(_x isEqualTo _excludedVehicle)}
    };

    {
        private _crew = crew _x;
        private _vehicleSide = if ((count _crew) > 0) then {
            str (side group (_crew select 0))
        } else {
            str sideUnknown
        };

        _vehicleDetails pushBack (createHashMapFromArray [
            ["type", typeOf _x],
            ["netId", netId _x],
            ["varName", vehicleVarName _x],
            ["side", _vehicleSide],
            ["distance", _x distance2D _spawnPos]
        ]);
    } forEach _vehicleBlockers;
};

createHashMapFromArray [
    ["isClear", ((count _playerBlockers) <= 0 && {(count _vehicleBlockers) <= 0})],
    ["playerBlockers", _playerBlockers],
    ["vehicleBlockers", _vehicleBlockers],
    ["playerDetails", _playerDetails],
    ["vehicleDetails", _vehicleDetails]
]

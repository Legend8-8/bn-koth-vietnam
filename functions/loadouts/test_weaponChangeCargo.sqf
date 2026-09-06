/*
    File: test_weaponChangeCargo.sqf
    Author: Legend
    Description: Tests managed weapon-change validation, cargo cleanup, and
        saved-kit rejection. Run after mission initialization; does not apply
        equipment or save kits.
    Execution: Hosted or dedicated server debug/test context
    Parameters: 0: Connected WEST player with starter entitlement <OBJECT>
    Returns: Failed assertion labels <ARRAY>
    Public: No
*/
params [["_player", objNull, [objNull]]];
if (!isServer) exitWith {["Run on the server."]};
private _failures = [];
private _check = {
    params ["_label", "_condition"];
    if (!_condition) then {_failures pushBack _label;};
};

// Exercise the production private helper without modifying progression or
// requiring acquisition of the replacement weapon in the test player's state.
private _source = loadFile "functions\loadouts\fn_validateLoadout.sqf";
private _start = _source find "private _removeIncompatibleWeaponCargo = {";
private _end = _source find "if (_requestMode isEqualTo ""primary"") exitWith {";
if ((_start < 0) || {_end <= _start}) exitWith {["Cargo cleanup helper boundaries not found."]};
private _cleanup = call compile ((_source select [_start, _end - _start]) + "_removeIncompatibleWeaponCargo");
private _arsenalCfg = missionConfigFile >> "CfgBnKothArsenal";
private _compatibilityCfg = _arsenalCfg >> "Equipment" >> "Compatibility";

{
    _x params ["_oldMagazine", "_newWeapon", "_newMagazine"];
    private _cargo = [
        [_oldMagazine, 4, 1], [_newMagazine, 2, 1],
        ["vn_m1911_mag", 1, 7], ["vn_rpg7_mag", 1, 1],
        ["vn_m61_grenade_mag", 3, 1], ["vn_m18_white_mag", 2, 1],
        ["vn_b_item_firstaidkit", 2]
    ];
    private _loadout = [
        [_newWeapon, "", "", "", [], [], ""],
        ["vn_rpg7", "", "", "", [], [], ""],
        ["vn_m1911", "", "", "", [], [], ""],
        ["uniform", +_cargo], ["vest", +_cargo], ["backpack", +_cargo],
        "", "", [], []
    ];
    private _original = +_loadout;
    private _cleaned = [_loadout] call _cleanup;
    [format ["%1 cleanup does not mutate its input", _newWeapon], _loadout isEqualTo _original] call _check;
    {
        private _remaining = (_cleaned select _x) select 1;
        [format ["%1 container %2 removes only stale magazines", _newWeapon, _x],
            _remaining isEqualTo (_cargo select [1])
        ] call _check;
    } forEach [3, 4, 5];
} forEach [
    ["vn_m3a1_mag", "vn_m1903", "vn_m1903_mag"],
    ["vn_m1903_mag", "vn_m3a1", "vn_m3a1_mag"]
];

// Full saved-kit validation must still reject the same incompatible cargo.
if (isNull _player || {!isPlayer _player} || {(getPlayerUID _player) isEqualTo ""}) then {
    _failures pushBack "Saved-kit rejection requires a connected WEST test player.";
} else {
    private _starter = [west] call bn_koth_fnc_loadouts_getStarterLoadout;
    if !(_starter getOrDefault ["success", false]) then {
        _failures pushBack "WEST starter unavailable for saved-kit rejection test.";
    } else {
        {
            _x params ["_slotName", "_slotIndex"];
            private _clearRequest = createHashMapFromArray [["weapons", createHashMapFromArray [
                [_slotName, createHashMapFromArray [
                    ["weaponClass", ""],
                    ["magazines", []],
                    ["attachments", []]
                ]]
            ]]];
            private _clearResult = [_player, _clearRequest] call bn_koth_fnc_loadouts_validateLoadout;
            private _validatedWeapons = _clearResult getOrDefault ["validatedWeapons", createHashMap];
            private _clearPayload = _validatedWeapons getOrDefault [_slotName, createHashMap];
            private _validatedLoadout = _clearResult getOrDefault ["validatedLoadout", []];
            private _clearedSlot = if ((count _validatedLoadout) > _slotIndex) then {
                _validatedLoadout select _slotIndex
            } else {
                objNull
            };

            [format ["%1 clear passes authoritative validation without weapon entitlement", _slotName],
                (_clearResult getOrDefault ["success", false]) &&
                {_clearPayload getOrDefault ["clear", false]}
            ] call _check;
            [format ["%1 clear builds empty Unit Loadout index %2", _slotName, _slotIndex],
                (_clearedSlot isEqualType []) &&
                {
                    (_clearedSlot isEqualTo []) ||
                    {((count _clearedSlot) >= 7) && {(_clearedSlot select 0) isEqualTo ""}}
                }
            ] call _check;
        } forEach [
            ["launcher", 1],
            ["handgun", 2]
        ];

        private _primaryClearResult = [_player, createHashMapFromArray [["weapons", createHashMapFromArray [
            ["primary", createHashMapFromArray [
                ["weaponClass", ""],
                ["magazines", []],
                ["attachments", []]
            ]]
        ]]]] call bn_koth_fnc_loadouts_validateLoadout;
        ["Primary clear remains rejected", !(_primaryClearResult getOrDefault ["success", true])] call _check;

        {
            _x params ["_slotName", "_slotIndex", "_emptySlot", "_expectedSuccess"];
            private _savedLoadout = +(_starter get "loadout");
            // Isolate optional-slot validation from the separately tested rule
            // that rejects cargo magazines incompatible with all carried weapons.
            {
                private _container = +(_savedLoadout select _x);
                _container set [1, []];
                _savedLoadout set [_x, _container];
            } forEach [3, 4, 5];
            _savedLoadout set [_slotIndex, +_emptySlot];
            private _savedResult = [_player, createHashMapFromArray [["mutation", createHashMapFromArray [
                ["op", "load_local_kit"],
                ["kitId", format ["test_empty_%1", _slotName]],
                ["savedLoadout", _savedLoadout]
            ]]]] call bn_koth_fnc_loadouts_validateLoadout;

            if (_expectedSuccess) then {
                private _validatedLoadout = _savedResult getOrDefault ["validatedLoadout", []];
                private _builtSlot = if ((count _validatedLoadout) > _slotIndex) then {
                    _validatedLoadout select _slotIndex
                } else {
                    objNull
                };

                [format ["Saved kit with empty %1 passes load_local_kit validation", _slotName],
                    _savedResult getOrDefault ["success", false]
                ] call _check;
                [format ["Saved empty %1 builds Unit Loadout index %2 empty", _slotName, _slotIndex],
                    (_builtSlot isEqualType []) &&
                    {
                        (_builtSlot isEqualTo []) ||
                        {((count _builtSlot) >= 7) && {(_builtSlot select 0) isEqualTo ""}}
                    }
                ] call _check;
            } else {
                ["Saved kit with empty primary remains rejected with ERR_LOADOUT_SLOT_EMPTY",
                    !(_savedResult getOrDefault ["success", true]) &&
                    {(_savedResult getOrDefault ["code", ""]) isEqualTo "ERR_LOADOUT_SLOT_EMPTY"}
                ] call _check;
            };
        } forEach [
            ["launcher", 1, [], true],
            ["handgun", 2, ["", "", "", "", [], [], ""], true],
            ["primary", 0, ["", "", "", "", [], [], ""], false]
        ];

        private _saved = +(_starter get "loadout");
        private _vest = _saved select 4;
        private _cargo = +(_vest select 1);
        _cargo pushBack ["vn_m1903_mag", 1, 5];
        _vest set [1, _cargo];
        _saved set [4, _vest];
        private _result = [
            _player,
            createHashMapFromArray [["op", "load_local_kit"], ["kitId", "test_incompatible_cargo"], ["savedLoadout", _saved]],
            _compatibilityCfg, _arsenalCfg, west, "WEST", _starter get "loadout"
        ] call bn_koth_fnc_loadouts_validateMutation;
        ["Incompatible saved-kit cargo still rejects",
            !(_result getOrDefault ["success", true]) &&
            {(_result getOrDefault ["code", ""]) isEqualTo "ERR_CARGO_MAGAZINE_INCOMPATIBLE"}
        ] call _check;
    };
};

diag_log format ["[BN_KOTH_TEST] Weapon-change cargo: %1 failure(s): %2", count _failures, _failures];
_failures

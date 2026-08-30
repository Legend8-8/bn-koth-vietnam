/*
    File: fn_selectAnimation.sqf
    Author: Legend
    Edited: Legend
    Description: Selects an available stock Arma 3 or S.O.G. traversal animation
        for the requested start or finish phase.
    Execution: Owning client
    Parameters:
        0: Traversing unit <OBJECT>
        1: Traversal action <STRING>
        2: Landing mode <STRING>
        3: Animation phase: START or FINISH <STRING>
    Returns:
        Animation state name, or an empty finish animation when not applicable <STRING>
    Public: Yes
*/

params [
    ["_unit", objNull, [objNull]],
    ["_action", "NONE", [""]],
    ["_landingMode", "ON_TOP", [""]],
    ["_phase", "START", [""]]
];

private _selectedWeapon = if (isNull _unit) then {""} else {currentWeapon _unit};
private _weaponStyle = if (_selectedWeapon isEqualTo "") then {
    "UNARMED"
} else {
    if (_selectedWeapon isEqualTo (handgunWeapon _unit)) exitWith {"PISTOL"};
    if (_selectedWeapon isEqualTo (secondaryWeapon _unit)) exitWith {"LAUNCHER"};
    "RIFLE"
};

private _standingVault = switch (_weaponStyle) do {
    case "PISTOL": {"AovrPercMstpSrasWpstDf"};
    case "LAUNCHER": {"AovrPercMstpSrasWlnrDf"};
    case "RIFLE": {"AovrPercMstpSrasWrflDf"};
    default {"AovrPercMstpSnonWnonDf"};
};

private _movingVault = if (_weaponStyle isEqualTo "RIFLE") then {
    "AovrPercMrunSrasWrflDf"
} else {
    _standingVault
};

private _ladderUp = if (_weaponStyle in ["RIFLE", "LAUNCHER"]) then {
    "LadderRifleUpLoop"
} else {
    "LadderCivilUpLoop"
};

private _ladderTopOff = if (_weaponStyle in ["RIFLE", "LAUNCHER"]) then {
    "LadderRifleTopOff"
} else {
    "LadderCivilTopOff"
};

private _isFinishPhase = (toUpper _phase) isEqualTo "FINISH";
private _isMantle = _action in ["MANTLE_LOW", "MANTLE_MEDIUM", "MANTLE_HIGH"];
private _candidates = if (_isFinishPhase) then {
    if (_isMantle) then {[_ladderTopOff]} else {[]}
} else {
    switch (_action) do {
        case "STEP_OVER": {["vn_weapon_on_back_evaF", _standingVault]};
        case "VAULT": {[_movingVault, _standingVault]};
        case "MANTLE_LOW": {[_ladderUp, _standingVault]};
        case "MANTLE_MEDIUM": {[_ladderUp, _standingVault]};
        case "MANTLE_HIGH": {[_ladderUp, _standingVault]};
        default {[_standingVault]};
    }
};

private _selected = "";
{
    if (isClass (configFile >> "CfgMovesMaleSdr" >> "States" >> _x)) exitWith {
        _selected = _x;
    };
} forEach _candidates;

if (_selected != "") exitWith {_selected};
if (_isFinishPhase) exitWith {""};

// Last-resort base-game safety fallback.
"AovrPercMstpSnonWnonDf"

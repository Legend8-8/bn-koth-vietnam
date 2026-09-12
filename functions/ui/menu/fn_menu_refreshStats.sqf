/*
    File: fn_menu_refreshStats.sqf
    Author: Legend
    Description: Renders the full-width player career and bounded leaderboard workspace.
    Execution: Client
    Public: No
*/
#include "..\..\..\ui\menu\idcs.hpp"
params [["_display", displayNull, [displayNull]]];
if (!hasInterface || {isNull _display}) exitWith {};
disableSerialization;

private _metric = uiNamespace getVariable ["BN_KOTH_menuStatsMetric", 1];
private _period = uiNamespace getVariable ["BN_KOTH_menuStatsPeriod", 0];
private _mode = uiNamespace getVariable ["BN_KOTH_menuStatsMode", "TOP"];
private _labels = ["", "KILLS", "DEATHS", "WINS", "ROUNDS PLAYED", "OBJECTIVE CONTRIBUTION", "HIGHEST KILL STREAK", "TOTAL XP EARNED", "TIME PLAYED", "K/D"];
(_display displayCtrl BN_KOTH_IDC_MENU_STATS_LEADER_TITLE) ctrlSetText format ["LEADERBOARD — %1", _labels select _metric];

private _progression = missionNamespace getVariable ["BN_KOTH_playerProgressionLocal", createHashMap];
private _level = (_progression getOrDefault ["level", 1]) max 1;
private _xp = (_progression getOrDefault ["xp", 0]) max 0;
private _cash = (_progression getOrDefault ["cash", 0]) max 0;
private _progress = [_xp, _level] call bn_koth_fnc_progression_xp_getLevelProgress;
_level = _progress getOrDefault ["level", 1];
private _rank = [_level] call bn_koth_fnc_progression_resolveRankPresentation;
private _rankCtrl = _display displayCtrl BN_KOTH_IDC_MENU_STATS_RANK;
_rankCtrl ctrlSetText (_rank getOrDefault ["icon", ""]);
_rankCtrl ctrlSetTextColor (_rank getOrDefault ["color", [1,1,1,0]]);
_rankCtrl ctrlShow (_rank getOrDefault ["hasIcon", false]);
(_display displayCtrl BN_KOTH_IDC_MENU_STATS_LEVEL) ctrlSetText format ["LEVEL %1", _level];
(_display displayCtrl BN_KOTH_IDC_MENU_STATS_XP) ctrlSetText (if (_level >= (_progress getOrDefault ["maxLevel",270])) then {format ["MAX LEVEL  |  %1 XP", [_xp] call BIS_fnc_numberText]} else {format ["%1 / %2 XP", round (_progress getOrDefault ["xpIntoLevel",0]), round (_progress getOrDefault ["xpRequired",0])]} );
(_display displayCtrl BN_KOTH_IDC_MENU_STATS_CASH) ctrlSetText ([_cash] call bn_koth_fnc_ui_formatCash);

private _response = uiNamespace getVariable ["BN_KOTH_menuStatsResponse", createHashMap];
private _career = _response getOrDefault ["career", createHashMap];
private _careerAvailable = _response getOrDefault ["careerAvailable", false] && {(count _career) > 0};
private _careerState = _display displayCtrl BN_KOTH_IDC_MENU_STATS_CAREER_STATE;
private _tileIds = [BN_KOTH_IDC_MENU_STATS_TILE_1,BN_KOTH_IDC_MENU_STATS_TILE_2,BN_KOTH_IDC_MENU_STATS_TILE_3,BN_KOTH_IDC_MENU_STATS_TILE_4,BN_KOTH_IDC_MENU_STATS_TILE_5,BN_KOTH_IDC_MENU_STATS_TILE_6,BN_KOTH_IDC_MENU_STATS_TILE_7,BN_KOTH_IDC_MENU_STATS_TILE_8,BN_KOTH_IDC_MENU_STATS_TILE_9];
private _tileMetrics = [1,2,9,3,4,5,6,7,8];
private _tileKeys = ["kills","deaths","kd","wins","roundsPlayed","objectiveContribution","highestKillStreak","totalXpEarned","timePlayedSeconds"];

_careerState ctrlShow (!_careerAvailable);
if (!_careerAvailable) then {
    _careerState ctrlSetStructuredText parseText "<t font='PuristaSemiBold' size='0.92'>CAREER DATA UNAVAILABLE</t><br/><t size='0.76' color='#AAA99F'>Your career record cannot be retrieved right now.</t>";
};
{
    private _ctrl = _display displayCtrl (_tileIds select _forEachIndex);
    private _tileMetric = _x;
    private _value = "—";
    if (_careerAvailable) then {
        private _raw = if (_tileMetric isEqualTo 9) then {_career getOrDefault ["kills",0]} else {_career getOrDefault [_tileKeys select _forEachIndex,0]};
        private _deaths = if (_tileMetric isEqualTo 9) then {_career getOrDefault ["deaths",0]} else {-1};
        _value = [_raw, _tileMetric, _deaths] call bn_koth_fnc_menu_formatCareerValue;
    };
    _ctrl ctrlSetStructuredText parseText format ["<t font='RobotoCondensed' size='0.78' color='#AAA99F'>%1</t><br/><t font='PuristaSemiBold' size='1.55' color='%3'>%2</t>", _labels select _tileMetric, _value, if (_tileMetric isEqualTo _metric) then {"#E5B849"} else {"#F2EEE6"}];
    _ctrl ctrlSetBackgroundColor (if (_tileMetric isEqualTo _metric) then {[0.20,0.15,0.08,0.98]} else {[0.085,0.082,0.068,0.98]});
    _ctrl ctrlShow true;
    _ctrl ctrlRemoveAllEventHandlers "MouseButtonClick";
    _ctrl ctrlAddEventHandler ["MouseButtonClick", format ["uiNamespace setVariable ['BN_KOTH_menuStatsMetric',%1]; [] call bn_koth_fnc_menu_requestStats;", _tileMetric]];
} forEach _tileMetrics;

private _setSelected = {params ["_id", "_selected"]; private _ctrl=_display displayCtrl _id; _ctrl ctrlSetBackgroundColor (if (_selected) then {[0.20,0.15,0.08,0.98]} else {[0.08,0.08,0.07,0.90]}); _ctrl ctrlSetTextColor (if (_selected) then {[0.94,0.80,0.34,1]} else {[0.94,0.92,0.88,0.98]});};
[BN_KOTH_IDC_MENU_STATS_PERIOD_24H,_period isEqualTo 1] call _setSelected; [BN_KOTH_IDC_MENU_STATS_PERIOD_7D,_period isEqualTo 2] call _setSelected; [BN_KOTH_IDC_MENU_STATS_PERIOD_30D,_period isEqualTo 3] call _setSelected; [BN_KOTH_IDC_MENU_STATS_PERIOD_ALL,_period isEqualTo 0] call _setSelected;
[BN_KOTH_IDC_MENU_STATS_MODE_TOP,_mode isEqualTo "TOP"] call _setSelected; [BN_KOTH_IDC_MENU_STATS_MODE_AROUND,_mode isEqualTo "MY_POSITION"] call _setSelected;

private _rowIds = [BN_KOTH_IDC_MENU_STATS_ROW_1,BN_KOTH_IDC_MENU_STATS_ROW_2,BN_KOTH_IDC_MENU_STATS_ROW_3,BN_KOTH_IDC_MENU_STATS_ROW_4,BN_KOTH_IDC_MENU_STATS_ROW_5,BN_KOTH_IDC_MENU_STATS_ROW_6,BN_KOTH_IDC_MENU_STATS_ROW_7,BN_KOTH_IDC_MENU_STATS_ROW_8,BN_KOTH_IDC_MENU_STATS_ROW_9,BN_KOTH_IDC_MENU_STATS_ROW_10];
{(_display displayCtrl _x) ctrlShow false} forEach _rowIds;
private _leaderState = _display displayCtrl BN_KOTH_IDC_MENU_STATS_LEADER_STATE;
private _position = _display displayCtrl BN_KOTH_IDC_MENU_STATS_POSITION;
_position ctrlSetText "";
private _matchesSelection = (_response getOrDefault ["metric",-1]) isEqualTo _metric && {(_response getOrDefault ["period",-1]) isEqualTo _period} && {(_response getOrDefault ["mode",""]) isEqualTo _mode};
if (uiNamespace getVariable ["BN_KOTH_menuStatsLoading", false] || {!_matchesSelection}) then {
    _leaderState ctrlShow true;
    _leaderState ctrlSetStructuredText parseText "<t align='center' font='PuristaSemiBold' size='1.15'>LOADING LEADERBOARD...</t>";
} else {
    private _success = _response getOrDefault ["success", false];
    private _rows = _response getOrDefault ["rows", []];
    if (!_success) then {
        _leaderState ctrlShow true;
        _leaderState ctrlSetStructuredText parseText "<t align='center' font='PuristaSemiBold' size='1.20'>LEADERBOARD TEMPORARILY UNAVAILABLE</t><br/><t align='center' color='#AAA99F'>Rankings cannot be retrieved right now.</t>";
    } else {
        if ((count _rows) isEqualTo 0) then {
            _leaderState ctrlShow true;
            _leaderState ctrlSetStructuredText parseText "<t align='center' font='PuristaSemiBold' size='1.20'>NO RANKED PLAYERS YET</t>";
        } else {
            _leaderState ctrlShow false;
            {
                private _ctrl = _display displayCtrl (_rowIds select _forEachIndex);
                private _rankValue = _x select 0;
                private _name = _x select 1;
                private _value = [_x select 2, _metric] call bn_koth_fnc_menu_formatCareerValue;
                private _isLocal = _x select 3;
                private _color = if (_isLocal) then {"#F1C55C"} else {if (_rankValue isEqualTo 1) then {"#E5B849"} else {"#EAE8E1"}};
                _ctrl ctrlSetBackgroundColor (if (_isLocal) then {[0.24,0.17,0.07,0.98]} else {if ((_forEachIndex mod 2) isEqualTo 0) then {[0.075,0.075,0.068,0.86]} else {[0.055,0.055,0.05,0.86]}});
                _ctrl ctrlSetStructuredText parseText format ["<t font='PuristaSemiBold' size='1.05' color='%4'>#%1</t><t align='center' size='1.02' color='%4'>%2%5</t><t align='right' font='PuristaSemiBold' size='1.05' color='%4'>%3</t>", _rankValue, _name, _value, _color, if (_isLocal) then {"  • YOU"} else {""}];
                _ctrl ctrlShow true;
            } forEach (_rows select [0, (count _rows) min 10]);
        };
        private _localRank = _response getOrDefault ["localRank",-1];
        private _count = _response getOrDefault ["rankedCount",-1];
        if (_localRank > 0) then {
            _position ctrlSetText (if (_count > 0) then {format ["YOU ARE #%1 OF %2", _localRank, _count]} else {format ["YOU ARE #%1", _localRank]});
        };
    };
};

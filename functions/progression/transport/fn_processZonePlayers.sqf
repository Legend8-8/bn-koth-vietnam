/*
    File: fn_processZonePlayers.sqf
    Author: Legend
    Description: Consumes the zone owner's already-computed eligible AO player
        set, prunes bounded state, confirms insertions, and calls the existing
        XP and cash reward owners for the pilot.
    Execution: Server
    Parameters: 0: Eligible human players physically inside the AO <ARRAY>
    Returns: Number of insertion rewards awarded <NUMBER>
    Public: No
*/

params [["_zonePlayers", [], [[]]]];
if (!isServer) exitWith {0};

private _now = serverTime;
private _aoId = missionNamespace getVariable ["BN_KOTH_activeLocationId", ""];
private _roundActive = ([] call bn_koth_fnc_round_getState) isEqualTo "ACTIVE";
private _inside = createHashMap;
{ _inside set [getPlayerUID _x, _x]; } forEach _zonePlayers;

private _candidates = missionNamespace getVariable ["BN_KOTH_transportCandidates", createHashMap];
private _cooldowns = missionNamespace getVariable ["BN_KOTH_transportPairCooldowns", createHashMap];
private _records = missionNamespace getVariable ["BN_KOTH_playerRecords", createHashMap];
private _awarded = 0;
private _maximumBoarded = missionNamespace getVariable ["BN_KOTH_transportMaximumBoardedSeconds", 900];

{
    private _passengerUid = _x;
    private _candidate = _candidates get _passengerUid;
    private _phase = _candidate getOrDefault ["phase", ""];
    if (_phase isEqualTo "BOARDED") then {
        private _vehicle = _candidate getOrDefault ["vehicle", objNull];
        private _expiredBoarding = (_now - (_candidate getOrDefault ["boardAt", _now])) > _maximumBoarded;
        private _wrongAo = !((_candidate getOrDefault ["aoId", ""]) isEqualTo _aoId);
        private _wrongPilot = isNull _vehicle || {(currentPilot _vehicle) isNotEqualTo (_candidate getOrDefault ["pilotUnit", objNull])};
        if (isNull _vehicle || {!alive _vehicle} || {_expiredBoarding} || {_wrongAo} || {_wrongPilot}) then {
            _candidates deleteAt _passengerUid;
        };
    } else {
        if (_phase isEqualTo "AWAITING_AO") then {
        private _expired = _now > (_candidate getOrDefault ["expiresAt", -1]);
        private _wrongAo = !((_candidate getOrDefault ["aoId", ""]) isEqualTo _aoId);
        if (_expired || {_wrongAo}) then {
            _candidates deleteAt _passengerUid;
        } else {
            private _passenger = _inside getOrDefault [_passengerUid, objNull];
            if (!isNull _passenger) then {
                private _pilotUid = _candidate getOrDefault ["pilotUid", ""];
                private _pilotRecord = _records getOrDefault [_pilotUid, createHashMap];
                private _pilotUnit = if (_pilotRecord isEqualType createHashMap) then {_pilotRecord getOrDefault ["currentUnit", objNull]} else {objNull};
                private _passengerRecord = _records getOrDefault [_passengerUid, createHashMap];
                private _passengerUnit = if (_passengerRecord isEqualType createHashMap) then {_passengerRecord getOrDefault ["currentUnit", objNull]} else {objNull};
                private _pilotSide = if (_pilotRecord isEqualType createHashMap) then {_pilotRecord getOrDefault ["assignedSide", sideUnknown]} else {sideUnknown};
                private _passengerSide = if (_passengerRecord isEqualType createHashMap) then {_passengerRecord getOrDefault ["assignedSide", sideUnknown]} else {sideUnknown};
                private _pilotValid = _pilotRecord isEqualType createHashMap
                    && {!isNull _pilotUnit}
                    && {isPlayer _pilotUnit}
                    && {alive _pilotUnit}
                    && {(_pilotRecord getOrDefault ["ownerId", -1]) > 0}
                    && {(owner _pilotUnit) isEqualTo (_pilotRecord getOrDefault ["ownerId", -1])}
                    && {(_pilotRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
                    && {_pilotRecord getOrDefault ["deployed", false]}
                    && {_pilotUnit isEqualTo (_candidate getOrDefault ["pilotUnit", objNull])}
                    && {[_pilotSide] call bn_koth_fnc_teams_validateSide};
                private _passengerValid = _passengerRecord isEqualType createHashMap
                    && {!isNull _passengerUnit}
                    && {_passengerUnit isEqualTo _passenger}
                    && {isPlayer _passengerUnit}
                    && {alive _passengerUnit}
                    && {(_passengerRecord getOrDefault ["ownerId", -1]) > 0}
                    && {(owner _passengerUnit) isEqualTo (_passengerRecord getOrDefault ["ownerId", -1])}
                    && {(_passengerRecord getOrDefault ["state", "LOBBY"]) isEqualTo "ACTIVE"}
                    && {_passengerRecord getOrDefault ["deployed", false]}
                    && {[_passengerSide] call bn_koth_fnc_teams_validateSide};
                private _pairKey = format ["%1|%2", _pilotUid, _passengerUid];
                private _cooldownOpen = _now >= (_cooldowns getOrDefault [_pairKey, 0]);
                private _sameSide = _pilotSide isEqualTo _passengerSide
                    && {_pilotSide isEqualTo (_candidate getOrDefault ["assignedSide", sideUnknown])};

                if (_roundActive && {_pilotValid} && {_passengerValid} && {_sameSide} && {_cooldownOpen} && {!(_pilotUid isEqualTo _passengerUid)}) then {
                    // Validation consumes the insertion and starts its anti-farm
                    // cooldown before either downstream reward owner is called.
                    _candidates deleteAt _passengerUid;
                    _cooldowns set [_pairKey, _now + (missionNamespace getVariable ["BN_KOTH_transportPairCooldown", 600])];
                    private _xp = missionNamespace getVariable ["BN_KOTH_transportInsertionXp", 25];
                    private _cash = missionNamespace getVariable ["BN_KOTH_transportInsertionCash", 25];
                    private _xpSucceeded = _xp <= 0;
                    private _cashSucceeded = _cash <= 0;
                    if (_xp > 0) then {
                        private _xpResult = [_pilotUid, _xp, "transport"] call bn_koth_fnc_progression_xp_addXp;
                        _xpSucceeded = _xpResult isEqualType createHashMap && {(count _xpResult) > 0};
                    };
                    if (_cash > 0) then {
                        private _cashResult = [_pilotUid, _cash, "transport"] call bn_koth_fnc_progression_cash_addCash;
                        _cashSucceeded = _cashResult isEqualType createHashMap && {_cashResult getOrDefault ["success", false]};
                    };
                    _awarded = _awarded + 1;
                    private _level = if (_xpSucceeded && {_cashSucceeded}) then {"INFO"} else {"WARN"};
                    [format ["Transport insertion validated pilot=%1 passenger=%2 vehicle=%3 ao=%4 xp=%5 xpOk=%6 cash=%7 cashOk=%8", _pilotUid, _passengerUid, _candidate getOrDefault ["vehicleNetId", ""], _aoId, _xp, _xpSucceeded, _cash, _cashSucceeded], _level] call bn_koth_fnc_common_log;
                } else {
                    _candidates deleteAt _passengerUid;
                };
            };
        };
        } else {
            _candidates deleteAt _passengerUid;
        };
    };
} forEach +(keys _candidates);

{
    if ((_cooldowns get _x) <= _now) then {_cooldowns deleteAt _x};
} forEach +(keys _cooldowns);

missionNamespace setVariable ["BN_KOTH_transportCandidates", _candidates];
missionNamespace setVariable ["BN_KOTH_transportPairCooldowns", _cooldowns];
_awarded

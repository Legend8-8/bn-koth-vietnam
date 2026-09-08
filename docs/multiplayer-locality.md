Bro-Nation KOTH Vietnam — Multiplayer Locality

1. Purpose

Arma multiplayer code may run on:

- the dedicated server;
- every client;
- one specific client;
- a headless client;
- the machine local to a particular object.

Every function must have a deliberate execution location.

2. Core Principle

The server calculates gameplay truth.

Clients display information and send requests.

Combat-attribution collection registers only on the server. Projectile facts
and bounded victim hit records remain server-local and are not broadcast;
optional diagnostics only control RPT verbosity. `EntityKilled` owns lethality,
`combat_handleKill` owns valid PvP, and progression mastery consumes only the
attached unique `ATTRIBUTED` canonical infantry root. Clients have no mastery
mutation or weapon-attribution request endpoint.

Transport insertion rewards are likewise server-only. Server-installed
vehicle GetIn/GetOut, ControlsShifted and SeatSwitched handlers establish or
invalidate the mounted transport leg, and the existing server zone evaluation
confirms subsequent AO entry. Candidates are bounded per passenger and pair
cooldowns remain server-local across ordinary lifecycle cleanup. The server
resolves current player records, representations, assigned sides, controller,
timing, displacement and AO membership. Clients have no insertion-reward
endpoint and never supply identity, side, distance, timing, AO membership or
reward results.

A client must not be trusted to determine:

- zone ownership;
- team score;
- kills or rewards;
- experience;
- currency;
- purchases;
- unlocks;
- round winners.

3. System Ownership

System or action| Execution owner
Mission framework initialisation| Server and clients separately
Round state| Server
Round start and end| Server
Active location selection| Server
Eligible zone-player detection| Server
Zone population calculation| Server
Zone ownership calculation| Server
Team score| Server
Win-condition calculation| Server
Team assignment validation| Server
Logical player-group membership and leadership| Server
Native player-group reconciliation| Server, with native leader selection delegated to the native group's locality owner
Experience and level changes| Server
Player input and menus| Owning client
HUD drawing| Each client
Local sounds and visual effects| Each client
Purchase request creation| Owning client
Purchase validation| Server
Experience and currency changes| Server
Database access| Server
Gameplay vehicle creation| Server
Air-insertion session, manifest, payment and aircraft creation| Server
Air-insertion flight| Current human driver through normal vehicle locality
Air-insertion seat assignment and physical backpack substitution/restoration| Owning client, on server instruction
Local player loadout interface| Owning client
Loadout entitlement validation| Server
Traversal input, geometry probing and movement| Owning client
Named kit profile storage and management| Owning client; stored data remains untrusted intent
Arsenal physical-loadout reconciliation| Server reads the owned player object
Arsenal preview framework| Owning client; currently disabled
Safe-zone physical inventory blocking| Owning client
Safe-zone ground-loot and corpse cleanup| Server
Respawn presentation| Owning client
Respawn rules and validation| Server
Advanced Revive mechanics| S.O.G. Advanced Revive module/runtime
KOTH incapacitated combat eligibility| Server, derived from the current representation
Call For Help approval and teammate projection| Server
Casualty actions, full-map/GPS Draw overlays and bounded 3D overlay| Owning client
Player safe-zone membership| Server
Player firing and damage enforcement| Owning client
Vehicle safe-zone membership| Server
Vehicle damage and firing enforcement| Current vehicle owner
Opposing-safe-zone ejection| Owning client, on server instruction
Headless-client AI processing| Headless client when introduced

4. Initialisation Files

"initServer.sqf"

Used for server-only startup.

Examples:

- creating authoritative mission state;
- starting the round manager;
- starting zone monitoring;
- initialising team score;
- selecting the active location.

"initPlayerLocal.sqf"

Runs once for each player on their own machine.

Examples:

- initialising the HUD;
- installing local event handlers;
- creating client menus;
- displaying notifications.

This file must account for join-in-progress players.

"initPlayerServer.sqf"

Runs on the server when a player joins.

Examples:

- validating the player;
- assigning initial server-side player state;
- sending the current round state to the joining player;
- loading and normalizing persistent data through the server-only persistence service.

"init.sqf"

Must not become a dumping ground.

It should contain only shared startup that genuinely needs to execute on every machine, or direct execution into clearly owned initialisation functions.

4.1 Representation handoff lifecycle

The transfer function bn_koth_fnc_teams_transferRepresentation is a server-owned handoff primitive.

Use it when a player must be moved to a newly created or newly selected representation unit, such as:

- lobby representation assignment;
- gameplay deployment assignment;
- any server-authoritative role/unit transition.

Do not call this handoff function from client startup files.

The startup file initPlayerLocal.sqf runs once on each client and initializes local systems for that client. It is not the place to authoritatively choose or transfer representation ownership.

Server-side usage pattern:

[_uid, _targetUnit, _targetState, _deletePrevious] call bn_koth_fnc_teams_transferRepresentation;

Parameter meaning:

- _uid: player UID string;
- _targetUnit: server-selected representation unit object;
- _targetState: logical player state string (for example LOBBY or DEPLOYING);
- _deletePrevious: whether to delete the previous non-player representation after successful handoff.

On success, the lifecycle is:

1. Server validates record and owner.
2. Server asks owning client to selectPlayer through bn_koth_fnc_ui_selectControlledUnit.
3. Server waits until target-unit locality ownership matches the player owner.
4. Server updates authoritative player record state.
5. The client acknowledges successful representation selection from
   `player isEqualTo _targetUnit`; transient same-frame `local` state does not
   reject or delay that ACK. The handoff does not call
   `VN_fnc_revive_coreinit`: that function is the S.O.G. incapacitated casualty
   core loop. Once the newly selected representation becomes local, the client
   invokes the module's local `VN_fnc_revive_addEventHandlers` installer once
   for that representation. The existing Eden module remains the system owner.
6. Server triggers post-handoff local reinitialization on the owning client (map icons, 3D icons, ESC menu), plus server-side curator setup.

This split keeps authority server-side while still ensuring client-local systems are reinstalled after ownership changes.

Call For Help is a narrow client-to-server intent with no UID, side, target or
incapacitation claim. The server derives the caller from `remoteExecutedOwner`,
validates its player record and current representation, and stores only valid
ACTIVE deployed casualties. It publishes conscious clients only same-team
entries; an incapacitated requester receives only their own approved map/GPS
entry and never an own 3D marker.
The receiver rejects non-server callers; map and 3D renderers independently
revalidate local lifecycle, team and incapacitation state before drawing.

5. State Distribution

The server stores authoritative state.

Clients receive only the information needed for presentation.

Examples of client-visible state:

- current round state;
- current team scores;
- current zone status;
- remaining preparation time;
- winning team.

Where practical, state should be published only when it changes rather than continuously broadcasting identical values.

6. Join in Progress

A joining player must receive the current state of the active round.

The player must not assume the round is beginning from its initial state.

At minimum, a joining player needs:

- current round state;
- active location;
- active zone details;
- active WEST and EAST safe-zone markers;
- current zone owner;
- raw, weighted and Priority-zone population;
- current team scores;
- winning score;
- remaining relevant timer information.

7. Client Requests

Client-to-server requests must contain the minimum required information.

Example:

[_loadoutId] remoteExecCall [
    "bn_koth_fnc_loadouts_request",
    2
];

The server must independently validate:

- the requesting player;
- the player’s side;
- the player’s position;
- the requested identifier;
- any level requirement;
- any cost;
- request frequency;
- current round state.

The client must not supply its own UID, balance, level or entitlement when the server can obtain those values itself.

8. Remote Execution Rules

Remote execution must use an allowlist.

Only intentional public network endpoints may be remotely executed.

Naming should distinguish requests from internal functions.

Examples:

bn_koth_fnc_loadouts_request
bn_koth_fnc_vehicles_requestSpawn
bn_koth_fnc_ui_receiveState

Internal calculation functions must not be remotely executable unless there is a specific documented reason.

9. Object Locality

Before executing a command on a unit or vehicle, confirm where that object is local.

Vehicle creation should normally be performed by the server.

Commands that require local execution must be sent to the machine that owns the object.

Locality must not be guessed from where a function happened to be called.

Traversal runs only for the current local player representation. It publishes
no authoritative state, sends no remote request, and creates no JIP payload.
The engine continues to replicate the owning client's unit transform normally;
the mission-local traversal lock and diagnostics remain client-local.

Safe-zone membership is calculated on the server. Player `HandleDamage`, `FiredMan`, `GetInMan` and physical-inventory handlers are installed on each current local player representation, including after respawn or `selectPlayer`. The inventory-open handler uses the published active markers and the shared safe-zone geometry helper to block local UI access when either the actor or container crosses the boundary. Vehicle `allowDamage`, `HandleDamage` and `Fired` enforcement is reapplied whenever the vehicle owner changes. The server independently validates and deletes safe-zone loot holders and corpses. The only safe-zone remote endpoints are server-to-owner ejection and vehicle-protection application; both reject non-server remote callers.

AO population eligibility is calculated only from server-owned player records
whose owner resolves to a connected human player object. Clients neither report
nor calculate this count. Vote candidate reconciliation and resolution are
server-only. Store capability display is client presentation derived from the
active location, while free slots, rentals and command teleport independently
enforce the same spawn-role capability on the server.

10. Performance

Do not use "eachFrame" for zone control, scoring or database activity.

Suggested initial intervals:

- zone population calculation: once per second;
- safe-zone membership and locality reconciliation: four times per second;
- safe-zone inventory blocking: event-based, with a bounded check only while the physical inventory display is open;
- safe-zone ground cleanup: entity events plus one activation-time sweep, never a recurring world scan;
- score awarding: configurable, such as once every five seconds;
- HUD refresh: only when values change, or at a controlled client-side interval;
- persistence saving: mutation-driven dirty state with one coalesced delayed save,
  plus disconnect/mission-end flushes; never every frame or every score tick.

Clients have no persistence endpoint. They cannot load, save, or submit XP, cash,
ownership, or mastery values. Registration supplies only a server-observed Steam
UID to `functions/persistence/`; the existing targeted progression snapshot is the
sole client presentation path. extDB3 calls remain server-local behind the backend
adapter. No persistence function is remotely exposed and no database result is
accepted from a client.

All players do not need to calculate the same authoritative zone result independently.

11. Disconnects and Death

The server calculation must naturally remove players who:

- disconnect;
- die;
- become spectators;
- leave the zone;
- change to an ineligible state.

Cached player references must be checked before use.

12. Locality Review Questions

Before merging a multiplayer feature, answer:

1. Which machine runs this function?
2. Which machine owns the affected object?
3. Is the input trusted?
4. Can a client fake this request?
5. What happens for a join-in-progress player?
6. What happens if the player disconnects midway?
7. Is the same work unnecessarily running on every client?
8. Does the server remain authoritative?

13. Store Weapon Requests

The client sends only `PURCHASE`/`RENT` plus a canonical weapon classname. The
server resolves the player and UID from `remoteExecutedOwner`, invokes the
existing server-only acquisition API, targets the result to that owner, and
publishes changed cash/ownership/rental state through the existing player-only
progression update. Store requests never broadcast and never equip equipment.

14. Vehicle Rental Requests

Clients submit only RENT or owner access-mode intent. The server derives the
UID from `remoteExecutedOwner`, validates current side/level/perks, cash and
active-rental state, selects/reserves a cached authored paid pad, creates the
vehicle server-local, and only then deducts cash — all as one transaction with
no separate requisition step. The active rental map is server-only; only the
requesting client receives their projected state. Get-in authorization is
checked from server-owned UID/access data. A narrowly allowlisted
server-to-owner endpoint performs locality-sensitive ejection.

14.1 Tactical Air Insertion

The active team mapboard sends only SOLO/GROUP start intent; invited clients
send only JOIN/LEAVE/CANCEL intent plus the opaque session ID. The server
resolves every caller from `remoteExecutedOwner`, revalidates current player
record, assigned side, active participation and authoritative safe-zone
membership, freezes the manifest, creates the aircraft, assigns the initiator
to the driver seat and calls the existing atomic cash owner only after every
client-local seat assignment has been verified.

The session, manifest, payment, captured backpack slot and asset lifecycle remain
server-owned. The aircraft has no AI crew or scripted waypoints: flight follows
normal human-driver vehicle locality and all real human positions are available.
A narrow server-to-owner endpoint performs driver, copilot or cargo seat
assignment, safe-zone return after an aborted commit, and the physical backpack
substitution/restoration required because the player unit is client-local. It
rejects every non-server remote caller. Before boarding, the server captures
Unit Loadout slot 5 from the current authoritative player representation, asks
its owner to apply the configured `B_Parachute`, and verifies the result before
boarding and payment. Native Eject is not intercepted: it produces standard
freefall and the player chooses deployment. An owner-local `GetOutMan` handler
for `ParachuteBase` starts one bounded ground check; the server validates that
the living player is on foot and grounded before authorizing exact slot-5
restoration. Restore success requires both an owner-local exact comparison and
an independent server observation; failed or missing acknowledgements retain the
captured slot for bounded retry. Death and disconnect clear temporary state
without writing to the intended-loadout owner; lobby and round lifecycle hooks
restore a still-live current representation or clear state before reset. An
empty aircraft remains server-owned during one bounded abandonment grace period;
there is no AI takeover or recurring cleanup scan.

15. Player Group Requests And Native Materialization

The owning client sends only a group operation plus the applicable logical
group or member identifier. `bn_koth_fnc_groups_request` runs on the server,
derives the caller from `remoteExecutedOwner`, and verifies that owner against
the current unit and UID in `BN_KOTH_playerRecords`. A client-supplied requester
UID is neither accepted nor required. Mutation validation uses current round,
deployment, side, membership and leadership state at execution time.

`BN_KOTH_groups` remains server-local. Targeted presentation snapshots contain
only names, stable identifiers, counts, deployment status and permissions needed
by the requesting client. An explicit snapshot is read-only; opening the Group
Menu is not a reconciliation or eventual-consistency boundary.

Native membership is reconciled by the server at existing lifecycle events. The
server uses global membership commands for same-side deployed units. If the
native group is server-local, reconciliation executes `selectLeader` directly
and never calls a public endpoint. Otherwise, the server resolves `groupOwner`
and sends the narrowly allowlisted
`bn_koth_fnc_groups_applyNativeLeadership` instruction there. That endpoint is
remote-only, accepts only the server, and verifies locality, logical revision and
group membership. This temporary native leader is derived engine state and
cannot mutate logical leadership.

Native release first moves live members, including unexpected AI/headless
entities, into safe standalone groups. Empty-group cleanup then follows the
native group's current locality. A server-local group is marked
`deleteGroupWhenEmpty` and deleted directly if already empty; a client-local
group receives the narrowly validated server-to-owner
`bn_koth_fnc_groups_prepareNativeCleanup` instruction. Its logical ID and
revision checks prevent cleanup of an unrelated group. The deletion flag covers
dead units that remain until later corpse removal, while logical release proceeds
without waiting for native deletion and no polling is introduced.

Presentation updates are also event-driven. Each mutation or relevant lifecycle
event captures only the affected logical group IDs, member UIDs and possible
leader/member sides. The publisher targets active members plus active players on
those sides whose AVAILABLE GROUPS projection can change. Empty impact has no
all-player fallback, so an ungrouped death or respawn sends no group projection.

Round release separates native units without deleting logical groups. If the
logical leader is connected but undeployed, no side is inferred and deployed
members remain separated. If the leader later deploys, their authoritative
`assignedSide` drives reconciliation. Death/respawn preserves `leaderUid`; only
disconnect, explicit leave/transfer, or another real membership removal may
trigger deterministic logical succession.

Group locking, display names and invitations remain server-owned extensions of
this same request boundary. Ordinary JOIN fails when the logical lock flag is
set; accepting a current invitation is a separate operation which revalidates
the target, current leader, deployment, membership and both authoritative sides.
Candidate projection uses that same validation and therefore never returns an
opposite-side identity. Invitations live in `BN_KOTH_groupInvites`, expire via
one scheduled server deadline rather than polling, and are cleared on relevant
disconnect/death/lobby, leadership, disband and round-reset boundaries. Lock and
display name remain logical session state across round release.

# Perk requests

Perk purchase and activation requests are client intent only. The server derives the player from `remoteExecutedOwner`, reads configured price and authoritative progression, commits atomically, marks persistence dirty, and publishes only to that owner. Restricted-item cleanup is server-derived; the owning client only applies the server-signed Unit Loadout because `setUnitLoadout` must execute where the player unit is local. Suppressor and MEDIC both use this transaction, and the perk stays active until the server observes the exact sanitized loadout.

The MEDIC engine trait is client-local derived state. Progression publication, state snapshots, local representation initialization and representation handoff re-evaluate it from projected `activePerks` plus the authoritative `ACTIVE` player-state projection. Lobby/non-current representations receive no KOTH Medic authority, and all medikit validation continues to read the server progression registry rather than the trait.

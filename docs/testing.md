Bro-Nation KOTH Vietnam — Testing

1. Purpose

This document defines how Bro-Nation KOTH Vietnam features are tested before they are considered complete.

Testing in Eden or Hosted Multiplayer is useful during development but does not prove dedicated multiplayer correctness.

Features affecting networking, locality, authoritative state, respawning, join-in-progress behaviour or round state must be tested on a dedicated server.

2. Testing Principles

1. Test the smallest useful change first.
2. Test both expected behaviour and failure cases.
3. Check client and server RPT files.
4. Do not treat Hosted Multiplayer as equivalent to a dedicated server.
5. Do not claim a feature is tested unless the relevant test was actually performed.
6. Multiplayer features must be tested with more than one client where practical.
7. Join-in-progress behaviour must be tested for systems that publish or restore mission state.
8. Repeated script errors must be resolved before a feature is considered complete.

3. Test Levels

Level 1 — Mission Load

Verify:

- the mission appears in the mission list;
- the mission loads successfully;
- required includes are found;
- required functions are registered;
- no immediate script errors occur;
- no required class or asset is missing.

Level 2 — Local Development

Verify the feature in Eden or Hosted Multiplayer.

Examples:

- UI appears correctly;
- local actions work;
- loadouts apply;
- configuration values are read correctly;
- basic function logic behaves as expected.

Local development testing is useful for quick iteration but is not final multiplayer validation.

Level 3 — Dedicated Server

Verify:

- the dedicated server starts the mission;
- players can connect;
- authoritative server state initialises correctly;
- remote execution behaves correctly;
- server-only functions do not execute incorrectly on clients;
- client-only functions do not execute incorrectly on the server;
- no repeated RPT errors occur.

Features affecting multiplayer state are not complete until this level has been tested.

4. Multiplayer Test Cases

Where relevant, test:

- WEST player joining;
- EAST player joining;
- two or more clients connected simultaneously;
- player death;
- player respawn;
- player disconnect;
- player reconnect;
- join in progress;
- mission restart;
- server restart;
- player changing state during an active system;
- invalid requests;
- repeated requests;
- simultaneous requests from multiple clients.

5. Round Testing

Round-related changes must verify:

- WAITING state initialises correctly;
- PREPARING begins only when valid;
- ACTIVE begins correctly;
- score cannot be awarded outside ACTIVE;
- ENDING occurs when the win condition is met;
- RESETTING cleans up the previous round;
- the next round can begin without stale state remaining.

Round state transitions must not occur in an invalid order.

6. Zone Testing

Zone-related changes must verify:

- no players in the zone results in neutral state;
- one team in the zone gains control;
- equal eligible players results in contested state;
- additional players correctly change control;
- dead players do not count;
- incapacitated players do not count;
- spectators do not count;
- players leaving the zone are removed from the calculation;
- disconnected players are removed from the calculation;
- zone state updates at the expected interval;
- actual-player, weighted-control and Priority-occupancy values come from the same eligible-player pass;
- the bottom-right HUD shows WEST/EAST team scores, AO status, round lead,
  scoring progress, local rank/level/XP, published WEST/EAST raw AO population,
  and the published Priority counts as a visually distinct `+N` bonus without
  independently scanning players;
- missing progression state shows a safe syncing presentation and maximum level
  never displays an invalid next-level requirement;
- HUD presentation does not change published population values, Priority
  weighting, zone control, scoring, or the debug display;
- the configured battlefield pickup count is attempted once per active AO,
  holders stay within the active marker with bounded placement attempts, factual
  compatible ammunition is included, pavement/sidewalk surfaces do not bury the
  holder, per-holder diagnostics identify RNG output and final position, and
  active-location cleanup deletes all tracked holders without granting
  progression entitlement;
- controlled-AO score progress and award cadence use the config-owned 30-second
  interval without changing point or reward values;
- the Priority client-local Simple Task is created once without notification,
  follows the global moving marker, and is removed outside ACTIVE state or when
  the deployed HUD/AO/Priority marker is absent;
- friendly 3D icons bypass geometry LOS only within the configured 25-metre
  proximity threshold; maximum range and beyond-threshold LOS remain unchanged.

If vehicle occupants count toward control, test players entering and leaving vehicles inside the zone.

7. Scoring Testing

Scoring-related changes must verify:

- score is awarded only to the controlling team;
- score is not awarded while neutral;
- score is not awarded while contested;
- score is not awarded outside the ACTIVE round state;
- score increments by the configured value;
- score uses the configured interval;
- reaching the configured score limit triggers the expected win behaviour;
- clients cannot directly award team score.

8. Respawn Testing

Respawn-related changes must verify:

- players respawn on the correct side;
- enemy spawn positions cannot be used;
- protection is active only while a deployed player is spatially inside the player's own active safe zone;
- leaving removes protection and re-entering restores it without a timer;
- no friendly safe-zone status indicator is visible while protection is active;
- leaving a friendly safe zone shows the exact `LEAVING SAFE ZONE` message in
  green for five seconds in a centered, half-screen-width banner at the shared,
  slightly lowered top position and then removes it;
- re-entering the friendly safe zone removes the exit message immediately, and
  death, respawn, enemy-safe-zone entry, or a non-active safe-zone round state
  does not leave or create a false exit message;
- protected players cannot fire, cause damage, or receive damage;
- an enemy intruder cannot fire, cause damage, or enter a vehicle but remains damageable;
- entering an opposing safe zone shows the exact persistent warning
  `ENEMY SAFE ZONE LEAVE NOW` in red text in the same centered,
  half-screen-width banner position, and leaving removes it;
- the enemy warning does not interfere with the friendly exit notification or
  unrelated HUD controls;
- an enemy already in a vehicle is ejected when entering the opposing safe zone;
- an enemy intruder can be run over by a protected friendly vehicle inside that safe zone;
- friendly vehicles are protected only when their center is inside their own safe zone;
- protected vehicles cannot fire or receive damage, including after vehicle locality changes;
- enemy vehicles never gain opposing-safe-zone protection, remain damageable, and cannot cause damage while inside it;
- protected collision damage remains blocked against every victim except an enemy intruder in that safe zone;
- a player cannot open self, friendly, enemy, corpse, ground-holder, crate, static-weapon or vehicle inventory while either the player or container is inside either safe zone;
- inventory access is also blocked when the player and container are on opposite sides of a safe-zone boundary;
- an inventory opened outside closes when the player or container enters a safe zone and normal access returns after both leave;
- vehicle cargo is preserved while inaccessible inside a safe zone and remains intact after leaving;
- weapons, magazines, attachments and backpacks dropped inside a safe zone disappear for all clients and do not return for JIP players;
- static-weapon assembly or disassembly cannot leave accessible weapon bags or physical inventory inside a safe zone;
- safe-zone AI corpses are deleted immediately and player corpses are unlootable immediately, then deleted without breaking UID resolution or respawn;
- corpses and dropped equipment created in the active AO outside safe zones remain available for normal scavenging;
- the server-validated KOTH loadout path still works in a safe zone without opening physical inventory;
- battlefield pickup and scavenging continue to work in the active AO outside safe zones even below level, unowned, or unmastered; the physical item remains usable while it grants no Arsenal, Store, ownership, rental, or saved-loadout entitlement;
- safe-zone status survives respawn representation handoff and is cleared outside active safe-zone states;
- reconnecting does not produce invalid spawn state.

Starter-loadout configuration changes must additionally verify on a dedicated
server that both WEST and EAST definitions initialize, receive the configured
side-correct assigned equipment, derive each weapon's generated canonical
`baseMagazine`, load those compatible magazines at
their actual `CfgMagazines` capacity, carry the configured spare counts in the
configured containers, and remain the native respawn/deployment fallback.
Invalid weapon compatibility, assigned-slot order, equipment classes, cargo
classes, counts, or cargo-without-container definitions must be rejected with a
clear server RPT warning rather than silently falling back to template gear.

9. Join In Progress Testing

A joining player must receive the current active mission state rather than assuming a new round.

Where relevant, verify that a JIP player receives:

- current round state;
- active combat location;
- current zone information;
- current zone owner;
- current active safe-zone marker names;
- current raw, weighted and Priority population;
- current team scores;
- configured winning score;
- relevant timers;
- any other client-visible authoritative state required by the active system.

10. Remote Execution Testing

For client-to-server requests, test:

- valid request;
- invalid identifier;
- wrong side;
- invalid position where relevant;
- incorrect round state;
- insufficient requirements;
- repeated request spam;
- request after disconnect or death where relevant.

For server-to-owner safe-zone endpoints, also verify that non-server remote callers are rejected and that listen-server players receive the same ejection and vehicle-protection behavior as dedicated clients. Verify safe-zone inventory and cleanup behavior with at least two clients so object deletion, container locality, respawn and JIP visibility are covered.

The server must reject invalid requests without creating inconsistent state.

11. Performance Testing

Every repeating system should be reviewed for unnecessary frequency.

Ask:

1. Does this need to run every frame?
2. Can it run once per second?
3. Can it run only when state changes?
4. Can one server calculation replace repeated client calculations?
5. Can an event handler replace polling?
6. Is the same unchanged state being unnecessarily broadcast?

Do not use per-frame execution for zone control, scoring, progression, persistence or cleanup without a documented requirement.

12. RPT Review

Check both:

- server RPT;
- client RPT.

Look for:

- undefined variables;
- missing functions;
- remote execution errors;
- locality errors;
- missing classes;
- repeated warnings;
- repeated debug logs;
- script loops producing excessive output.

A feature producing continuous error spam is not considered complete even if the visible gameplay appears to work.

13. Regression Testing

When changing an existing system, verify the behaviour that previously worked still works.

Examples:

- zone changes must not break scoring;
- scoring changes must not break round victory;
- respawn changes must not break team assignment;
- UI changes must not alter authoritative state;
- persistence changes must not alter live round logic.

Persistence changes must also run
`call compile preprocessFileLineNumbers "functions\persistence\test_persistence.sqf"`
on a hosted server and expect `[]`. Verify first-time defaults, known-state load,
XP-derived level, cash/ownership/mastery normalization, rental and round-state
exclusion, legacy/future schema handling, repeated-registration idempotence, and
dirty-state save success/failure. A failed save must remain dirty and produce a
server RPT error; it must never be reported as successful. Dedicated testing must
confirm disconnect and mission-end flush markers without any persistence RemoteExec
entry or per-frame activity.

Pure extDB3 adapter checks in the same test cover deterministic owned-weapon and
weapon-kill serialization, malformed codec input, valid/error/malformed extDB3
response parsing, and persistent projection exclusions. `MEMORY` is used only to
exercise the service contract without a database. Before deployment, follow the
live matrix in `docs/deployment-extdb3.md`: verify first-time insert, valid reload,
mutation/disconnect UPSERT, reconnect, full server restart, unavailable database,
and malformed/future-row fail-closed behavior. Inspect both the server RPT and
extDB3 log; a session fallback is not proof of durability.

Test the directly affected system and any system that depends on it.

For the Arsenal rework, also verify:

- opening at the correct team mapboard reconciles the overview from the
  server-observed physical player loadout;
- an unentitled battlefield pickup remains physically usable, but Arsenal
  reconciliation does not retain it in the reusable intended-loadout baseline;
- after that reconciliation, changing an unrelated wearable/cargo slot does not
  reapply the picked-up weapon;
- replacing the unentitled pickup with an entitled weapon remains possible;
- saving a physical snapshot never grants entitlement: loading that local kit
  without current authoritative entitlement is rejected;
- death/respawn, reconnect, and server restart do not convert picked-up weapons
  into ownership or rental state;
- each browser opens on the currently applied item when one exists, without
  repeatedly overriding manual pagination;
- locked weapons, attachments, wearables, assigned items, and positive cargo
  additions cannot be submitted successfully by an under-level client;
- cargo removal remains possible when entitlement has subsequently been lost;
- partial slot changes do not restore unrelated equipment;
- locally named kits survive a client restart, while edited or malformed local
  profile data is rejected by server validation;
- repeated browser, Configure, cargo, assigned-item, and kit-manager entry and
  exit does not leave stale controls, actions, pages, or draft state;
- authoritative return to the lobby closes an open deployed menu through its
  normal unload path from every page, while ACTIVE/RESPAWNING state leaves it
  open and stale `BN_KOTH_menuDisplay` state is cleared;
- lobby player-name presentation preserves short names and width-fits only
  overflowing names with an ellipsis in the local-player header, both team
  rosters, and all three Live Leaders cards. Test `Legend`, a clan/prefix name,
  spaces and permitted punctuation, plus the 24-character `W`, `M`, and `i`
  torture cases documented by the profile-name acceptance boundary;
- the disabled operator preview creates no camera or render-to-texture view;
- client and server RPT files remain free of Arsenal script errors throughout
  the complete flow.

Equipment-side policy changes must additionally verify:

- WEST-only, EAST-only, and both-sides `allowedSides[]` decisions;
- opposing uniforms, vests, and backpacks are rejected in both directions;
- headgear with `appearanceSide=BOTH` is usable by WEST and EAST alike,
  subject to `minLevel` only;
- missing appearance metadata fails closed while missing combat metadata
  remains temporarily uncontrolled;
- level gates appearance entitlement regardless of side/appearance being
  otherwise correct, and no Mastery/ownership/rental signal is ever consulted
  or reported for appearance items;
- `sourceAffiliations[]` never grants or revokes entitlement in either
  direction;
- structural weapon variants inherit the canonical root policy;
- direct slot mutation, saved-kit application, starter validation, respawn,
  and deployment restore cannot bypass the authoritative decision;
- client filtering agrees with the server but cannot grant entitlement.

After mission functions and config initialize, the focused pure-policy checks
can be run in an appropriate in-engine test context with:

```sqf
call compile preprocessFileLineNumbers "functions\progression\test_equipmentSidePolicy.sqf"
```

An empty returned array is a pass. This focused check does not replace hosted
and dedicated two-side testing or client/server RPT review.

Session cash API checks can be run on a hosted or dedicated server after
mission functions initialize:

```sqf
call compile preprocessFileLineNumbers "functions\progression\cash\test_cash.sqf"
```

An empty array is a pass. Hosted and dedicated testing must additionally verify
one cash award per validated kill/control/Priority event, no reward for rejected
events, starting cash only once across respawn/side/round changes, targeted
client updates, atomic insufficient-funds rejection, and clean server/client
RPT output.

Canonical weapon price authoring must additionally verify that every priced
entry is a canonical root, no structural variant owns a manual price, rental is
20% of purchase, Level 1 starter roots remain unpriced until starter ownership
has an authoritative owner, and Store purchase/rent results agree with the
server-owned cash and acquisition state.

Weapon acquisition transaction rules and server-session initialization can be
checked after mission functions initialize with:

```sqf
call compile preprocessFileLineNumbers "functions\progression\acquisition\test_weaponAcquisition.sqf"
```

An empty array is a pass. Dedicated testing must still verify the public
purchase/rent APIs with explicitly priced test metadata, one targeted update
per committed transaction, no charge on repeated requests, canonical
structural-variant inheritance, no equipment application, rental survival
across respawn/side/round transitions, and clean server/client RPT output.

Weapon entitlement and mastery checks can be run after mission
functions initialize:

```sqf
call compile preprocessFileLineNumbers "functions\progression\test_weaponEntitlementRules.sqf"
call compile preprocessFileLineNumbers "functions\progression\mastery\test_weaponMastery.sqf"
call compile preprocessFileLineNumbers "functions\progression\test_progressionMetadata.sqf"
```

Each must return `[]`. Dedicated testing must verify that one uniquely
attributed valid PvP kill increments the canonical root once, structural
variants share that root, ambiguous/non-infantry/explosive evidence awards
nothing, and mastery survives respawn, side changes, and round transitions.
Cross-side acquisition must fail before cash mutation until explicit
permission, level, mastery, and perks all pass.

Config-driven rank presentation checks can be run after mission functions
initialize on a client or hosted session:

```sqf
call compile preprocessFileLineNumbers "functions\progression\test_rankPresentation.sqf"
```

An empty array is a pass. Hosted UI testing must additionally confirm that the
lobby local-player card, WEST/EAST roster rows, every deployed-menu page, and
each newly opened pause display show the same config-derived insignia shape and
bronze/silver/gold tint. Recruit levels must preserve aligned blank roster icon
columns and show no icon or textual fallback. Repeated pause opening must not
duplicate controls. Rank presentation must not call `setRank`/`setUnitRank`,
mutate progression, or add rank fields to persistence.

14. Combat Attribution Probe

The pure factual candidate checks can be run after mission initialization:

```sqf
call compile preprocessFileLineNumbers "functions\combat\test_weaponAttribution.sqf"
```

An empty array is a pass.

For a hosted or dedicated diagnostic session, execute on the server before
shots are fired:

```sqf
missionNamespace setVariable ["BN_KOTH_combatAttributionDiagnostics", true];
[] call bn_koth_fnc_combat_initAttributionDiagnostics;
```

Search the server RPT for `[BN_KOTH][ATTRIBUTION]`. The expected event sequence
is `ENABLED`, `PROJECTILE`, `HIT`, `KILL`, and `PROJECTILE_DELETED`. The probe
uses disabled-by-default verbose logging. Collection remains server-only,
event-driven, and bounded per victim; only the separate mastery owner may
consume a finalized unique result attached to a valid PvP kill.
Run the dedicated matrix with: M16; M16 then pistol switch before impact; two
carried roots sharing ammo; a structural/camo variant; pistol; grenade;
handheld launcher; delayed explosive; vehicle MG; attack-helicopter cannon and
rocket; multiple attackers; and shooter death/disconnect before impact. Record
the `KILL.result`, `reason`, canonical candidates, hit-to-kill timing, and
projectile lifetime for every case. Any missing server projectile/hit callback,
multiple canonical candidates, non-infantry source, or non-infantry ammo
category must remain `UNKNOWN`/`AMBIGUOUS`. `EntityKilled` supplies the lethal
fact; projectile callbacks are expected to observe the victim before final
damage/death state becomes visible.

15. Definition of Tested

A feature may be considered tested when:

- expected behaviour works;
- relevant failure cases were checked;
- required multiplayer scenarios were tested;
- dedicated-server testing was completed where required;
- client and server RPT files were reviewed;
- no repeated script errors remain;
- documentation reflects the implemented behaviour.

16. Store V1 Checks

Run `functions/ui/menu/test_storeV1.sqf` in a client debug context and
`functions/progression/acquisition/test_weaponAcquisition.sqf` on the server;
both return `[]` on success. Hosted and dedicated tests must also verify
root-to-category and category-to-product navigation, canonical-only deterministic
weapon ordering, global WEST/EAST/BOTH weapon visibility, level/mastery/perk
locks, unconfigured-price safety, buy/rent outcomes, rental-to-owned upgrade,
requester-only results, targeted progression repaint, the exact curated vehicle
surface (37 Ground, 29 Rotary Wing, 18 Fixed Wing, no SEA), real config pictures,
disabled vehicle actions while locked, four-card pagination, Store-only operator
panel collapse/restoration, Primary/Handgun/Launcher Arsenal handoff with target
page snap/highlight, and tab transitions without stale controls.

Also cycle Store -> Loadout -> Arsenal -> Configure -> Saved Loadouts several
times and verify canonical title/subtitle/BACK/action/pagination geometry is
restored without cumulative drift. Cross-side mastery-capable cards must expose
current/required progress even below level; prohibited products must say
`FACTION RESTRICTED`; unusable cross-side discovery products must remain absent
from Arsenal. Saved-loadout LOAD feedback must follow successful authoritative
application. EDIT must establish context only after the same validation path
succeeds; SAVE CHANGES must update the selected local record without creating a
duplicate, while CANCEL EDIT or closing the menu must leave the stored record
unchanged.

17. Vehicle Progression Metadata Checks

After mission functions and S.O.G. configuration initialize, run:

```sqf
call compile preprocessFileLineNumbers "functions\vehicles\test_progressionMetadata.sqf"
```

An empty array is a pass. The focused check verifies valid explicit Store
categories, roles, sides, finite non-negative levels/prices, resolvable and
acyclic canonical links, policy-free structural entries, deterministic Store
projection, curated product count, the reserved SEA category boundary,
side/level eligibility and absence of weapon mastery policy.

Hosted and dedicated testing must confirm that existing managed free and
command vehicles still spawn and recycle exactly as before. For paid rentals,
run:

```sqf
call compile preprocessFileLineNumbers "functions\vehicles\test_rental.sqf"
```

An empty array is a pass. Then verify: RENT is the complete transaction (a
successful RENT immediately spawns the active vehicle in the same request,
with no separate requisition/pending step); cash is deducted exactly once and
only after the vehicle exists; a blocked spawn (occupied pads and no safe
fallback) leaves no vehicle, no active record and no charge, and the player
remains `AVAILABLE TO RENT`; destroyed/cleaned vehicles restore nothing and
begin cooldown; cargo is empty while mounted armament remains; owner/group/
public access is enforced; occupied pads cannot collide; disconnect does not
instantly delete occupied vehicles; and restart clears all rental state.

18. Development Progression Debug Script

`functions/progression/test_setProgression.sqf` is a standalone, non-registered
developer script for quickly staging Store/vehicle test states (level, cash,
optionally one canonical weapon's mastery kill count) on a hosted or dedicated
server. It grants no client-callable endpoint. Edit the `_targetPlayer`,
`_targetLevel`, `_targetCash`, and optional `_debugWeaponClass`/
`_debugMasteryKills` values at the top of the file, then paste the file's
contents into the server-side debug console (select "Server" execution) and
run it, or execute:

```sqf
call compile preprocessFileLineNumbers "functions\progression\test_setProgression.sqf"
```

The target player must already be registered (joined and assigned a side).
The script derives XP from the existing level curve, adds/reduces XP and cash
through the existing authoritative progression APIs, marks persistence dirty
normally, and publishes the normal targeted progression update. Result UID,
XP, level and cash print to RPT and `systemChat`.

19. Arsenal Direct Weapon Acquisition

Native-side Arsenal browser cards now show `BUY $X`/`RENT $Y` in place of
`APPLY`/`CONFIGURE` while entitlement is `REQUIRES_ACQUISITION` (side, level,
mastery and perks already satisfied, ownership/rental still missing), and
submit through the exact same `bn_koth_fnc_progression_requestWeaponAcquisition`
endpoint Store uses. Verify:

- a below-level native weapon shows `LOCKED · LEVEL N` with no BUY/RENT;
- a level-eligible unacquired native weapon shows `AVAILABLE TO ACQUIRE` with
  BUY/RENT enabled only up to the player's current cash;
- BUY/RENT from Arsenal succeeds without a Store round-trip, and the card
  becomes `OWNED`/`RENTED` with normal `APPLY`/`CONFIGURE` actions, staying on
  the same browser slot/page;
- an insufficient-cash attempt is rejected server-side with the existing
  notification, and the card state is unchanged;
- a cross-faction weapon with incomplete mastery never appears in the Arsenal
  browser at all, while it remains discoverable/acquirable in Store;
- once that cross-faction weapon is fully entitled (owned/rented, mastery
  complete, perks satisfied), it appears in Arsenal like a native weapon;
- Store weapon BUY/RENT continues to work unchanged from Store.

20. Vehicle Rental RPT Audit Trail

`functions/vehicles/fn_rentVehicle.sqf` logs every RENT outcome to RPT. A
successful RENT logs UID, canonical class, pad id (or `FALLBACK`), spawn
position, `netId` and cash charged; a failed RENT logs UID, requested class,
code and exact reason, with no charge. Verify the Store card only ever shows
`AVAILABLE TO RENT` (or `LOCKED`/`INSUFFICIENT CASH`/`COOLDOWN`) before a
successful RENT, and `VEHICLE ACTIVE` only after a logged `RENTED` success with
a real `netId`. There is no `REQUISITION` action, no `RENTAL READY` state, and
no pending-rental state anywhere in the client or server rental payloads.
# Perk foundation manual matrix

Run on hosted and dedicated servers with the extDB schema-v2 migration applied:

- Fresh/legacy player: `ownedPerks=[]`, `activePerks=[]`; malformed, duplicate, unknown, non-owned active, and over-limit persisted IDs normalize safely.
- Purchase Suppressor at $1: cash falls once, ownership appears once, duplicate/spammed purchase does not charge again, reconnect restores it.
- Activation: unowned is rejected; owned activates without a fee; repeated/rapid requests cannot exceed the configured maximum of three; reconnect restores the normalized active subset.
- Inactive Suppressor: primary, handgun, launcher, uniform, vest, and backpack suppressors are rejected from managed requests with `ERR_PERK_SUPPRESSOR_INACTIVE`.
- Active Suppressor: the same otherwise-valid managed loadouts succeed.
- Deactivation with none present succeeds immediately. With any present it asks for confirmation; cancel changes nothing; confirm removes every factual suppressor from equipped slots and cargo, applies the sanitized intended loadout, then deactivates. Failed/incomplete cleanup leaves it active.
- A saved kit containing a suppressor remains unchanged, fails while inactive, and succeeds while active if all other entitlement checks pass.
- Battlefield pickup remains possible while inactive; death/redeployment returns to the existing starter/validated-loadout behavior.
- Dedicated security: invoke requests only from the owning client and confirm forged UID/cost/ownership/loadout data is neither accepted nor part of the endpoint schema.

Focused server tests: `call compile preprocessFileLineNumbers "functions\progression\perks\test_perks.sqf"`. Expected result: `[]`.

21. Advanced Traversal Checks

After mission functions and S.O.G. configuration initialize, run:

```sqf
call compile preprocessFileLineNumbers "functions\traversal\test_traversal.sqf"
```

An empty array is a pass. The focused check verifies configured classification
boundaries, the unbound-default gamemode action, required stock animation
states, mantle climb-first/top-off-last phase selection, no finish phase for
step-over/vault, and absence of a traversal RemoteExec endpoint.

Hosted and dedicated testing must additionally bind the action and verify
step-over, vault, low/medium/high mantle, on-top and over-obstacle landings with
rifle, pistol, launcher and unarmed states. Every mantle must begin with the
matching `Ladder*UpLoop` and call the matching `Ladder*TopOff` only after the
unit reaches its final landing position; step-over and vault must never call a
ladder top-off. Verify rejection while dead,
incapacitated, prone, underwater, attached, in a vehicle, already traversing,
inside the cooldown, without an obstacle, without landing support, and with
blocked headroom. Death, respawn, `selectPlayer` representation handoff and
locality loss during movement must release the traversal lock or safely cancel.
With two clients, confirm movement is visible remotely, no traversal function
is remotely executed, no persistent/JIP state is created, and client/server RPT
files contain no repeated traversal errors. Enable `Diagnostics.debugDraw` only
for a separate probe-visualization pass and confirm the handler is absent when
the option is disabled.
21. Deployment Transition Presentation

The deployment transition is client-local presentation over the existing
authoritative `WAITING -> PREPARING -> ACTIVE` lifecycle. On hosted and
dedicated servers verify:

- a selected player sees the transition before the lobby closes or the
  PREPARING gameplay representation becomes visible;
- the retained lobby blackout plus the transition's absolute-width opaque
  background leaves no terrain, world object, HUD or screen-edge gap visible;
- walking, sprinting, firing, interaction and gameplay controls are blocked
  while the transition owns presentation, then return after normal reveal,
  PREPARING abort and participation loss;
- the theatre uses loaded-world metadata and the AO uses the selected
  `CfgBnKothLocations` display name;
- a fast preparation reaching `ACTIVE` first still plays the complete
  typewriter sequence before fading into gameplay;
- a slow preparation finishing the sequence first holds on `READY` and
  `AWAITING DEPLOYMENT CLEARANCE` until authoritative `ACTIVE` arrives;
- a PREPARING abort to `WAITING`, removal from the participating set, or a
  failed deployment removes the transition and restores the normal lobby with
  no permanent black screen;
- repeated rounds and duplicate state publications create only one transition
  resource and one typewriter script per client;
- each run produces one controlled typo in an operational status line,
  visibly backspaces and corrects it, and leaves the final order correct;
- the slower variable cadence, selected blinking-cursor thought pauses and
  brief `READY_` hold remain natural without spawning separate cursor scripts;
- the normal BN KOTH score/AO/rank HUD is withdrawn as transition ownership
  begins, remains absent through fast/slow preparation and the final fade, then
  restarts exactly one animator only after successful transition cleanup;
- a PREPARING abort leaves both transition and gameplay HUD hidden while the
  normal lobby lifecycle resumes;
- two or more clients animate independently without presentation traffic or
  any effect on server readiness;
- a JIP client during PREPARING either enters the same transition safely or
  remains in the lobby when not selected, and no client joining directly into
  ACTIVE receives a fabricated deployment sequence.

During each case confirm the existing `BN_KOTH_LobbyBlackout` remains behind
the transition with no visible frame of AO setup and that the transition's
fade does not remove the HUD, lobby, or other named UI layers.

22. Round-End Results Presentation

The round-end results screen is client-local presentation over the existing
authoritative `ACTIVE -> ENDING -> RESETTING -> WAITING` lifecycle. On hosted
and dedicated servers verify:

- normal round end shows the authoritative winning side, both final team
  scores, and the same MOST DEADLY, OBJECTIVE and BEST STREAK values shown by
  the lobby Live Leaders cards;
- missing or zero-value leader entries render `NO LEADER` with the appropriate
  zero-value `KILLS`/`PTS` fallback;
- RESETTING and player return-to-lobby cleanup remain fully concealed by the
  opaque results layer, with no gameplay HUD, deployed menu, world frame or
  half-reset AO visible;
- movement, firing and interaction remain blocked while results own
  presentation, and input is restored after both the minimum results sequence
  and authoritative lobby readiness have completed;
- a fast reset reaching WAITING before the sequence finishes does not reveal
  the lobby early, while a slow reset holds on `RETURNING TO OPERATIONS...`
  until WAITING and the local lobby representation are ready;
- long leader names remain within their cards through the existing width-aware
  lobby name fitter;
- repeated rounds show only the new winner/scores/leaders, create one results
  resource and presentation script per client, and do not leave stale input,
  blackout or HUD state;
- display recreation during ENDING/RESETTING safely rebuilds the presentation
  from the completed-round snapshot, and a JIP client during those states does
  not expose cleanup or fabricate authoritative result data;
- multiple clients render independently with no cosmetic network traffic and
  no delay to the server round lifecycle.

23. Population-Aware AO and Location Vehicle Capability

Pure population-bound checks:

```sqf
call compile preprocessFileLineNumbers "functions\round\test_populationEligibility.sqf"
```

Spawn-role capability checks:

```sqf
call compile preprocessFileLineNumbers "functions\zone\test_vehicleCapabilities.sqf"
```

Both return `[]` on success. On a hosted and dedicated server also verify:

- 1-3 connected humans receive only population-eligible choices;
- 60 humans joining but remaining in LOBBY count immediately for AO sizing;
- crossing 20/21 invalidates Son Tay, while movement inside the 15-20 overlap
  does not reset still-valid candidates;
- high-to-low crossing refreshes full-size candidates;
- open and closed vote refreshes remove invalid votes and publish consistent totals;
- resolution cannot select a newly ineligible AO;
- the deterministic nearest-range fallback logs clearly when no range matches;
- previous-location exclusion remains effective when an alternative exists;
- JIP clients receive the current candidates, totals and votes;
- an AO lacking vehicle roles keeps INFANTRY usable and shows GROUND, ROTARY
  and FIXED WING as `DISABLED FOR THIS AO`;
- disabled Store categories cannot be opened and a stale route returns to ROOT;
- direct rental requests fail before spawn or cash mutation when the paid role
  is absent;
- missing free roles construct no managed slots and do not invalidate the AO;
- missing command spawn roles create no command vehicle or teleport action,
  while the mapboard's unrelated Open Menu action remains available;
- direct command-teleport requests remain rejected server-side;
- enabled-to-disabled AO changes delete old command vehicles/actions and JIP
  receives the current command availability.
Career persistence and leaderboard backend dedicated-server checks

After a full mission restart with extDB3 ready, run on the server:

```sqf
[] call bn_koth_fnc_career_test
```

Expected result: `[]`.

Then verify with two human clients and RPT/database inspection:

1. Join with a new Steam UID and confirm `upsertCareerIdentity` creates one
   career row; reconnect with a changed profile name and confirm the same UID
   row is updated rather than duplicated.
2. During `ACTIVE`, perform one valid enemy PvP kill. Confirm exactly one killer
   kill, one victim death, and the new streak maximum reach both lifetime and
   the current UTC hourly bucket. Suicide, teamkill, AI and ignored kill records
   must add no career kill.
3. Die once and confirm duplicate respawn/lifecycle callbacks do not add another
   death. Confirm the live round streak still resets while the lifetime maximum
   never decreases.
4. Earn one physical objective score tick and confirm the exact team-score
   points credited by `roundStats_recordObjectiveTick` become career objective
   contribution. Priority bonus XP must not inflate that counter.
5. Complete a round. Confirm each UID in the authoritative participant snapshot
   receives one round played, winners receive one win, losers receive none, and
   reconnect/reset notifications cannot repeat the result.
6. Earn each existing XP reward type and confirm `total_xp_earned` increases by
   the accepted positive award while current progression XP remains independently
   stored in `bn_koth_player_progression`.
7. Remain connected across at least two 60-second samples. Confirm playtime is
   stored in seconds, no per-second DB writes occur, and disconnect performs a
   final accumulation/flush without counting offline time.
8. Temporarily make extDB3 unavailable. Confirm gameplay continues, career
   mutations remain bounded/queued, leaderboard queries return a structured
   unavailable result, and no fabricated leaderboard rows are returned.
9. Exercise `bn_koth_fnc_career_queryLeaderboard` for metric IDs `1..9`, periods
   `0..3` (`0` = all time), and `TOP`, `RANK`, `AROUND`, `COUNT`. Verify limits
   cap at 25, K/D comes from the database query, ranking uses value descending
   then UID ascending, and no caller-supplied SQL/query/table/column is accepted.
10. Confirm hourly pruning runs no more frequently than the configured daily
    interval and retains approximately 32 days.

The external deployed `bn_koth.ini` must be checked against the parameter order
used by the semantic adapter before release: UID followed by kills, deaths,
wins, rounds played, objective contribution, highest streak, total XP earned
and playtime seconds; rolling queries additionally consume the approved period
ID as configured by their SQL_CUSTOM statements.

24. Deployed Weapon Mastery Progression Page

Run the focused catalogue/projection check in a client debug context:

```sqf
call compile preprocessFileLineNumbers "functions\ui\menu\test_progressionMasteryUi.sqf"
```

Expected result: `[]`. With the deployed menu open, the same check also verifies
that its dedicated fixed-control pool exists.

For visual/runtime acceptance, use a hosted session with representative
authoritative `weaponKills` values and verify:

- opening `PROGRESSION` freshly always selects `IN PROGRESS`;
- zero-progress weapons are absent from `IN PROGRESS`, partial progress shows
  the exact kill count/requirement, and the most progressed entries
  sort first;
- `COMPLETED` contains only completed weapons with the `MASTERED` treatment;
- `ALL` contains every mastery-capable weapon exactly once, with no structural-variant duplicates;
- zero, tiny, near-complete and over-complete values render bars within 0-100%;
- missing pictures leave a neutral image area, and long display names remain
  within their card;
- all empty states are intentional, filtering/paging creates no controls or
  event handlers, and closing/reopening resets the filter;
- `PROGRESSION -> LOADOUT/STORE/PERKS -> PROGRESSION` leaks no controls or
  actions between views;
- a received progression update refreshes the open page without mutating XP,
  Level, weapon kills, ownership, rental, Perks or entitlement;
- no script/config errors appear in RPT.

Also exercise every deployed-menu return path: selector, configure,
magazine/attachment, cargo/container, saved kits, Store, Perks and Progression.
Each visible `BACK` control must retain its existing destination while matching
the `EXIT MENU` control's size and bottom alignment at the opposite (bottom-right)
edge. Repeatedly switch between those views and confirm only one `BACK` control
is visible, no control overlaps it, and `ESC`/menu reopen behaviour is unchanged.

No dedicated-server acceptance is claimed by this presentation test. A normal
dedicated progression award should still be observed on a client to confirm
the existing bounded projection refreshes the open page end to end.

25. Stats And Leaderboard Page

Run the focused contract/formatting checks from the debug console:

```sqf
call compile preprocessFileLineNumbers "functions\ui\menu\test_stats.sqf"
```

Run the server-side single-row career-summary projection checks separately:

```sqf
call compile preprocessFileLineNumbers "functions\career\test_careerSummary.sqf"
```

Expected result: `[]`. These checks cover the semantic metric/period/mode
allowlists, bounded limits, K/D safety, duration formatting, and the distinction
between legitimate zero values and unavailable data. Runtime menu acceptance
must additionally verify fresh-entry defaults (`KILLS`, `ALL TIME`, `TOP`),
clickable metric cards, all period/mode controls, local-row highlighting,
loading/empty/unavailable states, control cleanup across every deployed-menu
route, and the fixed `EXIT MENU` left / `BACK` right layout.

Live persisted totals and leaderboard windows remain dedicated-server database
acceptance and must not be claimed by the focused UI checks.

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
- the bottom-right HUD shows WEST/EAST team scores, AO status, round lead, and
  scoring progress without showing actual-player, weighted-control,
  Priority-occupancy, or personal Priority-status rows;
- removing those HUD rows does not change published population values, Priority
  weighting, zone control, scoring, or the debug display.

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
- the disabled operator preview creates no camera or render-to-texture view;
- client and server RPT files remain free of Arsenal script errors throughout
  the complete flow.

Equipment-side policy changes must additionally verify:

- WEST-only, EAST-only, and both-sides `allowedSides[]` decisions;
- opposing uniforms, vests, backpacks, headgear, and facewear are rejected;
- missing appearance metadata fails closed while missing combat metadata
  remains temporarily uncontrolled;
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

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
- the HUD maps playable-side order to WEST/EAST correctly and reports personal Priority status.

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
- protected players cannot fire, cause damage, or receive damage;
- an enemy intruder cannot fire, cause damage, or enter a vehicle but remains damageable;
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
- battlefield pickup and scavenging continue to work in the active AO outside safe zones;
- safe-zone status survives respawn representation handoff and is cleared outside active safe-zone states;
- reconnecting does not produce invalid spawn state.

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

14. Definition of Tested

A feature may be considered tested when:

- expected behaviour works;
- relevant failure cases were checked;
- required multiplayer scenarios were tested;
- dedicated-server testing was completed where required;
- client and server RPT files were reviewed;
- no repeated script errors remain;
- documentation reflects the implemented behaviour.

Bro-Nation KOTH Vietnam — Game Design

1. Project Summary

Bro-Nation KOTH Vietnam is a team-versus-team multiplayer game mode for Arma 3 using S.O.G. Prairie Fire.

Players fight to control a designated combat zone. A team earns score while it controls the zone. The first team to reach the configured score limit wins the round.

The initial version uses two teams:

- WEST: United States and allied forces
- EAST: PAVN and Viet Cong forces

The game mode must be designed so that additional playable sides can be added later through configuration.

2. Core Gameplay Loop

1. A player joins a team.
2. The player spawns at that team’s protected base.
3. The player selects an available loadout.
4. The player travels to the combat zone.
5. Players fight for control of the zone.
6. The controlling team earns score.
7. The first team to reach the score limit wins.
8. The round ends and resets.

3. Zone Control

Only eligible, living players count toward zone control.

A team controls the zone when:

- it has at least one eligible player inside the zone; and
- it has more eligible players inside the zone than every opposing team.

The zone is contested when two or more teams are tied for the highest player count.

The zone is neutral when no eligible players are inside it.

Example:

- WEST: 8
- EAST: 5
- Result: WEST controls the zone.

Example:

- WEST: 6
- EAST: 6
- Result: Contested.

Players inside vehicles count unless a future balancing decision states otherwise.

Dead players, spectators and incapacitated players do not count.

4. Team Score

Team score is earned only while a team controls the combat zone.

Team score and individual player progression are separate systems.

The score interval, points awarded per interval and winning score must be configurable.

The server is responsible for calculating and awarding all team score.

The deployed bottom-right HUD presents WEST and EAST team scores, current AO
control status, the round lead, and scoring progress. Raw player population,
weighted control, Priority occupancy, and personal Priority status remain part
of authoritative gameplay where applicable but are not displayed in that panel.

5. Player Progression

The current progression implementation is session-scoped and not yet
database-backed. XP, derived level, and cash are server-owned by player UID.
They survive respawn, side changes and round transitions, but not a server
restart.

The current implementation awards XP for:

- validated control participation while a team controls the zone;
- validated participation inside the active Priority zone during a scoring interval;
- validated opposing player kills.

The same validated events provisionally award config-owned cash amounts. Cash
is initialized once when a player first enters server progression state.
Canonical weapons with explicit `purchasePrice` or `rentalPrice` metadata may
be permanently purchased or rented through server-authoritative APIs. Cash and
entitlement change in one transaction, and acquisition never auto-equips the
weapon. Rentals last for the current server session. Store UI, final prices,
stock and persistence are not implemented yet. Weapon-specific session mastery
and the cross-side licence gate are implemented; only uniquely attributed
canonical infantry-weapon PvP kills progress mastery.

The current level cap is configurable and defaults to 270. The Arsenal now
supports human-authored level and perk requirements for canonical weapons,
attachments, wearable/assigned items, and cargo additions. The server repeats
all entitlement checks before accepting equipment intent. Canonical weapon
ownership/rental is implemented as session state; vehicles, final equipment
prices, stock, wider licence content/population, and database persistence
remain unfinished.

Future progression may include:

- persistent currency and economy sinks;
- equipment unlocks;
- vehicle unlocks;
- player statistics.

Progression must reward team participation, not only kills.

Possible future rewards include:

- time spent in the combat zone;
- kills and assists;
- healing and reviving;
- repairing;
- transporting players toward the combat zone;
- destroying occupied enemy vehicles.

6. Respawning

Players respawn at their team base after a configurable delay.

Phase 3 deliberately replaces the former action- and timeout-based spawn-protection design with spatial safe-zone protection.

- A living, deployed player is protected while inside the active safe zone assigned to that player's team.
- Leaving the team's safe zone removes protection immediately; re-entering restores it.
- Protection does not expire on a timer and is not consumed by attempting to fire or cause damage. Those actions are blocked while protection is active.
- Protected players cannot fire weapons or cause outgoing damage and cannot receive incoming damage.
- No HUD indicator is displayed while friendly safe-zone protection is active.
- Leaving the friendly safe zone displays a centered, half-screen-width green
  `LEAVING SAFE ZONE` banner slightly below the top of the deployed HUD for five
  seconds. Re-entering the safe zone, dying, entering an enemy safe zone, or
  leaving an active safe-zone round state removes the message immediately.
- Players must not be able to spawn at an enemy base.

An enemy inside the opposing team's safe zone is an intruder:

- the intruder immediately loses the ability to fire, cause damage, or enter a vehicle;
- an intruder already in a vehicle is ejected when the vehicle enters the opposing safe zone;
- no countdown, execution, or forced relocation is used;
- the intruder remains vulnerable to damage and may be run over inside the opposing safe zone;
- a persistent, centered, half-screen-width warning with red text displays
  `ENEMY SAFE ZONE LEAVE NOW` slightly below the top of the deployed HUD while
  the player remains an intruder; the warning disappears after leaving, and the
  entry and blocked-action notifications identify the weapon, vehicle and
  vulnerability restrictions.

Vehicle protection is also spatial:

- a friendly vehicle is protected while the vehicle's center is inside its own active safe zone;
- a protected vehicle cannot be damaged or fire, and all friendly occupants receive player protection;
- an enemy vehicle never receives protection from the opposing safe zone, remains damageable, and cannot cause weapon or collision damage while inside it;
- protected outgoing damage is blocked except for vehicle collision damage whose victim is an enemy intruder inside that safe zone.

Physical inventory access is disabled inside both active safe zones:

- a player cannot open their own inventory or any player, corpse, ground-holder, static-container or vehicle inventory while the player or target container is inside either safe zone;
- an inventory opened outside a safe zone closes if the player or target container crosses the boundary;
- vehicle cargo is preserved while the vehicle passes through a safe zone and becomes accessible again after leaving;
- dropped equipment and dead bodies inside a safe zone are removed by the server, with player corpses deleted at the earliest engine-safe respawn transition;
- the server-validated KOTH loadout path remains available and does not expose physical container access;
- equipment scavenging in the active AO remains allowed, including equipment above a player's current progression level. Safe-zone restrictions do not change battlefield pickup rules outside the bases.

7. Equipment

The Arsenal provides server-validated selection of faction-appropriate S.O.G.
Prairie Fire weapons, compatible magazines and attachments, wearable and
assigned equipment, and container cargo. Clients present candidates and submit
intent; the server owns validation and application.

Equipment must be defined in configuration rather than spread throughout gameplay functions.

Future versions may include equipment shops, purchases, rentals, and broader
progression balance. No economy behavior is implied by current availability or
entitlement presentation.

8. Vehicles

The first version may use a limited selection of pre-placed vehicles.

Future vehicle systems may include:

- faction-specific vehicle shops;
- level requirements;
- vehicle costs;
- active vehicle limits;
- abandoned vehicle cleanup;
- transport rewards.

Helicopter transport should be an important part of the Vietnam setting.

9. Round States

A round can be in one of the following states:

- WAITING: waiting for enough players;
- PREPARING: players prepare before combat begins;
- ACTIVE: zone control and scoring are active;
- ENDING: a winner has been declared;
- RESETTING: the current round is being cleaned up.

Score cannot be earned outside the ACTIVE state.

10. First Playable Version

The first playable version includes only:

- two teams;
- team spawning;
- one combat zone;
- zone population calculation;
- neutral, contested and controlled zone states;
- team scoring;
- a winning score;
- round ending;
- round resetting;
- basic debug information.

The first playable version does not include:

- database persistence;
- experience or levels;
- currency;
- equipment shops;
- vehicle shops;
- prestige;
- custom stat websites;
- multiple simultaneous combat zones.

11. Design Principles

- Team play is more valuable than kill farming.
- Important values are configurable.
- Faction content is separate from game-mode logic.
- New locations can be added without duplicating the game mode.
- Features are introduced in small, testable stages.
- A feature is not complete until it works on a dedicated server.

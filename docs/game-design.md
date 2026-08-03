Bro-Nation KOTH Vietnam - Game Design

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

5. Player Progression

Persistent progression is not part of the first playable version.

Future progression may include:

- experience;
- levels or ranks;
- currency;
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

Team bases are protected areas.

Spawn protection must end when the player:

- leaves the protected area;
- fires a weapon;
- damages another player; or
- reaches the configured protection timeout.

Players must not be able to spawn at an enemy base.

7. Equipment

The first playable version uses preset faction-appropriate loadouts.

Equipment must be defined in configuration rather than spread throughout gameplay functions.

Future versions may include equipment shops and progression-based unlocks.

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

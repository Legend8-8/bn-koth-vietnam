# Bro-Nation KOTH Vietnam — Arsenal & Loadout Architecture

## 1. Purpose

This document defines the ownership, data model, validation rules, progression boundaries, maintenance workflow, and integration architecture for the Bro-Nation KOTH Vietnam arsenal and loadout system.

The system is deliberately split into four separate concerns:

1. **Factual game data** — what equipment exists in S.O.G. Prairie Fire and how it technically fits together.
2. **KOTH balance metadata** — how Bro-Nation chooses to expose that equipment through progression and faction rules.
3. **Player progression state** — what an individual player has earned, mastered, purchased, or rented.
4. **Server-authoritative validation/application** — whether a requested loadout is currently legal and what actual Arma classnames must be applied.

These concerns must remain separate.

The server owns authoritative gameplay decisions.

Clients display state and submit intent.

Configuration describes data.

Runtime functions perform gameplay behaviour.

No system may create a parallel source of truth.

---

# PART A — ARCHITECTURE

## 2. Ownership

### `config/arsenal/`

Owns KOTH arsenal configuration.

This includes:

- arsenal settings;
- human-authored KOTH equipment metadata;
- generated runtime catalogue data;
- starter/default loadout definitions.

Configuration contains data only.

It must not perform runtime gameplay actions.

---

### `functions/loadouts/`

Owns the gameplay interpretation of arsenal/loadout data.

Responsibilities include:

- loadout validation;
- factual equipment compatibility validation;
- starter/default loadout resolution;
- canonical weapon variant resolution;
- authoritative faction/access checks;
- future progression entitlement queries;
- accepted-loadout application through one controlled path.

There must be one loadout validator.

There must be one accepted-loadout application path.

No other gameplay system may implement a competing version.

---

### `functions/progression/`

Future owner of:

- XP;
- player level;
- rank;
- currency;
- weapon kill/mastery progress;
- weapon licenses;
- permanent ownership;
- rental entitlement;
- progression statistics.

Loadouts may ask progression whether a player is entitled to equipment.

Loadouts must not calculate or independently store progression state.

---

### `functions/persistence/`

Future sole owner of persistent/database state.

This includes:

- XP and level;
- currency;
- weapon kill progress;
- licenses;
- ownership;
- rental state if persisted;
- saved loadouts.

Loadout functions must not communicate directly with the database.

---

### `functions/ui/`

Future owner of player-facing arsenal/loadout presentation.

The UI may display:

- equipment;
- level requirements;
- kill/license progress;
- ownership;
- rental/purchase options;
- rejection reasons;
- current loadout selections.

The UI must not authoritatively decide whether equipment is legal.

---

## 3. The Four Layers of Arsenal Data

### 3.1 Factual S.O.G. Prairie Fire Data

This answers:

> What actually exists in the game?

Examples:

- weapon classname;
- magazine classname;
- attachment classname;
- display name;
- weapon/item type;
- compatible magazines;
- compatible attachments;
- structural weapon variants;
- source affiliation evidence.

This data is generated automatically.

It is not KOTH balance configuration.

---

### 3.2 Human-Authored KOTH Metadata

This answers:

> How do we want this equipment to behave in KOTH?

Future examples include:

- native faction;
- minimum level;
- license kill requirement;
- purchase price;
- rental price;
- starter/free status;
- equipment exclusions;
- special restrictions.

This data belongs to maintainers.

Generated tooling must never silently overwrite these decisions.

---

### 3.3 Player Progression State

This answers:

> What has this specific player achieved?

Examples:

- current level;
- weapon kills;
- license progress;
- license completion;
- ownership;
- rental entitlement;
- currency.

This state belongs to progression/persistence.

It must not be derived from client claims.

---

### 3.4 Canonical Runtime Validation

This answers:

> Is this particular requested loadout legal for this player right now?

The server combines:

- factual equipment data;
- KOTH metadata;
- authoritative player progression;
- authoritative player faction;
- request structure.

The final result is a canonical accepted or rejected loadout.

---

## 4. Generated S.O.G. Equipment Catalogue

The project contains development-time tooling for producing the factual S.O.G. Prairie Fire equipment catalogue.

Conceptually:

```text
S.O.G. Prairie Fire source data
        ↓
catalogue scraper
        ↓
classification / validation
        ↓
data/generated/sog_catalogue.json
        ↓
runtime config generator
        ↓
config/arsenal/generated/sog_catalogue.hpp
        ↓
missionConfigFile
```

Runtime gameplay does not scrape websites.

Runtime gameplay does not parse the generated JSON.

Runtime gameplay consumes the static generated HPP through `missionConfigFile`.

---

## 5. Generated Runtime Catalogue Structure

The generated compatibility data currently exposes factual structures including:

```text
SourceWeapons
SourceMagazines
SourceItems

WeaponMagazines
WeaponAttachments
WeaponVariants

WeaponVariantByBaseAndAttachments
WeaponVariantTransformingAttachments
```

### `SourceWeapons`

Contains factual information for known weapon classes.

### `SourceMagazines`

Contains factual magazine entries.

### `SourceItems`

Contains factual attachment/item entries.

### `WeaponMagazines`

Provides direct weapon → compatible magazine relationships.

### `WeaponAttachments`

Provides direct weapon → compatible attachment relationships.

### `WeaponVariants`

Contains confirmed structural variant relationships.

Ambiguous variant candidates must not be promoted into confirmed relationships.

### `WeaponVariantByBaseAndAttachments`

Provides a generated reverse lookup from:

```text
root weapon
+ exact structural attachment set
→ canonical real weapon classname
```

Example:

```text
vn_m16
+ vn_s_m16
→ vn_m16_sd
```

and:

```text
vn_m16
+ vn_s_m16
+ vn_o_4x_m16
→ vn_m16_mrk_sd
```

Confirmed variant chains are flattened during generation.

The server therefore does not need to scan every variant or recursively discover weapon classes during gameplay.

### `WeaponVariantTransformingAttachments`

Identifies attachments that participate in structural classname transformation for each root weapon.

This allows structural attachments to be separated from ordinary attachment compatibility during validation.

---

## 6. Source Affiliations Are Not KOTH Faction Rules

Generated catalogue data may contain:

```text
sourceAffiliations[]
```

This is factual source evidence only.

It means approximately:

> The underlying S.O.G. Prairie Fire data associates this equipment with these factions.

It does **not** mean:

> These are the only factions allowed to use this weapon in KOTH.

Do not use `sourceAffiliations` as authoritative KOTH access control.

Mixed, Independent, ambiguous, or missing source affiliation evidence must remain factual review information rather than silently becoming gameplay balance.

KOTH faction behaviour is human-authored.

---

## 7. Native Faction Model

Weapons may later receive a human-authored KOTH native faction.

Conceptually:

```cpp
class vn_l1a1_01
{
    nativeSide = "WEST";
};
```

The exact final schema may evolve, but the concept is important.

`nativeSide` answers:

> Which faction naturally receives normal access to this weapon?

It does not permanently prohibit cross-faction use.

Cross-faction access is governed by the weapon license system described below.

---

# PART B — PROGRESSION MODEL

## 8. Core Progression Rule: Level Is King

Every progression-controlled weapon has a minimum required level.

Nothing bypasses this requirement.

Not:

- money;
- ownership;
- license progress;
- completed license;
- kills;
- battlefield pickups;
- rentals;
- purchases.

Conceptually:

```text
playerLevel >= weaponMinLevel
```

must be true before the KOTH arsenal/store system grants access.

### Battlefield pickups

A player may physically pick up and use equipment found during normal gameplay even when below its progression level.

That does not unlock the weapon.

That does not grant ownership.

That does not grant arsenal access.

It may, however, contribute to weapon kill/license progress.

Active base safe zones are a deliberate physical-inventory exception, not a progression exception. Players cannot exchange equipment through player, corpse, ground, static-container or vehicle inventories while either the player or container is inside a safe zone. Dropped equipment and corpses there are cleaned up by the server. Once outside the safe zones, the battlefield pickup rule above remains unchanged.

---

## 9. Levels Grant Eligibility, Not Free Weapons

Reaching a weapon's required level does not automatically give the player that weapon.

Example:

```text
L1A1
Required Level: 20
```

At Level 19:

```text
arsenal access: locked
purchase: locked
rental: locked
license activation: locked
```

At Level 20:

```text
weapon becomes eligible
```

The system then evaluates:

- license;
- ownership;
- rental;
- faction.

Therefore:

> Levels unlock the opportunity to acquire/use the next progression tier.

They do not automatically award equipment.

---

## 10. Weapon Kills and License Progress

Each progression-controlled weapon may have a weapon-specific kill requirement.

Example:

```text
L1A1
Minimum Level: 20
License Requirement: 50 L1A1 kills
```

Kill progress may accumulate before the minimum level.

Example:

```text
Player Level: 12
L1A1 Kills: 20/50
```

Later:

```text
Player Level: 16
L1A1 Kills: 50/50
```

The progress is retained.

The license is still not active because Level 20 has not been reached.

At Level 20:

```text
level requirement complete
kill requirement complete
→ license activates
```

This allows battlefield scavenging and weapon familiarity to matter without bypassing level progression.

---

## 11. License = Cross-Faction Permission

A weapon license represents mastery.

Conceptually:

> The player has demonstrated enough experience with this weapon to use it outside its native faction.

A license does **not** mean the player owns the weapon.

Example:

```text
L1A1
Native faction: WEST
Minimum level: 20
License kills: 50
```

Player:

```text
Level: 20
L1A1 kills: 50
Ownership: no
```

Result:

```text
License: yes
Cross-faction permission: yes
Permanent ownership: no
```

The player may therefore rent the weapon on either faction, subject to economy/rental rules.

---

## 12. Purchase = Permanent Ownership

Purchasing answers:

> Does this player permanently own this weapon?

It does not answer:

> Has this player mastered the weapon?

Purchasing therefore does not automatically grant a cross-faction license.

Example:

```text
Level: 20
L1A1 kills: 10/50
L1A1 ownership: yes
```

On the native faction:

```text
Level requirement: complete
Ownership: complete
→ permanent access
```

On the opposing faction:

```text
Level requirement: complete
Ownership: complete
License: incomplete
→ cross-faction access denied
```

Money must not bypass the mastery requirement.

---

## 13. Owned + Licensed = Fully Completed Weapon

When a player has both permanent ownership and the weapon license:

```text
Level requirement: complete
Ownership: yes
License: yes
```

the weapon becomes permanently usable on both its native and opposing faction.

No rental is required.

This is the final completion state for a normal progression weapon.

---

## 14. Rental

Rental represents temporary economic access.

A rental does not become ownership.

A rental does not bypass minimum level.

Cross-faction rental additionally requires the weapon license.

Conceptually:

```text
LEVEL GATE
    ↓
FACTION / LICENSE GATE
    ↓
OWNED?
    YES → permanent access
    NO  → valid rental required
```

Exact rental lifetime remains a later gameplay decision.

Examples include:

- life;
- round;
- session;
- fixed duration.

That decision belongs to progression/economy design, not the loadout validator.

---

## 15. Example Player States

### Dave

```text
Level: 12
L1A1 kills: 50/50
Money: $500,000
```

L1A1 requires Level 20.

Result:

```text
purchase: denied
rental: denied
arsenal selection: denied
license activation: denied
```

Kill progress remains saved.

---

### Bob

```text
Level: 20
L1A1 kills: 10/50
Ownership: yes
```

Result:

```text
native faction: permanent access
opposing faction: denied
license progress: 10/50
```

---

### Steve

```text
Level: 20
L1A1 kills: 50/50
Ownership: no
```

Result:

```text
license: complete
native faction: rental required
opposing faction: rental allowed
permanent ownership: no
```

---

### Mongo

```text
Level: 20
L1A1 kills: 50/50
Ownership: yes
```

Result:

```text
license: complete
ownership: complete
native faction: permanent access
opposing faction: permanent access
rental required: no
```

Weapon is fully completed.

---

## 16. Authoritative Entitlement Logic

The future server-side entitlement sequence should conceptually be:

```text
1. Does the item exist?
        ↓
2. Is the weapon/magazine/attachment combination factually valid?
        ↓
3. Has the player reached the minimum level?
        ↓
4. Is the current side the weapon's native faction?

   YES:
       owned or otherwise valid native access?

   NO:
       license complete?
           NO → reject
           YES → owned or valid rental?
        ↓
5. VALID
```

The exact API between `functions/loadouts/` and `functions/progression/` must be deliberately designed when progression is implemented.

Loadouts must ask progression for authoritative entitlement.

Loadouts must not duplicate progression calculations.

---

# PART C — CURRENT LOADOUT FOUNDATION

## 17. Starter Loadouts

Every playable side must have an explicitly configured starter/default loadout.

Current starter definitions include:

```text
starter_west
starter_east
```

Starter entitlement is explicit.

Do not infer starter equipment from:

- level zero;
- missing database state;
- empty ownership;
- failed progression load;
- missing rental state.

Starter equipment must remain usable even when progression/persistence systems are unavailable.

---

## 18. Server Loadout Initialization

`fn_initServer.sqf` owns server initialization of configured loadout definitions.

Configured template loadouts are resolved once at server initialization and stored in server-owned state.

Do not recreate template units or rediscover starter loadouts per request.

---

## 19. Validation Request Modes

`fn_validateLoadout.sqf` is server-only and supports three top-level request modes.

Exactly one top-level mode may be supplied.

### Configured loadout intent

```text
loadoutId
```

Used for known canonical configured loadouts such as starter/default loadouts.

Legacy array-form configured requests remain supported where existing code still requires them.

### Legacy primary composition intent

```text
primary
    weaponClass
    magazines[]
    attachments[]
```

This remains supported for backward compatibility with the earlier foundation work.

New multi-weapon requests should prefer the `weapons` mode.

### Multi-weapon composition intent

```text
weapons
    primary
        weaponClass
        magazines[]
        attachments[]

    handgun
        weaponClass
        magazines[]
        attachments[]

    launcher
        weaponClass
        magazines[]
        attachments[]
```

The `weapons` map must contain at least one supported slot.

Supported slots are currently:

- `primary`
- `handgun`
- `launcher`

Unknown slots are rejected as malformed.

Each populated slot is validated through the single internal:

```text
bn_koth_fnc_loadouts_validateWeaponComposition
```

No weapon slot maintains a separate compatibility implementation.

The canonical multi-slot result is returned through:

```text
validatedWeapons
```

For backward compatibility, when a primary weapon is present:

```text
validatedPrimary
```

continues to mirror the canonical primary result.

Providing more than one top-level intent such as:

```text
loadoutId + weapons
primary + weapons
loadoutId + primary
```

is malformed and rejected.

---

## 20. Weapon Composition Validation

`fn_validateWeaponComposition.sqf` is the single internal owner of factual weapon composition validation.

It is:

```text
Execution: Server
Public: No
```

It validates one weapon slot against the canonical generated S.O.G. Prairie Fire compatibility data.

It currently verifies:

- request structure;
- weapon classname existence;
- magazine classname existence;
- attachment classname existence;
- weapon/magazine compatibility;
- weapon/attachment compatibility;
- structural variant relationships;
- ambiguous/unresolved structural variant rejection;
- canonical derived weapon classname.

The helper is shared by:

```text
primary
handgun
launcher
```

`fn_validateLoadout.sqf` remains the higher-level orchestrator responsible for:

- player authority;
- authoritative side resolution;
- request mode selection;
- composition orchestration;
- future progression entitlement integration.

The client must never provide a trusted final derived classname.

The server constructs the canonical result.

---

## 21. Proven Weapon Composition Examples

Hosted Multiplayer testing has verified the following M16 structural variant cases:

```text
vn_m16
→ vn_m16
```

```text
vn_m16
+ vn_s_m16
→ vn_m16_sd
```

```text
vn_m16
+ vn_o_4x_m16
→ vn_m16_mrk
```

```text
vn_m16
+ vn_s_m16
+ vn_o_4x_m16
→ vn_m16_mrk_sd
```

The server resolves these through generated direct lookup data.

No runtime classname guessing is performed.

No runtime full-variant scan is required.

Hosted Multiplayer testing has also verified a single multi-slot request containing:

```text
primary
    vn_m16 + vn_s_m16
    → vn_m16_sd

handgun
    vn_hp
    → vn_hp

launcher
    vn_m72
    → vn_m72
```

All three were validated through the same internal composition validator and returned together in `validatedWeapons`.

Malformed multi-weapon requests have been verified to reject:

- empty `weapons` maps;
- non-map `weapons`;
- unsupported weapon slot names;
- non-map slot payloads;
- multiple simultaneous top-level request modes.

---

## 22. Validation Failure Behaviour

Validation returns explicit result codes.

Examples currently exercised include:

```text
ERR_MALFORMED_REQUEST
ERR_UNKNOWN_LOADOUT
ERR_UNKNOWN_PRIMARY_WEAPON
ERR_UNKNOWN_MAGAZINE
ERR_INCOMPATIBLE_MAGAZINE
ERR_UNKNOWN_ATTACHMENT
ERR_INCOMPATIBLE_ATTACHMENT
ERR_VARIANT_UNRESOLVED
ERR_VARIANT_AMBIGUOUS
```

Failures must explain the real rejection reason.

Do not silently replace invalid requests with unrelated equipment.

---

## 23. Authoritative Player Side

The server resolves the player's authoritative assigned side from server-owned player records.

Client-supplied side information is a cross-check only.

A client cannot change its entitlement by claiming a different side.

---

## 24. Loadout Application

`fn_applyLoadout.sqf` owns application of already accepted canonical loadouts.

It is an internal function.

It is not the client/server trust boundary.

Do not allow clients to remotely invoke arbitrary application.

All eventual application paths should converge on one authoritative application route.

This includes future:

- initial deployment;
- arsenal confirmation;
- respawn restoration;
- saved-loadout restoration;
- reconnect/JIP restoration where appropriate.

---

## 25. `fn_request.sqf` Boundary

`fn_request.sqf` is the sole public loadout request ingress. It accepts intent only, resolves the requesting player from `remoteExecutedOwner`, applies a narrow request-rate guard, invokes the server validator and returns only the canonical validated result to that player's owning client.

The implemented flow is:

```text
CLIENT
sends intent only
        ↓
SERVER fn_request
        ↓
resolve player from network owner
        ↓
validate request
        ↓
resolve current side and factual catalogue eligibility
        ↓
construct canonical accepted loadout
        ↓
apply through owned application path
```

The request implementation deliberately handles:

- `remoteExecutedOwner`;
- rate limiting;
- rapid duplicate request throttling;
- `CfgRemoteExec`;
- object locality;
- authoritative player identity.

Future progression entitlement must integrate inside the existing server validator through a progression-owned API. It must not create a second request, validation or application path.

### Arsenal V1 weapon composition drafts

The primary-weapon and sidearm browsers share one card, Configure, draft and
request architecture. Either browser may submit one complete client-selected
composition for its explicit weapon slot:

```text
canonical base weapon
+ one compatible magazine
+ zero or more compatible attachments
```

The client draft is presentation and intent only. The server independently:

- resolves structural variants from generated compatibility data;
- validates the magazine against the resolved weapon;
- validates every attachment against the resolved weapon;
- validates weapon entitlement;
- validates any human-authored attachment minimum level;
- builds the accepted composition into the authoritative intended loadout.

Only the server-returned validated loadout is applied through the existing
owned application path. Viable but incomplete structural attachment drafts are
not submittable.

The browser slot context is presentation only. The request contains either a
`weapons.primary` or `weapons.handgun` intent, and the server validates that
slot through the shared weapon-composition validator before building the
authoritative intended loadout.

Safe-zone anti-duplication boundaries are:

- never treat a client inventory snapshot or client-supplied `getUnitLoadout` result as entitlement or persistence authority;
- do not persist battlefield pickups or equipment the progression service has not authorized for restoration;
- future purchase and rental mutations must use server-owned transaction identifiers and idempotent grant/charge handling;
- do not expose unrestricted BIS Arsenal objects as an alternate application path;
- keep accepted, throttled and rejected loadout requests auditable in server logs without logging on a recurring inventory scan.

---

# PART D — PERFORMANCE AND MULTIPLAYER RULES

## 26. Performance

Do not:

- continuously scan player inventories;
- repeatedly walk the complete Arma config tree;
- regenerate catalogue relationships during gameplay;
- parse catalogue JSON at runtime;
- scrape external sources at runtime;
- scan all structural variants per validation request;
- create per-frame arsenal handlers;
- create short-interval arsenal polling loops;
- duplicate large catalogue state per player;
- broadcast the complete catalogue during ordinary gameplay state updates;
- rebuild static compatibility caches per Arsenal open.

Prefer:

- development-time generation;
- static mission config;
- direct classname lookups;
- validation only on explicit requests or owned lifecycle transitions.

---

## 27. Multiplayer / Remote Execution

The rules in:

```text
docs/architecture.md
docs/multiplayer-locality.md
```

remain authoritative.

Client requests contain intent, not trusted results.

Only explicitly required request/response functions should be exposed through `CfgRemoteExec`.

Never expose arbitrary equipment application for convenience.

---

## 28. `mission.sqm` Boundary

The arsenal/loadout foundation does not require editor objects simply to establish data, validation, progression, or application architecture.

Do not add:

- Eden modules;
- triggers;
- markers;
- NPCs;
- crates;
- laptops;
- scripted objects;

merely to make the backend work.

A later physical Arsenal interaction may deliberately use an existing base object or new editor object.

That decision belongs to the UI/interaction phase.

Behaviour belongs in mission functions rather than object init fields.

---

# PART E — MAINTAINER GUIDE

## 29. The Important Rule

Maintainers should not need to understand generated structural variant internals to balance the game.

Think of the system as:

```text
GAME FACTS
generated automatically
        +
KOTH RULES
edited by humans
        +
PLAYER PROGRESS
stored by progression
```

---

## 30. Files You Must Not Hand Edit

Generated factual files must not be manually balanced.

In particular:

```text
config/arsenal/generated/sog_catalogue.hpp
data/generated/sog_catalogue.json
```

and generated reports should be treated as generated output.

If generated factual data is wrong:

> fix the scraper/classifier/generator and regenerate.

Do not permanently patch generated output by hand.

---

## 31. Where Future Balance Changes Belong

Changing things such as:

```text
L1A1 native faction
L1A1 minimum level
L1A1 license kill requirement
L1A1 purchase price
L1A1 rental price
starter/free status
```

must happen in human-authored KOTH metadata.

A maintainer should never need to edit:

```text
WeaponVariantByBaseAndAttachments
```

to change gameplay progression.

---

## 32. Example Future Human Metadata

The exact final schema remains to be implemented, but maintenance should eventually be approximately as simple as:

```cpp
class vn_l1a1_01
{
    nativeSide = "WEST";
    minLevel = 20;
    licenseKills = 50;
    purchasePrice = 100000;
    rentalPrice = 2000;
};
```

This example documents design intent only.

Do not create this schema until the progression metadata slice is deliberately implemented.

---

## 33. Adding a New S.O.G. Prairie Fire Weapon

If the S.O.G. Prairie Fire equipment source changes or a previously unsupported weapon is added to the catalogue:

1. run the catalogue scraper;
2. review validation/report output;
3. regenerate runtime config;
4. inspect unexpected ambiguity;
5. test runtime config in Arma;
6. add deliberate KOTH metadata if the weapon should participate in progression;
7. commit generated and human-authored changes separately where practical.

The generator should discover factual relationships.

Maintainers decide balance.

---

## 34. Changing an Existing Weapon's Progression

Once human KOTH progression metadata exists, changing an unlock should require editing that metadata only.

Example:

```text
L1A1
Level 20 → Level 25
```

should not require:

- scraper changes;
- generator changes;
- SQF validator changes;
- generated HPP edits.

The same principle applies to:

- native faction;
- kill requirement;
- price;
- rental cost.

If a balance change requires modifying runtime validator code, the architecture should be questioned first.

---

## 35. Testing Requirements

### Generator changes

Run the S.O.G. catalogue unit tests and regenerate output.

Generated output must remain deterministic.

### Runtime loadout changes

At minimum test:

- valid request;
- malformed request;
- unknown item;
- incompatible equipment;
- side mismatch where applicable;
- structural variant resolution;
- configured starter validation.

### Hosted Multiplayer

Use Hosted MP for fast functional validation.

### Dedicated server

Any feature involving:

- server authority;
- locality;
- networking;
- RemoteExec;
- multiple clients;

is not feature-complete until dedicated-server testing passes.

Check client and server RPT.

No repeated errors are acceptable.

---

# PART F — CURRENT STATUS

## 36. Implemented

Current foundation includes:

- canonical arsenal config entry point;
- explicit WEST and EAST starter loadouts;
- server loadout initialization;
- server-authoritative configured-loadout validation;
- canonical loadout application foundation;
- S.O.G. Prairie Fire catalogue scraping;
- generated JSON catalogue;
- generated static runtime HPP;
- factual source affiliation retention;
- weapon → magazine relationships;
- weapon → attachment relationships;
- confirmed weapon structural variants;
- deterministic reverse structural variant index;
- chained structural variant flattening;
- server-authoritative weapon composition validation;
- shared internal weapon composition validator;
- multi-slot `weapons` request validation;
- primary weapon validation;
- handgun validation;
- launcher validation;
- canonical `validatedWeapons` results;
- backward-compatible `validatedPrimary` results;
- malformed request rejection;
- explicit validation failure codes;
- Hosted MP validation of configured starter loadouts;
- Hosted MP validation of structural M16 variants;
- Hosted MP validation of combined primary + handgun + launcher requests.

---

## 37. Deliberately Not Implemented Yet

The foundation currently does not implement:

- XP;
- player levels;
- ranks;
- weapon kill persistence;
- license activation;
- ownership;
- currency;
- purchasing;
- rental;
- persistence/database integration;
- saved player loadouts;
- final custom Arsenal UI;
- complete non-weapon equipment-slot validation;
- progression entitlement checks during loadout validation.

Do not pretend these systems exist by adding temporary shortcuts to loadout code.

---

## 38. Current Phase 4A Direction

The next foundation work should continue extending the same validator/application architecture rather than introducing progression prematurely.

Progression should integrate only after the factual loadout model is sufficiently stable.

The intended eventual dependency direction is:

```text
UI
 ↓
Loadout request boundary
 ↓
Loadout validation
 ├── factual catalogue
 ├── KOTH metadata
 └── progression entitlement API
 ↓
canonical accepted loadout
 ↓
single application path
```

---

## 39. Foundation Completion Criteria

Phase 4A foundation is complete when:

1. one documented arsenal/loadout ownership model exists;
2. one canonical factual equipment catalogue exists;
3. generated and human-authored data remain separate;
4. WEST and EAST have explicit starter/default loadouts;
5. one server-side validator returns deterministic results;
6. factual weapon/magazine/attachment compatibility is validated;
7. all deliberately supported equipment slots pass through that validator;
8. structural variants resolve to canonical real Arma classes;
9. one owned loadout application path exists;
10. no progression/economy/persistence authority is invented inside loadouts;
11. no duplicate validator/application system exists;
12. no recurring server loadout polling is introduced;
13. Hosted MP tests pass;
14. dedicated-server tests pass where required;
15. client and server RPT remain clean;
16. documentation matches the implemented architecture.

---

## 40. Design Rule Summary

When in doubt:

```text
Does it describe what exists in S.O.G. Prairie Fire?
→ generated factual catalogue

Does it describe how Bro-Nation wants the weapon balanced?
→ human KOTH metadata

Does it describe what a player has earned?
→ progression/persistence

Does it decide whether a requested loadout is legal?
→ server loadout validator

Does it physically equip an accepted loadout?
→ owned loadout application path

Does it display/select equipment?
→ client UI
```

Keep those ownership boundaries intact and the Arsenal can grow without being redesigned every time another feature is added.

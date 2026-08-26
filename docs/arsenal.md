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

Owner of:

- XP;
- player level;
- rank;
- currency;
- weapon kill/mastery progress;
- weapon mastery;
- permanent ownership;
- rental entitlement;
- progression statistics.

Loadouts may ask progression whether a player is entitled to equipment.

Loadouts must not calculate or independently store progression state.

Current canonical weapon acquisition state is stored per UID in the
server-owned progression record as `ownedWeapons[]` and `rentedWeapons[]`.
Both contain canonical logical classnames only. Purchase and rent validate the
existing side, level, and perk gates before applying an explicitly configured
price. The combined cash/entitlement transition is committed once and does not
equip the weapon. Ownership and rentals are session-scoped until persistence
exists; rentals currently last for that whole server session.

---

### `functions/persistence/`

Future sole owner of persistent/database state.

This includes:

- XP and level;
- currency;
- weapon kill progress;
- mastery;
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
- mastery progress;
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

Examples include:

- allowed KOTH sides;
- visual appearance side;
- minimum level;
- mastery kill requirement;
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
- mastery progress;
- mastery completion;
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

## 7. KOTH Side Policy

KOTH side policy is human-authored and deliberately independent from factual
S.O.G. provenance and progression balance:

```cpp
class vn_l1a1_01
{
    allowedSides[] = {"WEST"};
};
```

`allowedSides[]` answers:

> Which KOTH sides may use or acquire this logical item?

For canonical weapons only, `crossSideAllowed = 1` deliberately permits the
opposite side to pursue weapon-specific mastery. `allowedSides[]` continues
to mean native/default access. Cross-side access requires level first, then
canonical `weaponKills >= masteryKillsRequired`, then perks and any configured
acquisition. Ownership and rental do not bypass those gates. Structural
variants inherit the canonical rule.

An empty or absent `allowedSides[]` temporarily leaves combat equipment
uncontrolled while balance metadata is authored. It must never be populated
from `sourceAffiliations[]` automatically. Structural weapon variants inherit
the canonical root weapon metadata and never receive separate side policy.

Visual equipment additionally requires:

```cpp
appearanceSide = "WEST"; // or "EAST"
```

`appearanceSide` identifies which KOTH faction the item visually represents.
Uniforms, vests, backpacks, headgear, and facewear fail closed when this field
is absent or invalid; opposing appearance equipment is rejected even if its
`allowedSides[]` value is broader. No battlefield-loot exception currently
exists.

These fields remain separate concepts:

- `sourceAffiliations[]`: generated factual S.O.G. provenance;
- `allowedSides[]`: human-authored KOTH gameplay availability;
- `appearanceSide`: human-authored KOTH visual identity;
- `minLevel`, mastery, ownership, and prices: progression/economy policy.

---

# PART B — PROGRESSION MODEL

## 8. Core Progression Rule: Level Is King

Every progression-controlled weapon has a minimum required level.

Nothing bypasses this requirement.

Not:

- money;
- ownership;
- mastery progress;
- completed mastery;
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

A player may physically pick up and use equipment found during normal gameplay
even when below its progression level, unowned, or not yet mastered. This is
temporary physical possession only.

That does not unlock the weapon.

That does not grant ownership.

That does not grant arsenal access.

That does not grant Store access, rental entitlement, or saved-kit/loadout
restoration. Pickup history is never proof of entitlement, and progression
policy does not plan to confiscate battlefield weapons solely because their
level, mastery, or ownership requirements are incomplete.

Properly attributed kills may, however, contribute to canonical weapon mastery.

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
mastery permission: locked
```

At Level 20:

```text
weapon becomes eligible
```

The system then evaluates:

- mastery;
- ownership;
- rental;
- faction.

Therefore:

> Levels unlock the opportunity to acquire/use the next progression tier.

They do not automatically award equipment.

---

## 10. Weapon Kills and Mastery Progress

Each progression-controlled weapon may have a weapon-specific kill requirement.

Example:

```text
L1A1
Minimum Level: 20
Mastery Requirement: 50 L1A1 kills
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

Mastery progress is complete, but level eligibility has not been reached.

At Level 20:

```text
level requirement complete
kill requirement complete
→ cross-side mastery permission becomes usable
```

This allows battlefield scavenging and weapon familiarity to matter without bypassing level progression.

---

## 11. Mastery Progress Is Independent From Native Side Policy

Weapon mastery represents cross-side permission.

Conceptually:

> The player has demonstrated the configured mastery requirement for this weapon.

Mastery does **not** mean the player owns the weapon, and it does not mutate
`allowedSides[]`. Cross-side eligibility is a separate weapon-only route that
exists only when the canonical weapon explicitly declares
`crossSideAllowed = 1`.

Example:

```text
L1A1
Allowed sides: WEST
Minimum level: 20
Mastery kills required: 50
```

Player:

```text
Level: 20
L1A1 kills: 50
Ownership: no
```

Native-side result:

```text
Mastery: complete
Native/default side: WEST
Permanent ownership: no
```

On EAST, this focused seed may proceed only after Level 20 and 50 canonical
L1A1 mastery kills, then remains subject to acquisition/economy rules.

---

## 12. Purchase = Permanent Ownership

Purchasing answers:

> Does this player permanently own this weapon?

It does not answer:

> Has this player mastered the weapon?

Purchasing therefore does not alter `allowedSides[]`.

Example:

```text
Level: 20
L1A1 kills: 10/50
L1A1 ownership: yes
```

On an allowed side:

```text
Level requirement: complete
Ownership: complete
→ permanent access
```

On a side absent from `allowedSides[]` with no explicit cross-side path:

```text
Level requirement: complete
Ownership: complete
→ CROSS_SIDE_NOT_ALLOWED regardless of ownership
```

When `crossSideAllowed = 1`, ownership still cannot bypass level, perks, or an
incomplete cross-side mastery requirement.

Money must not bypass the mastery requirement.

---

## 13. Owned + Mastered = Progression Completion

When a player has both permanent ownership and complete weapon mastery:

```text
Level requirement: complete
Ownership: yes
Mastery: complete
```

the weapon has completed those progression requirements on every side listed in
its `allowedSides[]` metadata.

No rental is required.

This is the final completion state for a normal progression weapon.

---

## 14. Rental

Rental represents temporary economic access.

A rental does not become ownership.

A rental does not bypass minimum level.

Rental never mutates `allowedSides[]` and never creates a cross-side path.

Conceptually:

```text
LEVEL GATE
    ↓
ALLOWED-SIDE GATE
    ↓
OWNED?
    YES → permanent access
    NO  → valid rental required
```

The current rental lifetime is the server session. Rental state survives
respawn, side changes and round transitions, and is not reset by the round
lifecycle. A future persistence/economy design may deliberately replace that
policy, but expiry must continue to have one authoritative owner.

Provisional weapon pricing is authored on canonical logical roots only. It uses
readable purchase bands based on progression tier and broad combat role, with
specialist, support, precision, and strategic weapons priced above ordinary
weapons at comparable levels. Rental is currently exactly 20% of purchase
price. These are playtest values for the current provisional cash cadence, not
final economy balance.

The configured Level 1 starter roots (`vn_m1903`, `vn_m1911`, `vn_k98k`, and
`vn_pm`) remain acquisition-uncontrolled. Deployment applies their configured
starter loadouts directly and the current acquisition initializer does not seed
starter ownership, so pricing them would make those guaranteed baseline kits
fail later entitlement checks. `vn_fkb1_pm` also remains unpriced with its wider
metadata pending manual review.

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
mastery permission: denied
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
native side: permanent access
cross side: LOCKED_MASTERY (10/50), even though owned
mastery progress: 10/50
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
mastery: complete
native side: rental or purchase required
cross side: mastery complete, then rental or purchase required
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
mastery: complete
ownership: complete
native side: permanent access
cross side: permanent access only because crossSideAllowed is explicit and mastery is complete
rental required: no
```

Weapon is fully completed.

---

## 16. Authoritative Entitlement Logic

The server-side weapon entitlement sequence is:

```text
1. Does the item exist?
        ↓
2. Is the weapon/magazine/attachment combination factually valid?
        ↓
3. Is the current side native/default through allowedSides, or is an explicit
   crossSideAllowed path configured?
        ↓
4. Has the player reached minLevel?
        ↓
5. For cross-side access, has canonical weapon mastery reached masteryKillsRequired?
        ↓
6. Have required perks passed?
        ↓
7. Where acquisition is configured, is ownership/rental valid?
        ↓
8. VALID
```

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

Each starter class owns the human-authored equipment choice: primary, launcher
and handgun weapons and attachments; uniform, vest, backpack, headgear, facewear
and binocular classes; spare-magazine counts and target containers; generic starter
cargo; and the six assigned-item slots in Arma order (map, GPS/terminal, radio,
compass, watch, NVG). Empty optional classnames explicitly clear that slot.

Runtime derives each configured weapon's loaded and spare magazine classname
from the generated canonical S.O.G. `baseMagazine` fact; starter config does not
duplicate that factual choice. Magazines and attachments are then validated
against generated compatibility. Runtime initialization resolves structural variants,
derives loaded and spare magazine capacity from `CfgMagazines`, constructs the
physical Unit Loadout Array shapes, and rejects an invalid definition with a
specific server log. Changing a starter equipment choice must therefore be a
config edit; weapon facts and loadout mechanics remain outside the balance
definition.

---

## 18. Server Loadout Initialization

`fn_initServer.sqf` owns server initialization of configured loadout definitions.

Configured template loadouts are resolved once at server initialization, then
their explicitly configured starter choices are validated and mechanically
built into complete loadouts stored in server-owned state. The template supplies
an engine-valid baseline shape; it is not the balance owner for configured
starter equipment.

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

The primary-weapon, sidearm and launcher browsers share one card, Configure,
draft and request architecture. Each browser may submit one complete
client-selected composition for its explicit weapon slot:

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

The browser slot context is presentation only. The request contains a
`weapons.primary`, `weapons.handgun`, or `weapons.launcher` intent, and the
server validates that slot through the shared weapon-composition validator
before building the authoritative intended loadout. Launcher presentation also
provides an explicit `NONE` choice. That choice submits an empty launcher-slot
intent; only the server validates and applies the resulting removal.

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
L1A1 allowed sides
L1A1 minimum level
L1A1 mastery kill requirement
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
    allowedSides[] = {"WEST"};
    minLevel = 20;
    masteryKillsRequired = 50;
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

- allowed sides;
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

- ranks;
- weapon kill persistence;
- mastery completion;
- persistence/database integration;
- non-weapon Store categories;
- final weapon prices;
- stock behavior.

Session XP, derived levels, cash, canonical weapon ownership, and
server-session weapon rentals are implemented. Acquisition is active only when
human-authored `purchasePrice` or `rentalPrice` metadata exists. Purchase/rent
do not equip equipment and do not bypass side, level, or perk requirements.

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

---

## 41. Wearable And Cargo Entitlement

Wearable container selection and container contents are separate concerns.

- `Metadata >> Wearables` owns human-authored level and perk requirements for
  uniform and later wearable selection.
- `Metadata >> Consumables` owns human-authored level and perk requirements for
  cargo items.
- Generated S.O.G. facts remain the source of class identity, pictures, item
  type, weapon-magazine relationships, and cargo validity.
- Presentation categories may organize cargo for browsing, but a category never
  grants entitlement.
- Client UI evaluates the shared pure rule interpreter only for presentation.
- The server re-evaluates entitlement before accepting a wearable selection or
  positive cargo adjustment.
- Cargo removal remains permitted when an item is no longer entitled, so a
  player can always clean up an existing kit.

Unconfigured wearable and consumable metadata is deliberately uncontrolled. No
level, perk, price, ownership, stock, or economy rule may be inferred from the
factual catalogue or from a presentation category.

Cargo presentation uses the shared two-column card workspace. Factual candidates
are grouped for navigation as ammunition, grenades, smoke/flares, medical,
navigation/comms, or equipment. Cards display the authoritative intended-kit
quantity and submit one-unit add/remove intents. Empty categories are disabled.
These categories organize presentation only; the server continues to own class
validity, entitlement, quantity limits, container capacity, and application.

Uniforms, vests, backpacks, headgear, facewear, and binoculars share the
large-card item browser. Each slot keeps
its own factual catalogue and applied-state lookup. Backpack `NONE` is an
explicit clear intent, and only an applied non-empty container may open its
cargo configuration view. Human-authored `Metadata >> Wearables` requirements
are evaluated for presentation and repeated by the server before a selection
is accepted. Assigned equipment remains slot-first because map, navigation,
radio, compass, watch, and NVG positions are independent loadout fields; both
its slot and candidate stages use the card workspace, and candidates use the
same entitlement rules.

Weapon art may use the overview row's wide framing, while uniform, vest,
headgear, and backpack art preserves its source aspect ratio in both overview
and browser presentation. Wearable pictures must not be stretched to fill the
weapon-shaped frame.

Opening any card browser sets a one-shot snap request. The renderer locates the
currently applied logical item and opens its page. Pagination after entry is
fully user-controlled and does not repeatedly jump back to the applied item.

Opening the Arsenal requests a server-owned reconciliation snapshot. The server
reads the current physical player unit, replaces the stored intended-loadout
baseline with that observation, and returns it without applying equipment.
Clients do not submit inventory contents. This prevents later partial mutations
from restoring equipment that the player physically dropped between Arsenal
sessions while preserving the server as the state owner.

Saved kits are stored only in the local client's `profileNamespace`. Saving and
deleting do not mutate server gameplay state. A locally stored kit is never an
authority source: LOAD submits the complete stored array as untrusted intent,
and the server repeats structural weapon/attachment validation, factual slot
validation, progression entitlement checks, assigned-slot rules, cargo class
and quantity checks, and container capacity checks before the single owned
application path may equip it. Editing local profile data therefore cannot
grant equipment or bypass progression.

The Loadout overview exposes `MANAGE LOADOUTS` and `SAVE CURRENT KIT` in its
centre footer. The manager supports up to twelve locally named kits, including
load, explicit edit, rename, and delete. LOAD gives feedback only after the
server-validated loadout has been applied. EDIT submits the same untrusted
loadout through that validation path and establishes a local edit target only
after success. The normal Arsenal flow then edits the authoritative intended
loadout; `SAVE CHANGES` explicitly overwrites that same local record without a
new name or duplicate. `CANCEL EDIT`, successful ordinary LOAD, successful save,
and menu close clear the edit target. Navigation, including Store entry, never
autosaves it. The former fixed `slot1` profile record is migrated once as
`MIGRATED KIT`; the old profile key is then removed. Kit names and ids are
presentation metadata only. The server never resolves equipment from a client
kit id and validates the complete submitted loadout independently.

State-changing Arsenal requests also include the network id of the actual
mapboard whose local action opened the menu. The server treats that id only as
a target hint: it resolves the object itself and verifies it against the
configured side mapboard or marker and player distance before accepting the
mutation. This avoids selecting a different nearby board while preserving the
server-owned access decision.

The operator-panel render-to-texture control and client-local camera lifecycle
helpers are retained as disabled preview framework. The menu does not currently
start that camera. The attempted live-player view was rejected because its
world-relative framing could not provide the deliberately staged presentation
required by the design reference. A future implementation may use a locally
owned, presentation-only mannequin in a fixed decorated scene. It must never
equip or mutate the gameplay player, and simultaneous clients must not share or
compete over preview state.

The Store uses the existing deployed-menu shell and owns only the wide centre
workspace. The operator column is hidden only while Store is active so the
catalogue can use the full main width; normal Loadout and Arsenal views restore
that column through the shared menu lifecycle owner. Its root exposes Infantry,
Ground Vehicles, Rotary Wing,
and Fixed Wing; Infantry then separates Primary, Sidearms, and Launchers. SEA
is hidden while the curated progression surface has no SEA products. Weapon
lists contain global canonical S.O.G. roots deterministically; structural
variants are never separate products. Human-authored `allowedSides[]`,
`crossSideAllowed`, level, passive canonical mastery, perks and prices
drive presentation. Missing prices show acquisition not configured and never
produce invented values.

Product categories use the shared four-card, two-column visual language with
bounded pagination rather than a long scrolling list. Store keeps its own
discovery/acquisition projection while sharing controls with Arsenal. Its
expanded geometry is applied only while Store is active; the shared menu mode
owner restores canonical title, subtitle, BACK, selector action, pagination,
workspace, card and operator geometry before every non-Store renderer. Locked,
wrong-side, unaffordable, owned and rented products remain discoverable.
Cross-side products that permit mastery show current/required progress even
while level-locked; truly prohibited products say `FACTION RESTRICTED`.
Selecting a card explains combined level, mastery, perk and acquisition state
with real line-separated text in the right detail panel. Category data is
cached on entry and invalidated by authoritative progression/acquisition
updates, with no polling or per-frame config scan.

`BUY` and `RENT` submit intent only. The server derives the caller, repeats
entitlement and cash checks, commits through
`functions/progression/acquisition/`, and returns only to the requester. The
existing targeted progression update refreshes Store cash and ownership/rental
state. Acquisition does not auto-equip. Persistence, stock, and final price
balance remain outside this presentation slice.

An owned or rented weapon exposes `EQUIP IN ARSENAL`. This is navigation only:
it opens the existing Primary, Handgun or Launcher Arsenal browser, snaps to and
highlights the acquired canonical weapon, and leaves configuration/application
to the existing validated loadout path. Store never mutates a loadout. Arsenal
remains the currently usable surface: cross-side discovery products stay absent
until the shared authoritative entitlement result says they are entitled.

Native-side weapons may also be bought or rented directly from their existing
Arsenal browser card once level/side/mastery/perk entitlement is otherwise
satisfied (`REQUIRES_ACQUISITION`); the card shows `AVAILABLE TO ACQUIRE` with
`BUY $X`/`RENT $Y` actions that submit through the exact same
`bn_koth_fnc_progression_requestWeaponAcquisition` endpoint Store uses. Store
remains the only discovery surface for cross-faction weapons and vehicles, and
the only route for a cross-faction weapon until it is fully entitled there.
Once a cross-faction weapon becomes entitled (side, level, mastery, perks all
satisfied and owned/rented), it appears in Arsenal like any native weapon under
the existing filtering; Arsenal never lists a locked cross-faction weapon.

Vehicle progression preparation is owned separately by
`CfgBnKothVehicles >> Metadata >> Vehicles`. Canonical vehicle roots explicitly
declare `allowedSides[]`, `minLevel`, provisional purchase/rental prices,
`storeCategory`, and `vehicleRole`; structural relationships may be declared
only with `variantOf` and inherit root policy. The current taxonomy is
`GROUND`, `SEA`, `ROTARY`, and `FIXED_WING`, with a separate role such as
`TRANSPORT`, `LOGISTICS`, `COMMAND`, or `COMBAT`.

The factual audit of public physical classes from the official S.O.G.
EAST/WEST CfgVehicles tables lives in `data/vehicle_inventory.csv`. The Store
product surface is intentionally smaller: `config/vehicles.hpp` authors a
curated set of combat-relevant ground, rotary-wing and fixed-wing loadouts.
Materially different factual loadout labels may be separate products, while
paint/faction duplicates and support-only classes are omitted. The source
exposes no dependable inheritance graph, so no vehicle `variantOf` links are
authored. Factual table side and faction remain evidence only, while config
owns deliberate KOTH availability and balance.

Only those curated metadata entries are discoverable in the vehicle Store
categories. Vehicles are RENT-only and the displayed price buys one vehicle
life. RENT is one immediate authoritative transaction: successful server-side
spawn and cash deduction happen together, so a single RENT press either ends
with a live active vehicle or with nothing charged. An active life ends on
destruction or authoritative cleanup, with no refund or entitlement
restoration. There is no BUY action, permanent vehicle ownership, persisted
rental, or session-wide unlimited unlock. M577 rental grants only the normal
vehicle object and never
managed command/teleport capability. Vehicles do not use weapon mastery.

# Bro-Nation KOTH Vietnam — Arsenal & Loadout Architecture

## 1. Purpose

This document defines the ownership, configuration, validation, and integration boundaries for the KOTH loadout and arsenal system.

The foundation does not implement progression, purchases, rentals, currency, persistence, or the final UI. It establishes one predictable equipment model those systems can later consume without redesigning the arsenal.

Repository rules remain authoritative:

- the server owns authoritative gameplay decisions;
- clients display state and submit requests;
- configuration is separate from runtime logic;
- each behaviour has one clear owner;
- shared validation is implemented once;
- balancing values are configurable;
- no system may invent a parallel source of truth.

## 2. Foundation Scope

Establish:

- one canonical KOTH equipment catalogue;
- faction/side and category metadata;
- explicit starter/default loadouts;
- weapon, magazine, attachment, and weapon-variant relationships;
- one server-authoritative loadout validation path;
- one server-authoritative accepted-loadout application path;
- stable integration boundaries for later UI, progression, economy, and persistence;
- a boundary for generated S.O.G. Prairie Fire / Nickel Steel equipment data.

Do not implement yet:

- XP, levels, or ranks;
- currency;
- purchases or rentals;
- persistent ownership;
- database access;
- persistent saved loadouts;
- the final custom arsenal UI.

## 3. Ownership

### `config/arsenal/`

Owns KOTH equipment definitions and balance metadata. Configuration describes data; it does not perform gameplay actions.

### `functions/loadouts/`

Owns catalogue access, loadout normalisation, validation, faction restrictions, compatibility validation, starter/default loadouts, and applying accepted loadouts through one controlled path.

No other gameplay system may create a second implementation of loadout validation.

### `functions/progression/`

Future owner of XP, levels/ranks, currency, equipment unlock entitlement, permanent ownership, rental entitlement, and player statistics.

Loadouts may later ask progression for entitlement. Loadouts must not calculate progression.

### `functions/persistence/`

Future sole owner of database loading/saving, including progression, ownership and saved loadouts. Loadouts must not communicate directly with the database.

### `functions/ui/`

Future owner of arsenal/loadout presentation and client selection state. UI may display authoritative information but must not decide entitlement.

## 4. Canonical Equipment Catalogue

All equipment available through KOTH must come from one canonical catalogue using actual Arma classnames as identity.

Support as required:

- primary weapons;
- secondary weapons;
- launchers;
- handguns;
- magazines;
- optics;
- muzzle devices;
- rail/weapon accessories;
- bipods;
- grenades/throwables;
- explosives;
- uniforms;
- vests;
- headgear;
- backpacks;
- binoculars/NVGs/assigned items;
- other deliberately supported equipment.

An item does not become KOTH-valid merely because it exists in Arma config.

## 5. Generated Data vs Hand-Authored Balance Data

Generated factual game data and human-authored KOTH balance data must remain separate.

Generated data may include classname, display name, config/item type, compatible magazines, compatible attachments, weapon variants, and useful parent/base relationships.

Generated output must be deterministic and reviewable. Runtime gameplay must not scrape external websites or repeatedly walk the complete Arma config tree.

Maintainers own gameplay metadata such as permitted side, KOTH category, starter/free status, future minimum level, future purchase/rental settings, restrictions, and exclusions.

Regeneration must not silently overwrite hand-authored balance decisions.

## 6. Weapon Compatibility and Variants

The catalogue must account for how S.O.G. Prairie Fire / Nickel Steel represents usable weapon combinations.

Do not assume every attachment can simply be attached to one base weapon classname. If a combination is represented by another weapon classname, that variant must be known to the catalogue.

Conceptual example:

```text
M16 base weapon
+ suppressor
-> suppressed M16 weapon variant classname
```

Choose the exact representation only after inspecting the real config relationships. The validator must consume canonical compatibility data rather than maintaining another table.

## 7. Starter Equipment

Every playable side must have at least one explicitly configured valid starter/default loadout sufficient to participate.

Do not infer starter entitlement from missing persistence, level zero, an empty ownership list, or failed progression loading.

## 8. Authoritative Validation

The client may request a loadout. The server decides whether it is valid.

One reusable validator must serve all eventual application paths: first deployment, arsenal confirmation, respawn restoration, saved-loadout restoration, and reconnect/JIP restoration where appropriate.

Validation must be capable of checking:

- request/loadout structure;
- catalogue membership;
- authoritative player side;
- side/faction restrictions;
- weapon/magazine/attachment compatibility;
- equipment restrictions;
- starter/default validity;
- future progression entitlement;
- future ownership/rental entitlement.

Never trust client-supplied level, rank, XP, currency, unlock state, ownership, rental state, affordability, or validation result.

Failures should return a useful reason/code rather than silently turning the request into an unrelated loadout.

## 9. Loadout Application

There must be one owned path for applying an accepted KOTH loadout.

Callers must not independently duplicate equipment removal, item/weapon/magazine addition, attachment application, assigned-item application, or starter fallback behaviour.

Do not allow clients to remotely invoke arbitrary equipment application.

## 10. Progression and Economy Hooks

Progression is not implemented by this foundation.

Current design intent:

- equipment may have configurable minimum levels;
- level remains a hard access gate unless game design explicitly changes;
- reaching a level does not automatically imply permanent ownership unless configured that way;
- permanent ownership and rental entitlement are separate;
- rental must not silently bypass minimum level;
- exact prices, rental rules, kill requirements, currency, and persistence belong to later design.

Do not hard-code temporary progression assumptions into loadout functions.

## 11. Saved Loadouts

Persistent saved loadouts are later work. A saved loadout is player intent, not authority.

Every restored loadout must be revalidated against current rules before application. Never restore persisted equipment directly onto a player without current validation.

## 12. Multiplayer / Remote Execution

The rules in `docs/architecture.md` and `docs/multiplayer-locality.md` apply.

Client requests contain intent, not trusted results.

Only specifically required request/response functions should be added to `CfgRemoteExec`. Do not open broad remote-execution access for convenience.

## 13. Performance

Do not:

- continuously scan every player's inventory;
- repeatedly walk the complete Arma config tree;
- regenerate compatibility data at runtime;
- add a per-frame or short-interval server arsenal loop;
- broadcast the complete catalogue with ordinary state updates;
- duplicate large catalogue data separately per player;
- perform expensive compatibility discovery every time the UI opens.

Prefer static/config-backed catalogue data, generated development-time data, and validation on explicit requests or owned lifecycle transitions.

## 14. Expected Repository Structure

```text
config/
└── arsenal/
    ├── settings.hpp
    ├── equipment.hpp
    └── generated/
        ├── weapons.hpp
        ├── magazines.hpp
        └── compatibility.hpp

functions/
└── loadouts/
    ├── fn_initServer.sqf
    ├── fn_validateLoadout.sqf
    ├── fn_applyLoadout.sqf
    └── fn_getStarterLoadout.sqf

tools/
└── arsenal/
    └── [catalogue-generation tooling when implemented]
```

This is a target, not permission to create empty placeholders. Inspect the current tree and established include/function-registration patterns first. Extend an existing equivalent owner instead of creating a parallel system.

## 15. `mission.sqm` Boundary

The arsenal foundation should not require `mission.sqm` changes merely to establish catalogue, validation, or application architecture.

Do not add Eden objects, modules, playable units, triggers, markers, or scripted objects just to make the foundation work.

A later physical arsenal interaction may use an existing base object/UI entry point or deliberately add an editor object. Decide that only after inspecting the current deployment/base interaction design.

If an Eden object is eventually required, give it a stable purpose/name and keep behaviour in mission functions rather than object init fields.

## 16. Foundation Completion Criteria

The foundation is complete when:

1. One documented arsenal/loadout ownership model exists.
2. The catalogue has one canonical configuration entry point.
3. WEST and EAST have explicit starter/default loadouts.
4. A server-side validator returns deterministic valid/invalid results with reasons.
5. Validation consumes catalogue/config data rather than duplicated item lists.
6. Accepted loadouts use one owned application function.
7. No progression, currency, purchase, rental, or persistence authority is invented early.
8. No duplicate validator/application path exists.
9. No recurring server loop is introduced.
10. No unrelated gameplay system is changed.
11. Dedicated-server testing produces no repeated RPT errors.
12. Documentation matches the implemented boundary.

## 17. Later Work

Later phases may add catalogue generation, custom arsenal UI, filtering/categories, progression requirements, purchases, rentals, saved loadouts, persistence, respawn restoration, and richer rejection/lock messaging.

Each must integrate with this foundation rather than replacing its authority model.

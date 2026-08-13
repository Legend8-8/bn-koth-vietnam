from __future__ import annotations

from collections import Counter, defaultdict
import re
from typing import Any

from .catalogue import increment_reason, sort_unique


NON_SOG_REASON = "non_sog_class"
VNX_REASON = "vnx_excluded"

MAGAZINE_EXCLUSION_PREFIXES = (
    "vn_vmagazine",
    "vn_magazine",
    "vn_lmagazine",
    "vn_pistolmag_base",
    "vn_riflemag_base",
    "vn_shotgunmag_base",
    "vn_smgmag_base",
    "vn_lmgmag_base",
    "vn_handgrenade_base",
    "vn_40mm_mag_base",
    "vn_22mm_mag_base",
    "vn_cannon_",
    "vn_mortar_",
    "vn_bomb_",
    "vn_fuel_",
    "vn_missile_",
    "vn_ship_horn",
    "vn_rocket_ffar_",
    "vn_rocket_s5_",
    "vn_rocket_h12_",
    "vn_gunpod_",
    "vn_smokegen_",
)

WEAPON_EXCLUSION_CLASSES = {
    "vn_fakeweapon",
    "vn_revive_weapon",
}

REVERSE_EXCLUDED_WEAPON_PREFIXES = (
    "vn_wheeled_",
    "vn_truck_",
    "vn_boat_",
    "vn_air_",
    "vn_armor_",
    "vn_ship_",
)

REVERSE_EXCLUDED_WEAPON_TOKENS = (
    "_veh",
    "_vehicle",
    "_turret",
    "_tripod",
    "_static",
    "_pod",
    "_pylon",
    "_horn",
    "_fake",
    "_helper",
)

ITEM_EXCLUSION_PATTERNS = (
    re.compile(r"_1\s+-\s+1000$"),
    re.compile(r"_horn$"),
)

WEAPON_VARIANT_SUFFIX_TRAITS = {
    "sd": "suppressed",
    "bayo": "bayonet",
    "mrk": "optic",
    "sniper": "optic",
    "nvg": "night_optic",
    "xm148": "grenade_launcher",
    "m203": "grenade_launcher",
    "gl": "grenade_launcher",
    "bipod": "bipod",
    "camo": "camo",
    "stock": "stock",
    "short": "short",
    "shorty": "short",
    "fold": "folded",
    "f": "folded",
    "fs": "front_sight",
}

PRIMARY_SMALLARM_CATEGORIES = {
    "pistol_mag",
    "smg_mag",
    "rifle_mag",
    "lmg_mag",
    "shotgun_mag",
}

SECONDARY_LAUNCHER_CATEGORIES = {
    "grenade_20mm",
    "grenade_22mm",
    "grenade_40mm",
    "launcher_round",
}


def build_catalogue(parsed_pages: dict[str, list[dict[str, Any]]], overrides: dict[str, Any]) -> tuple[dict[str, Any], dict[str, Any]]:
    summary = {
        "sourceCoverage": {
            "weaponRows": len(parsed_pages["weapons"]),
            "itemRows": len(parsed_pages["items"]),
            "magazineRows": len(parsed_pages["magazines"]),
        },
        "filtering": {
            "accepted": {"weapons": 0, "items": 0, "magazines": 0},
            "rejectedReasons": {"weapons": Counter(), "items": Counter(), "magazines": Counter()},
        },
        "exclusions": {"vnx": []},
        "warnings": [],
        "overridesApplied": [],
        "weaponExclusionReasons": {},
    }

    accepted_weapons = filter_weapon_rows(parsed_pages["weapons"], overrides, summary)
    accepted_items = filter_item_rows(parsed_pages["items"], overrides, summary)
    accepted_magazines = filter_magazine_rows(parsed_pages["magazines"], overrides, summary)

    item_map = {item["class"]: item for item in accepted_items}
    magazine_map = {magazine["class"]: magazine for magazine in accepted_magazines}

    relationship_state = enrich_relationships(accepted_weapons, item_map, magazine_map, summary)
    derive_item_reverse_relationships(item_map, accepted_weapons)
    derive_magazine_reverse_relationships(magazine_map, accepted_weapons)
    derive_weapon_families_and_variants(accepted_weapons, item_map)
    propagate_family_base_magazines(accepted_weapons)
    apply_overrides(accepted_weapons, accepted_items, accepted_magazines, overrides, summary, item_map, magazine_map)

    catalogue = {
        "metadata": {
            "source": "sog_pf",
            "schemaVersion": 1,
            "deliberateDeviations": [
                "Source wiki does not expose explicit muzzle names; the extractor derives primary and secondary groups from factual magazine categories and records grouping confidence.",
                "Source wiki does not expose explicit magazine-default flags; the extractor collapses ordinary/tracer equivalents and keeps remaining capacity/type ambiguity null unless a conservative decision is justified.",
                "Family grouping may use shared primary-magazine evidence and attachment hints, but structural derived classification requires an explicit base-plus-accessory relationship and a matching structural classname pattern.",
            ],
        },
        "sources": [],
        "weapons": sorted(accepted_weapons, key=lambda record: record["class"]),
        "magazines": sorted(accepted_magazines, key=lambda record: record["class"]),
        "items": sorted(accepted_items, key=lambda record: record["class"]),
        "relationships": relationship_state,
        "summary": finalize_summary(summary, accepted_weapons, accepted_items, accepted_magazines, relationship_state),
    }

    return catalogue, catalogue["summary"]


def filter_weapon_rows(rows: list[dict[str, Any]], overrides: dict[str, Any], summary: dict[str, Any]) -> list[dict[str, Any]]:
    excluded = set(overrides.get("exclude", {}).get("weapons", []))
    accepted = []

    for row in rows:
        class_name = row["class"]
        reason = weapon_rejection_reason(row, excluded)
        if reason is not None:
            if reason == VNX_REASON:
                summary["exclusions"]["vnx"].append(class_name)
            if class_name.startswith("vn_"):
                summary["weaponExclusionReasons"][class_name] = reason
            increment_reason(summary["filtering"]["rejectedReasons"]["weapons"], reason)
            continue

        accepted.append(
            {
                "class": class_name,
                "displayName": row["displayName"],
                "description": row["description"],
                "source": "sog_pf",
                "sourcePage": row["sourcePage"],
                "version": row["version"],
                "weaponType": classify_weapon_type(row),
                "rawCompatibleMagazines": sort_unique(row["magazines"]),
                "rawCompatibleAttachments": sort_unique([value for value in row["accessories"] if value.startswith("vn_")]),
                "muzzles": {},
                "compatibleMagazines": [],
                "compatibleAttachments": [],
                "baseMagazine": None,
                "baseMagazineConfidence": "unknown",
                "baseMagazineCandidates": [],
                "baseMagazineDecisionSignature": "",
                "unlockableMagazines": [],
                "unlockableAttachments": [],
                "family": None,
                "variantOf": None,
                "variantTraits": [],
                "derivedRequirements": [],
                "variantEvidence": [],
                "variantCandidateOf": None,
                "variantCandidateEvidence": [],
            }
        )

    summary["filtering"]["accepted"]["weapons"] = len(accepted)
    return accepted


def filter_item_rows(rows: list[dict[str, Any]], overrides: dict[str, Any], summary: dict[str, Any]) -> list[dict[str, Any]]:
    excluded = set(overrides.get("exclude", {}).get("items", []))
    accepted = []

    for row in rows:
        class_name = row["class"]
        reason = item_rejection_reason(row, excluded)
        if reason is not None:
            if reason == VNX_REASON:
                summary["exclusions"]["vnx"].append(class_name)
            increment_reason(summary["filtering"]["rejectedReasons"]["items"], reason)
            continue

        item_type = classify_item_type(row)
        accepted.append(
            {
                "class": class_name,
                "displayName": row["displayName"],
                "description": row["description"],
                "source": "sog_pf",
                "sourcePage": row["sourcePage"],
                "version": row["version"],
                "itemType": item_type,
                "magazines": sort_unique([value for value in row["magazines"] if value.startswith("vn_")]),
                "compatibleWeapons": [],
                "traits": derive_item_traits(class_name, item_type, row),
            }
        )

    summary["filtering"]["accepted"]["items"] = len(accepted)
    return accepted


def filter_magazine_rows(rows: list[dict[str, Any]], overrides: dict[str, Any], summary: dict[str, Any]) -> list[dict[str, Any]]:
    excluded = set(overrides.get("exclude", {}).get("magazines", []))
    accepted = []

    for row in rows:
        class_name = row["class"]
        reason = magazine_rejection_reason(row, excluded)
        if reason is not None:
            if reason == VNX_REASON:
                summary["exclusions"]["vnx"].append(class_name)
            increment_reason(summary["filtering"]["rejectedReasons"]["magazines"], reason)
            continue

        category = classify_magazine_category(row)
        traits = derive_magazine_traits(row, category)
        accepted.append(
            {
                "class": class_name,
                "displayName": row["displayName"],
                "description": row["description"],
                "source": "sog_pf",
                "sourcePage": row["sourcePage"],
                "version": row["version"],
                "ammoClass": row["ammoClass"],
                "category": category,
                "traits": traits,
                "compatibleWeapons": sort_unique([value for value in row["usedBy"] if value.startswith("vn_")]),
            }
        )

    summary["filtering"]["accepted"]["magazines"] = len(accepted)
    return accepted


def weapon_rejection_reason(row: dict[str, Any], excluded: set[str]) -> str | None:
    class_name = row["class"]
    if not class_name:
        return "missing_class"
    if class_name in excluded:
        return "manual_exclusion"
    if class_name.startswith("vnx_"):
        return VNX_REASON
    if not class_name.startswith("vn_"):
        return NON_SOG_REASON
    if class_name in WEAPON_EXCLUSION_CLASSES:
        return "helper_or_fake_weapon"
    if not row["displayName"]:
        return "helper_or_base_weapon"
    if not row["magazines"]:
        return "non_magazine_weapon_record"
    return None


def item_rejection_reason(row: dict[str, Any], excluded: set[str]) -> str | None:
    class_name = row["class"]
    if not class_name:
        return "missing_class"
    if class_name in excluded:
        return "manual_exclusion"
    if class_name.startswith("vnx_"):
        return VNX_REASON
    if not class_name.startswith("vn_"):
        return NON_SOG_REASON
    if " " in class_name:
        return "range_placeholder"
    if not row["displayName"]:
        return "helper_or_base_item"
    for pattern in ITEM_EXCLUSION_PATTERNS:
        if pattern.search(class_name):
            return "non_player_item"
    if row["displayName"].lower() == "horn":
        return "vehicle_item"
    return None


def magazine_rejection_reason(row: dict[str, Any], excluded: set[str]) -> str | None:
    class_name = row["class"]
    if not class_name:
        return "missing_class"
    if class_name in excluded:
        return "manual_exclusion"
    if class_name.startswith("vnx_"):
        return VNX_REASON
    if not class_name.startswith("vn_"):
        return NON_SOG_REASON
    if any(class_name.startswith(prefix) for prefix in MAGAZINE_EXCLUSION_PREFIXES):
        return "helper_or_vehicle_magazine"
    if "_v_" in class_name or class_name.endswith("_empty"):
        return "vehicle_magazine"
    if class_name in {"vn_fakemagazine"}:
        return "helper_or_fake_magazine"
    if not row["displayName"]:
        return "helper_or_base_magazine"
    return None


def classify_weapon_type(row: dict[str, Any]) -> str:
    haystack = f"{row['displayName']} {row['description']} {row['class']}".lower()
    if "pistol" in haystack or "revolver" in haystack or "sidearm" in haystack:
        return "handgun"
    if "shotgun" in haystack:
        return "shotgun"
    if "submachinegun" in haystack or "smg" in haystack or "machine pistol" in haystack:
        return "smg"
    if "light machine gun" in haystack or "lmg" in haystack:
        return "lmg"
    if "sniper" in haystack or "marksman" in haystack:
        return "marksman"
    if "grenade launcher" in haystack or " rocket" in haystack or "missile" in haystack or "law" in haystack:
        return "launcher"
    return "rifle"


def classify_item_type(row: dict[str, Any]) -> str:
    class_name = row["class"].lower()
    display_name = row["displayName"].lower()
    if class_name.startswith("vn_s_") or "suppressor" in display_name:
        return "suppressor"
    if class_name.startswith("vn_o_") or "optic" in display_name or "scope" in display_name:
        return "optic"
    if class_name.startswith("vn_bipod_") or "bipod" in display_name:
        return "bipod"
    if "bayonet" in display_name or class_name.startswith("vn_b_"):
        return "bayonet"
    if "camo wrap" in display_name:
        return "camo"
    if "binoc" in class_name or "binocular" in display_name:
        return "binocular"
    if "map" in display_name:
        return "map"
    if "compass" in display_name:
        return "compass"
    if "watch" in display_name:
        return "watch"
    if "radio" in display_name or "telephone" in display_name:
        return "radio"
    if "medikit" in display_name or "first aid" in display_name:
        return "medical"
    if "toolkit" in display_name or "trap" in display_name:
        return "tool"
    return "item"


def classify_magazine_category(row: dict[str, Any]) -> str:
    class_name = row["class"].lower()
    display_name = row["displayName"].lower()
    description = row["description"].lower()

    if class_name.startswith("vn_40mm_"):
        return "grenade_40mm"
    if class_name.startswith("vn_22mm_"):
        return "grenade_22mm"
    if class_name.startswith("vn_20mm_"):
        return "grenade_20mm"
    if "rocket" in display_name or "missile" in display_name:
        return "launcher_round"
    if "smoke" in display_name and "40mm" not in display_name and "22mm" not in display_name:
        return "throwable_smoke"
    if "flare" in display_name and "40mm" not in display_name and "22mm" not in display_name:
        return "throwable_flare"
    if "grenade" in display_name:
        return "throwable_grenade"
    if "mine" in display_name or "satchel" in display_name or "trap" in display_name:
        return "explosive"
    if "shotgun" in description or "buckshot" in description or "buck" in class_name:
        return "shotgun_mag"
    if any(token in description for token in ["pistol", "revolver"]):
        return "pistol_mag"
    if "submachinegun" in description or "smg" in description:
        return "smg_mag"
    if "light machine gun" in description or "belt" in display_name or "drum" in display_name or "box" in display_name:
        return "lmg_mag"
    return "rifle_mag"


def derive_item_traits(class_name: str, item_type: str, row: dict[str, Any]) -> list[str]:
    traits = [item_type]
    if "red" in class_name or "red" in row["displayName"].lower():
        traits.append("red")
    if "camo" in class_name:
        traits.append("camo")
    return sort_unique(traits)


def derive_magazine_traits(row: dict[str, Any], category: str) -> list[str]:
    display_name = row["displayName"].lower()
    class_name = row["class"].lower()
    description = row["description"].lower()
    traits = [category]
    if "tracer" in display_name or "_t_mag" in class_name:
        traits.append("tracer")
    if "smoke" in display_name or "smoke" in description:
        traits.append("smoke")
    if "flare" in display_name or "lume" in display_name:
        traits.append("flare")
    if "wp" in display_name or "white phosphorus" in description:
        traits.append("wp")
    if "cs" in display_name or "cs gas" in description:
        traits.append("cs")
    if "hedp" in display_name:
        traits.append("hedp")
    if "heat" in display_name:
        traits.append("heat")
    if "airburst" in display_name:
        traits.append("airburst")
    if "buck" in display_name or "buckshot" in description:
        traits.append("buckshot")
    if "flechette" in display_name or "flechette" in description:
        traits.append("flechette")
    if "dual" in display_name:
        traits.append("dual")
    if "drum" in display_name:
        traits.append("drum")
    if "box" in display_name:
        traits.append("box")
    if "belt" in display_name:
        traits.append("belt")
    return sort_unique(traits)


def enrich_relationships(
    weapons: list[dict[str, Any]],
    item_map: dict[str, dict[str, Any]],
    magazine_map: dict[str, dict[str, Any]],
    summary: dict[str, Any],
) -> dict[str, Any]:
    weapon_mag_links = 0
    weapon_attachment_links = 0
    missing_magazines: list[tuple[str, str]] = []
    missing_attachments: list[tuple[str, str]] = []
    multi_muzzle_weapons = 0
    ambiguous_grouping = 0

    for weapon in weapons:
        compatible_magazines = []
        for magazine_class in weapon["rawCompatibleMagazines"]:
            if magazine_class in magazine_map:
                compatible_magazines.append(magazine_class)
            else:
                missing_magazines.append((weapon["class"], magazine_class))

        compatible_attachments = []
        for item_class in weapon["rawCompatibleAttachments"]:
            if item_class in item_map:
                compatible_attachments.append(item_class)
            else:
                missing_attachments.append((weapon["class"], item_class))

        weapon["compatibleMagazines"] = sort_unique(compatible_magazines)
        weapon["compatibleAttachments"] = sort_unique(compatible_attachments)
        weapon["unlockableAttachments"] = list(weapon["compatibleAttachments"])
        weapon_mag_links += len(weapon["compatibleMagazines"])
        weapon_attachment_links += len(weapon["compatibleAttachments"])

        muzzles, grouping_confidence = group_weapon_muzzles(weapon, magazine_map)
        weapon["muzzles"] = muzzles
        if len(muzzles) > 1:
            multi_muzzle_weapons += 1
        if grouping_confidence == "ambiguous":
            ambiguous_grouping += 1

        base_magazine, confidence, candidates, signature = choose_base_magazine(weapon, magazine_map)
        weapon["baseMagazine"] = base_magazine
        weapon["baseMagazineConfidence"] = confidence
        weapon["baseMagazineCandidates"] = candidates
        weapon["baseMagazineDecisionSignature"] = signature
        weapon["unlockableMagazines"] = [
            magazine_class for magazine_class in weapon["compatibleMagazines"] if magazine_class != base_magazine
        ]

    forward_links = {(weapon["class"], magazine_class) for weapon in weapons for magazine_class in weapon["compatibleMagazines"]}
    reverse_links = {
        (magazine["class"], weapon_class)
        for magazine in magazine_map.values()
        for weapon_class in magazine["compatibleWeapons"]
        if weapon_class.startswith("vn_")
    }

    confirmed = 0
    one_sided_forward = []
    unexplained_reverse = []
    excluded_target_reverse = []

    for weapon_class, magazine_class in sorted(forward_links):
        if (magazine_class, weapon_class) in reverse_links:
            confirmed += 1
        else:
            one_sided_forward.append((weapon_class, magazine_class))

    for magazine_class, weapon_class in sorted(reverse_links):
        if (weapon_class, magazine_class) in forward_links:
            continue
        exclusion_reason = classify_reverse_only_target(weapon_class, summary["weaponExclusionReasons"])
        if exclusion_reason is not None:
            excluded_target_reverse.append((magazine_class, weapon_class, exclusion_reason))
        else:
            unexplained_reverse.append((magazine_class, weapon_class))

    return {
        "weaponMagazineLinks": weapon_mag_links,
        "weaponAttachmentLinks": weapon_attachment_links,
        "confirmedReverseRelationships": confirmed,
        "oneSidedWeaponToMagazine": one_sided_forward,
        "oneSidedMagazineToWeapon": unexplained_reverse,
        "excludedTargetReverseRelationships": excluded_target_reverse,
        "missingMagazines": missing_magazines,
        "missingAttachments": missing_attachments,
        "multiMuzzleWeapons": multi_muzzle_weapons,
        "ambiguousMuzzleGrouping": ambiguous_grouping,
    }


def classify_reverse_only_target(weapon_class: str, known_reasons: dict[str, str]) -> str | None:
    known_reason = known_reasons.get(weapon_class)
    if known_reason in {
        "helper_or_fake_weapon",
        "non_magazine_weapon_record",
        "helper_or_base_weapon",
        "manual_exclusion",
        "vehicle_weapon",
        "system_weapon",
    }:
        return known_reason

    lowered = weapon_class.lower()
    if lowered.startswith(REVERSE_EXCLUDED_WEAPON_PREFIXES):
        return "vehicle_weapon"
    if any(token in lowered for token in REVERSE_EXCLUDED_WEAPON_TOKENS):
        return "helper_or_system_weapon"
    return None


def derive_item_reverse_relationships(item_map: dict[str, dict[str, Any]], weapons: list[dict[str, Any]]) -> None:
    reverse_map: dict[str, set[str]] = defaultdict(set)
    for weapon in weapons:
        for item_class in weapon["compatibleAttachments"]:
            reverse_map[item_class].add(weapon["class"])
    for item_class, item in item_map.items():
        item["compatibleWeapons"] = sorted(reverse_map[item_class])


def derive_magazine_reverse_relationships(magazine_map: dict[str, dict[str, Any]], weapons: list[dict[str, Any]]) -> None:
    forward_map: dict[str, set[str]] = defaultdict(set)
    for weapon in weapons:
        for magazine_class in weapon["compatibleMagazines"]:
            forward_map[magazine_class].add(weapon["class"])
    for magazine_class, magazine in magazine_map.items():
        combined = set(magazine["compatibleWeapons"]) | forward_map[magazine_class]
        magazine["compatibleWeapons"] = sorted(combined)


def group_weapon_muzzles(weapon: dict[str, Any], magazine_map: dict[str, dict[str, Any]]) -> tuple[dict[str, dict[str, Any]], str]:
    magazines = [magazine_map[magazine_class] for magazine_class in weapon["compatibleMagazines"] if magazine_class in magazine_map]
    if not magazines:
        return {}, "ambiguous"

    categories = {magazine["category"] for magazine in magazines}
    smallarm = [magazine for magazine in magazines if magazine["category"] in PRIMARY_SMALLARM_CATEGORIES]
    launcher = [magazine for magazine in magazines if magazine["category"] in SECONDARY_LAUNCHER_CATEGORIES]

    if smallarm and launcher:
        return {
            "primary": {
                "kind": "primary_firearm",
                "confidence": "high",
                "magazines": sorted(magazine["class"] for magazine in smallarm),
            },
            "secondary_1": {
                "kind": "launcher",
                "confidence": "high",
                "magazines": sorted(magazine["class"] for magazine in launcher),
            },
        }, "high"

    if len(categories) == 1 or weapon["weaponType"] == "launcher":
        return {
            "primary": {
                "kind": next(iter(categories)),
                "confidence": "high",
                "magazines": sorted(magazine["class"] for magazine in magazines),
            }
        }, "high"

    primary_candidates = sorted(
        magazine["class"]
        for magazine in magazines
        if magazine["category"] not in {"throwable_grenade", "throwable_smoke", "throwable_flare", "explosive"}
    )
    if primary_candidates:
        return {
            "primary": {
                "kind": "derived_primary",
                "confidence": "ambiguous",
                "magazines": primary_candidates,
            },
            "secondary_1": {
                "kind": "derived_secondary",
                "confidence": "ambiguous",
                "magazines": sorted(
                    magazine["class"] for magazine in magazines if magazine["class"] not in primary_candidates
                ),
            },
        }, "ambiguous"

    return {
        "primary": {
            "kind": "unknown",
            "confidence": "ambiguous",
            "magazines": sorted(magazine["class"] for magazine in magazines),
        }
    }, "ambiguous"


def choose_base_magazine(weapon: dict[str, Any], magazine_map: dict[str, dict[str, Any]]) -> tuple[str | None, str, list[dict[str, Any]], str]:
    primary_classes = weapon.get("muzzles", {}).get("primary", {}).get("magazines", [])
    if not primary_classes:
        return None, "missing", [], ""

    candidates = build_base_candidate_groups(primary_classes, weapon, magazine_map)
    candidates.sort(key=lambda entry: (-entry["score"], entry["class"]))
    signature = "|".join(candidate["class"] for candidate in candidates)

    if not candidates:
        return None, "missing", [], signature

    if len(candidates) == 1:
        confidence = "high" if candidates[0]["score"] >= 0 else "ambiguous"
        return (candidates[0]["class"] if confidence == "high" else None), confidence, candidates, signature

    if candidates[0]["score"] < 0:
        return None, "ambiguous", candidates, signature

    if weapon["weaponType"] in {"launcher", "shotgun"} and candidates[0]["score"] > candidates[1]["score"]:
        confidence = "high" if candidates[0]["score"] >= 3 else "ambiguous"
        return (candidates[0]["class"] if confidence == "high" else None), confidence, candidates, signature

    return None, "ambiguous", candidates, signature


def build_base_candidate_groups(
    primary_classes: list[str],
    weapon: dict[str, Any],
    magazine_map: dict[str, dict[str, Any]],
) -> list[dict[str, Any]]:
    grouped_candidates: dict[str, list[dict[str, Any]]] = defaultdict(list)

    for magazine_class in primary_classes:
        magazine = magazine_map[magazine_class]
        grouped_candidates[canonical_magazine_key(magazine)].append(
            {
                "class": magazine_class,
                "score": score_base_magazine(weapon, magazine),
                "traits": list(magazine["traits"]),
                "category": magazine["category"],
                "ammoClass": magazine["ammoClass"],
                "roundCount": extract_round_count(magazine["displayName"]),
            }
        )

    groups = []
    for entries in grouped_candidates.values():
        entries.sort(key=lambda entry: ("tracer" in entry["traits"], entry["class"]))
        preferred = entries[0]
        groups.append(
            {
                "class": preferred["class"],
                "score": preferred["score"],
                "traits": preferred["traits"],
                "category": preferred["category"],
                "ammoClass": preferred["ammoClass"],
                "roundCount": preferred["roundCount"],
                "alternatives": [entry["class"] for entry in entries],
                "hasTracerAlternative": any("tracer" in entry["traits"] for entry in entries[1:]),
            }
        )
    return groups


def canonical_magazine_key(magazine: dict[str, Any]) -> str:
    class_name = magazine["class"].replace("_t_mag", "_mag")
    display_name = re.sub(r"\s*\(tracer[^)]*\)", "", magazine["displayName"], flags=re.IGNORECASE)
    display_name = re.sub(r"\btracer\b", "", display_name, flags=re.IGNORECASE)
    display_name = re.sub(r"\s+", " ", display_name).strip().lower()
    return "|".join(
        [
            class_name,
            display_name,
            magazine["ammoClass"],
            magazine["category"],
            str(extract_round_count(magazine["displayName"])),
        ]
    )


def extract_round_count(display_name: str) -> int | None:
    match = re.search(r"(\d+)\s*rnd", display_name, flags=re.IGNORECASE)
    if match:
        return int(match.group(1))
    return None


def score_base_magazine(weapon: dict[str, Any], magazine: dict[str, Any]) -> int:
    display_name = magazine["displayName"].lower()
    description = magazine["description"].lower()
    traits = set(magazine["traits"])
    score = 0

    if "tracer" in traits:
        score -= 4
    if any(token in traits for token in ["smoke", "flare", "wp", "cs", "hedp", "heat", "airburst"]):
        score -= 6

    if weapon["weaponType"] == "shotgun":
        if "buckshot" in traits:
            score += 4
        if "flechette" in traits:
            score -= 2
    elif weapon["weaponType"] == "launcher":
        if "he" in display_name and "hedp" not in display_name and "heat" not in display_name:
            score += 4
        if "frag" in display_name:
            score += 3
        if "smoke" in display_name or "flare" in display_name:
            score -= 5
    else:
        round_count = extract_round_count(magazine["displayName"])
        if round_count in {5, 6, 7, 8, 10, 13, 15, 20, 30}:
            score += 2
        if round_count in {40, 47, 50, 71, 100, 125, 150}:
            score -= 2
        if any(token in display_name for token in ["dual", "drum", "box", "belt"]):
            score -= 2
        if "ball" in description or "used in" in description:
            score += 1

    if "reload" in display_name and weapon["weaponType"] in {"shotgun", "handgun"}:
        score += 1
    if any(token in display_name for token in ["mag", "belt", "clip"]):
        score += 1
    return score


def derive_weapon_families_and_variants(weapons: list[dict[str, Any]], item_map: dict[str, dict[str, Any]]) -> None:
    for weapon in weapons:
        weapon["family"] = derive_family_key(weapon["class"])

    refine_weapon_families(weapons)

    family_groups: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for weapon in weapons:
        family_groups[weapon["family"]].append(weapon)

    for group in family_groups.values():
        group.sort(key=lambda entry: (len(entry["compatibleAttachments"]), len(entry["class"]), entry["class"]))
        for weapon in group:
            candidate = find_variant_base_candidate(weapon, group, item_map)
            if candidate is None:
                continue
            if candidate["confirmed"]:
                weapon["variantOf"] = candidate["base"]
                weapon["variantTraits"] = candidate["traits"]
                weapon["derivedRequirements"] = candidate["requirements"]
                weapon["variantEvidence"] = candidate["evidence"]
            else:
                weapon["variantCandidateOf"] = candidate["base"]
                weapon["variantCandidateEvidence"] = candidate["evidence"]


def derive_family_key(class_name: str) -> str:
    base = class_name.removeprefix("vn_")
    tokens = base.split("_")
    if len(tokens) == 1:
        return base
    removable = {"sd", "bayo", "mrk", "sniper", "nvg", "xm148", "m203", "gl", "bipod", "camo", "fold", "f", "stock", "short", "shorty", "p", "fs"}
    while tokens and tokens[-1] in removable:
        tokens.pop()
    if len(tokens) >= 2 and tokens[-1].isdigit():
        tokens.pop()
    return "_".join(tokens)


def refine_weapon_families(weapons: list[dict[str, Any]]) -> None:
    family_sizes = Counter(weapon["family"] for weapon in weapons)
    signature_families: dict[tuple[str, ...], set[str]] = defaultdict(set)
    for weapon in weapons:
        signature_families[tuple(weapon.get("muzzles", {}).get("primary", {}).get("magazines", []))].add(weapon["family"])

    for weapon in weapons:
        primary_signature = tuple(weapon.get("muzzles", {}).get("primary", {}).get("magazines", []))
        candidate_families = signature_families.get(primary_signature, set())
        hinted_families = attachment_family_hints(weapon, candidate_families)
        if len(hinted_families) == 1 and family_sizes[weapon["family"]] == 1:
            weapon["family"] = next(iter(hinted_families))


def attachment_family_hints(weapon: dict[str, Any], candidate_families: set[str]) -> set[str]:
    hints = set()
    for attachment_class in weapon.get("compatibleAttachments", []):
        normalized_attachment = attachment_class.removeprefix("vn_")
        for family in candidate_families:
            if family != weapon["family"] and family and family in normalized_attachment:
                hints.add(family)
    return hints


def find_variant_base_candidate(
    weapon: dict[str, Any],
    family_group: list[dict[str, Any]],
    item_map: dict[str, dict[str, Any]],
) -> dict[str, Any] | None:
    best_candidate: dict[str, Any] | None = None
    for candidate in family_group:
        if candidate["class"] == weapon["class"]:
            continue
        if candidate["compatibleMagazines"] != weapon["compatibleMagazines"] and candidate.get("muzzles", {}).get("primary", {}).get("magazines") != weapon.get("muzzles", {}).get("primary", {}).get("magazines"):
            continue

        candidate_attachments = set(candidate["compatibleAttachments"])
        weapon_attachments = set(weapon["compatibleAttachments"])
        if not candidate_attachments.issubset(weapon_attachments):
            continue

        extra_attachments = sorted(weapon_attachments - candidate_attachments)
        if not extra_attachments:
            continue

        requirements = [candidate["class"], *extra_attachments]
        if not all(requirement == candidate["class"] or requirement in item_map for requirement in requirements):
            continue

        structural_match = has_structural_class_relation(weapon["class"], candidate["class"])
        confirmed, explicit_evidence = find_explicit_variant_evidence(weapon, candidate, extra_attachments, item_map)
        evidence = [
            f"shared primary magazines with {candidate['class']}",
            f"additional accessories: {', '.join(extra_attachments)}",
        ]
        evidence.extend(explicit_evidence)
        if structural_match:
            evidence.append("class stem matches structural variant pattern")
        if confirmed:
            evidence.append("explicit source evidence supports base-plus-accessory relationship")
        else:
            evidence.append("explicit source evidence is insufficient for confirmed derived relationship")

        variant_traits = []
        for attachment in extra_attachments:
            item_type = item_map[attachment]["itemType"]
            if item_type == "suppressor":
                variant_traits.append("suppressed")
            elif item_type == "optic":
                variant_traits.append("optic")
            elif item_type == "bipod":
                variant_traits.append("bipod")
            elif item_type == "bayonet":
                variant_traits.append("bayonet")
            elif item_type == "camo":
                variant_traits.append("camo")
            else:
                variant_traits.append(item_type)

        rank = (0 if confirmed else 1, len(extra_attachments), len(candidate["class"]), candidate["class"])
        candidate_record = {
            "base": candidate["class"],
            "requirements": requirements,
            "traits": sort_unique(variant_traits + derive_suffix_traits(weapon["class"], candidate["class"])),
            "evidence": evidence,
            "confirmed": confirmed,
            "rank": rank,
        }
        if best_candidate is None or candidate_record["rank"] < best_candidate["rank"]:
            best_candidate = candidate_record

    if best_candidate is not None:
        best_candidate.pop("rank", None)
    return best_candidate


def derive_suffix_traits(class_name: str, base_class: str) -> list[str]:
    suffix_tokens = class_name.removeprefix("vn_").removeprefix(base_class.removeprefix("vn_")).split("_")
    traits = []
    for token in suffix_tokens:
        if token in WEAPON_VARIANT_SUFFIX_TRAITS:
            traits.append(WEAPON_VARIANT_SUFFIX_TRAITS[token])
    return sort_unique(traits)


def find_explicit_variant_evidence(
    weapon: dict[str, Any],
    candidate: dict[str, Any],
    extra_attachments: list[str],
    item_map: dict[str, dict[str, Any]],
) -> tuple[bool, list[str]]:
    evidence_lines: list[str] = []

    # Links in the source row accessories column are direct factual evidence.
    if extra_attachments:
        evidence_lines.append("source row links explicit accessory classnames")

    description = (weapon.get("description") or "").lower()
    display_name = (weapon.get("displayName") or "").lower()
    base_name = (candidate.get("displayName") or "").lower()

    attachment_terms = {
        "suppressor": ["suppressor", "suppressed", "silenced"],
        "optic": ["optic", "scope", "4x", "3x", "9x"],
        "bayonet": ["bayonet"],
        "bipod": ["bipod"],
        "camo": ["camo", "wrap"],
    }

    matched_traits: list[str] = []
    for attachment_class in extra_attachments:
        item_type = item_map[attachment_class]["itemType"]
        terms = attachment_terms.get(item_type, [item_type])
        if any(term in description or term in display_name for term in terms):
            matched_traits.append(item_type)

    if matched_traits:
        evidence_lines.append(f"description/name mentions accessory traits: {', '.join(sort_unique(matched_traits))}")

    base_hint_tokens = [token for token in base_name.replace("-", " ").split() if len(token) >= 4]
    if base_hint_tokens and any(token in description for token in base_hint_tokens):
        evidence_lines.append("description references base weapon naming")

    has_accessory_link = bool(extra_attachments)
    has_trait_text = bool(matched_traits)
    has_base_hint = "description references base weapon naming" in evidence_lines
    explicit_confirmed = has_accessory_link and (has_trait_text or has_base_hint)
    return explicit_confirmed, evidence_lines


def has_structural_class_relation(variant_class: str, base_class: str) -> bool:
    variant_tokens = variant_class.removeprefix("vn_").split("_")
    base_tokens = base_class.removeprefix("vn_").split("_")
    return len(variant_tokens) > len(base_tokens) and variant_tokens[: len(base_tokens)] == base_tokens


def propagate_family_base_magazines(weapons: list[dict[str, Any]]) -> None:
    grouped_weapons: dict[str, list[dict[str, Any]]] = defaultdict(list)
    for weapon in weapons:
        grouped_weapons[weapon["family"]].append(weapon)

    for family_group in grouped_weapons.values():
        established = {
            weapon["baseMagazine"]
            for weapon in family_group
            if weapon["baseMagazine"] and weapon["baseMagazineConfidence"] in {"high", "family", "override"}
        }
        if len(established) != 1:
            continue
        base_magazine = next(iter(established))
        for weapon in family_group:
            primary_magazines = weapon.get("muzzles", {}).get("primary", {}).get("magazines", [])
            if weapon["baseMagazine"] is None and base_magazine in primary_magazines:
                weapon["baseMagazine"] = base_magazine
                weapon["baseMagazineConfidence"] = "family"
                weapon["unlockableMagazines"] = [
                    magazine_class for magazine_class in weapon["compatibleMagazines"] if magazine_class != base_magazine
                ]


def apply_overrides(
    weapons: list[dict[str, Any]],
    items: list[dict[str, Any]],
    magazines: list[dict[str, Any]],
    overrides: dict[str, Any],
    summary: dict[str, Any],
    item_map: dict[str, dict[str, Any]],
    magazine_map: dict[str, dict[str, Any]],
) -> None:
    weapon_map = {weapon["class"]: weapon for weapon in weapons}

    for class_name, weapon_type in overrides.get("weaponType", {}).items():
        if class_name in weapon_map:
            weapon_map[class_name]["weaponType"] = weapon_type
            summary["overridesApplied"].append(f"weaponType:{class_name}->{weapon_type}")

    item_map_local = {item["class"]: item for item in items}
    for class_name, item_type in overrides.get("itemType", {}).items():
        if class_name in item_map_local:
            item_map_local[class_name]["itemType"] = item_type
            summary["overridesApplied"].append(f"itemType:{class_name}->{item_type}")

    for class_name, magazine_class in overrides.get("baseMagazine", {}).items():
        weapon = weapon_map.get(class_name)
        if weapon is None:
            continue
        primary_mags = weapon.get("muzzles", {}).get("primary", {}).get("magazines", [])
        if magazine_class in primary_mags:
            weapon["baseMagazine"] = magazine_class
            weapon["baseMagazineConfidence"] = "override"
            weapon["unlockableMagazines"] = [value for value in weapon["compatibleMagazines"] if value != magazine_class]
            summary["overridesApplied"].append(f"baseMagazine:{class_name}->{magazine_class}")

    for class_name, family in overrides.get("family", {}).items():
        weapon = weapon_map.get(class_name)
        if weapon is None:
            continue
        weapon["family"] = family
        summary["overridesApplied"].append(f"family:{class_name}->{family}")

    for class_name, variant_of in overrides.get("variantOf", {}).items():
        weapon = weapon_map.get(class_name)
        if weapon is None or variant_of not in weapon_map:
            continue
        weapon["variantOf"] = variant_of
        weapon["variantEvidence"] = sort_unique(weapon.get("variantEvidence", []) + ["manual override"])
        summary["overridesApplied"].append(f"variantOf:{class_name}->{variant_of}")

    for class_name, requirements in overrides.get("derivedRequirements", {}).items():
        weapon = weapon_map.get(class_name)
        if weapon is None:
            continue
        valid_requirements = [
            requirement
            for requirement in requirements
            if requirement == weapon.get("variantOf") or requirement in weapon_map or requirement in item_map or requirement in magazine_map
        ]
        weapon["derivedRequirements"] = valid_requirements
        summary["overridesApplied"].append(f"derivedRequirements:{class_name}->{','.join(valid_requirements)}")


def finalize_summary(
    summary: dict[str, Any],
    weapons: list[dict[str, Any]],
    items: list[dict[str, Any]],
    magazines: list[dict[str, Any]],
    relationships: dict[str, Any],
) -> dict[str, Any]:
    base_high = 0
    base_ambiguous = 0
    base_missing = 0
    base_override = 0
    ambiguous_signatures = set()
    ambiguous_families = set()
    family_count = len({weapon["family"] for weapon in weapons if weapon["family"]})
    variant_candidates = 0
    derived = 0
    ambiguous_variants = 0
    multi_muzzle_confidence = relationships["multiMuzzleWeapons"] - relationships["ambiguousMuzzleGrouping"]

    for weapon in weapons:
        confidence = weapon["baseMagazineConfidence"]
        if confidence in {"high", "family"}:
            base_high += 1
        elif confidence == "override":
            base_override += 1
        elif confidence == "ambiguous":
            base_ambiguous += 1
            if weapon["baseMagazineDecisionSignature"]:
                ambiguous_signatures.add(weapon["baseMagazineDecisionSignature"])
            if weapon["family"]:
                ambiguous_families.add(weapon["family"])
        else:
            base_missing += 1

        if weapon["variantOf"] or weapon["variantCandidateOf"]:
            variant_candidates += 1
        if weapon["variantOf"] and weapon["derivedRequirements"]:
            derived += 1
        elif weapon["variantCandidateOf"]:
            ambiguous_variants += 1

    progression = build_progression_counts(weapons, items)

    return {
        **summary,
        "filtering": {
            "accepted": summary["filtering"]["accepted"],
            "rejectedReasons": {group: dict(counter) for group, counter in summary["filtering"]["rejectedReasons"].items()},
        },
        "relationships": {
            "weaponMagazineLinks": relationships["weaponMagazineLinks"],
            "weaponAttachmentLinks": relationships["weaponAttachmentLinks"],
            "confirmedReverseRelationships": relationships["confirmedReverseRelationships"],
            "oneSidedWeaponToMagazine": len(relationships["oneSidedWeaponToMagazine"]),
            "oneSidedMagazineToWeapon": len(relationships["oneSidedMagazineToWeapon"]),
            "excludedTargetReverseRelationships": len(relationships["excludedTargetReverseRelationships"]),
            "unexplainedMismatches": len(relationships["oneSidedWeaponToMagazine"]) + len(relationships["oneSidedMagazineToWeapon"]),
        },
        "muzzles": {
            "multiMuzzleWeapons": relationships["multiMuzzleWeapons"],
            "primarySecondaryGroupingConfidence": multi_muzzle_confidence,
            "ambiguousGrouping": relationships["ambiguousMuzzleGrouping"],
        },
        "baseMagazines": {
            "highConfidence": base_high,
            "ambiguous": base_ambiguous,
            "uniqueAmbiguousCandidateSets": len(ambiguous_signatures),
            "uniqueAmbiguousFamilies": len(ambiguous_families),
            "missing": base_missing,
            "overrides": base_override,
        },
        "variants": {
            "families": family_count,
            "candidates": variant_candidates,
            "derived": derived,
            "ambiguous": ambiguous_variants,
            "overrides": len([entry for entry in summary["overridesApplied"] if entry.startswith("variantOf:") or entry.startswith("family:")]),
        },
        "orphans": {
            "missingMagazines": len(relationships["missingMagazines"]),
            "missingAttachments": len(relationships["missingAttachments"]),
        },
        "progression": progression,
    }


def build_progression_counts(weapons: list[dict[str, Any]], items: list[dict[str, Any]]) -> dict[str, int]:
    progression_item_types = {"optic", "suppressor", "bipod", "bayonet", "camo"}
    progression_item_classes = {item["class"] for item in items if item["itemType"] in progression_item_types}

    progression_weapons = {weapon["class"] for weapon in weapons if not weapon.get("variantOf")}
    included_base_magazines = {weapon["baseMagazine"] for weapon in weapons if weapon.get("baseMagazine")}
    extra_magazines = {magazine for weapon in weapons for magazine in weapon.get("unlockableMagazines", [])}
    progression_attachments = {
        attachment
        for weapon in weapons
        for attachment in weapon.get("unlockableAttachments", [])
        if attachment in progression_item_classes
    }
    confirmed_derived_classes = {weapon["class"] for weapon in weapons if weapon.get("variantOf") and weapon.get("derivedRequirements")}

    total_unique_future_assets = len(progression_weapons | extra_magazines | progression_attachments)
    return {
        "weapons": len(weapons),
        "progressionWeapons": len(progression_weapons),
        "includedBaseMagazines": len(included_base_magazines),
        "extraMagazines": len(extra_magazines),
        "attachments": len(progression_attachments),
        "derivedClasses": len(confirmed_derived_classes),
        "totalFutureProgressionAssets": total_unique_future_assets,
        "weaponMagazineRelationships": sum(len(weapon.get("compatibleMagazines", [])) for weapon in weapons),
        "weaponAttachmentRelationships": sum(len(weapon.get("compatibleAttachments", [])) for weapon in weapons),
    }
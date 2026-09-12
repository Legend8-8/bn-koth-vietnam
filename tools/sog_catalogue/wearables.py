"""
Author: Legend

Pure classification and rendering for the one-time frozen S.O.G. wearable
inventory. This module records source facts; it does not define KOTH policy.
"""

from __future__ import annotations

import csv
import io
from typing import Any

from .classify import derive_source_affiliations


EXCLUDED_SOURCE_CLASSES = {
    "Vest_NoCamo_Base": "Non-S.O.G. base/helper record with no display name.",
    "vn_default_helmetbase_09": "Base/helper helmet record, not a curated player item.",
}

STARTER_LEVELS = {
    "vn_b_uniform_aus_01_01": 1,
    "vn_b_vest_sog_04": 1,
    "vn_o_uniform_nva_army_03_03": 1,
    "vn_o_vest_01": 1,
}

LEVEL_BANDS = {
    "uniform": [5, 10, 15, 20, 25, 30, 35, 40],
    "vest": [5, 15, 25, 35, 45],
    "headgear": [5, 10, 15, 20, 25, 30],
    "backpack": [5, 10, 15, 20, 25, 30, 35, 40, 45],
}


def classify_wearable(row: dict[str, Any]) -> tuple[str, str]:
    class_name = str(row.get("class", ""))
    lowered = class_name.lower()
    if class_name in EXCLUDED_SOURCE_CLASSES:
        return "excluded", EXCLUDED_SOURCE_CLASSES[class_name]
    if not class_name.startswith("vn_"):
        return "unresolved", "Class is not in the frozen S.O.G. vn_ namespace."
    if "_uniform_" in lowered:
        return "uniform", "Official CfgWeapons equipment uniform record."
    if "_vest_" in lowered:
        return "vest", "Official CfgWeapons equipment vest record."
    return "headgear", "Remaining selectable official CfgWeapons equipment record."


def build_wearable_inventory(rows: list[dict[str, Any]], source_url: str) -> tuple[list[dict[str, Any]], list[dict[str, str]]]:
    inventory: list[dict[str, Any]] = []
    review: list[dict[str, str]] = []
    for row in rows:
        category, classification_basis = classify_wearable(row)
        if category == "excluded":
            review.append({
                "classname": str(row.get("class", "")),
                "displayName": str(row.get("displayName", "")),
                "category": category,
                "reason": classification_basis,
            })
            continue

        used_by = sorted(set(str(value) for value in row.get("usedBy", []) if value))
        inventory.append({
            "category": category,
            "classname": str(row.get("class", "")),
            "displayName": str(row.get("displayName", "")),
            "description": str(row.get("description", "")),
            "version": str(row.get("version", "")),
            "sourcePage": "CfgWeapons_Equipment",
            "sourceUrl": source_url,
            "sourceAffiliations": derive_source_affiliations(used_by),
            "usedBy": used_by,
            "classificationBasis": classification_basis,
        })

        affiliations = derive_source_affiliations(used_by)
        if category in {"uniform", "vest"}:
            has_west = "WEST" in affiliations
            has_east = "EAST" in affiliations
            if has_west == has_east:
                review.append({
                    "classname": str(row.get("class", "")),
                    "displayName": str(row.get("displayName", "")),
                    "category": category,
                    "reason": "No unique WEST/EAST side can be authored from official Used by evidence.",
                })

    inventory.sort(key=lambda entry: (entry["category"], entry["classname"].lower()))
    review.sort(key=lambda entry: (entry["category"], entry["classname"].lower()))
    return inventory, review


def classify_backpack_class(class_name: str) -> tuple[bool, str]:
    lowered = class_name.lower()
    if not class_name.startswith("vn_"):
        return False, "Not a supplied S.O.G. vn_* class."
    if "_pl" in lowered:
        return False, "Preloaded/role backpack variant (_pl)."
    if "static" in lowered:
        return False, "Static-weapon/support bag."
    if "parachute" in lowered:
        return False, "Parachute bag."
    if class_name.startswith("vn_c_"):
        return False, "Civilian/non-player utility bag."
    if not (class_name.startswith("vn_b_") or class_name.startswith("vn_o_")):
        return False, "No approved WEST/EAST wearable-backpack policy prefix."
    return True, "Public Bag_Base class from supplied live Arma debug-console dump."


def build_backpack_inventory(class_names: list[str]) -> tuple[list[dict[str, Any]], list[dict[str, str]]]:
    inventory: list[dict[str, Any]] = []
    review: list[dict[str, str]] = []
    for class_name in sorted(set(value.strip() for value in class_names if value.strip()), key=str.lower):
        included, reason = classify_backpack_class(class_name)
        if not included:
            review.append({
                "classname": class_name,
                "displayName": "",
                "category": "backpack",
                "reason": reason,
            })
            continue
        side = "WEST" if class_name.startswith("vn_b_") else "EAST"
        inventory.append({
            "category": "backpack",
            "classname": class_name,
            "displayName": "",
            "description": "",
            "version": "",
            "sourcePage": "Live Arma Bag_Base debug-console dump",
            "sourceUrl": "",
            "sourceAffiliations": [side],
            "usedBy": [],
            "classificationBasis": reason,
        })
    return inventory, review


def render_inventory_csv(inventory: list[dict[str, Any]]) -> str:
    output = io.StringIO(newline="")
    fields = [
        "category",
        "classname",
        "displayName",
        "description",
        "version",
        "sourcePage",
        "sourceUrl",
        "sourceAffiliations",
        "usedBy",
        "classificationBasis",
    ]
    writer = csv.DictWriter(output, fieldnames=fields, lineterminator="\n")
    writer.writeheader()
    for entry in sorted(inventory, key=lambda value: (value["category"], value["classname"].lower())):
        row = dict(entry)
        row["sourceAffiliations"] = ";".join(entry["sourceAffiliations"])
        row["usedBy"] = ";".join(entry["usedBy"])
        writer.writerow(row)
    return output.getvalue()


def render_review_csv(review: list[dict[str, str]]) -> str:
    output = io.StringIO(newline="")
    fields = ["classname", "displayName", "category", "reason"]
    writer = csv.DictWriter(output, fieldnames=fields, lineterminator="\n")
    writer.writeheader()
    writer.writerows(review)
    return output.getvalue()


def resolve_policy_side(entry: dict[str, Any]) -> str:
    if entry["category"] == "headgear":
        return "BOTH"
    affiliations = set(entry["sourceAffiliations"])
    has_west = "WEST" in affiliations
    has_east = "EAST" in affiliations
    if has_west == has_east:
        return ""
    return "WEST" if has_west else "EAST"


def build_curated_metadata(inventory: list[dict[str, Any]]) -> list[dict[str, Any]]:
    curated: list[dict[str, Any]] = []
    per_group_index: dict[tuple[str, str], int] = {}
    for entry in inventory:
        side = resolve_policy_side(entry)
        if not side:
            continue
        class_name = entry["classname"]
        group = (entry["category"], side)
        index = per_group_index.get(group, 0)
        bands = LEVEL_BANDS[entry["category"]]
        level = STARTER_LEVELS.get(class_name, bands[index % len(bands)])
        per_group_index[group] = index + 1
        curated.append({
            "category": entry["category"],
            "classname": class_name,
            "allowedSides": ["WEST", "EAST"] if side == "BOTH" else [side],
            "appearanceSide": side,
            "minLevel": level,
        })
    return curated


def render_metadata_hpp(curated: list[dict[str, Any]]) -> str:
    lines = [
        "/*",
        "    Author: Legend",
        "",
        "    Static one-time KOTH wearable policy curated from",
        "    data/wearable_inventory.csv. Facts remain in the CSV; this file owns",
        "    human-authored allowedSides, appearanceSide, and provisional minLevel.",
        "*/",
        "",
    ]
    for entry in curated:
        allowed = ", ".join(f'\"{side}\"' for side in entry["allowedSides"])
        lines.append(
            f'class {entry["classname"]} '
            f'{{allowedSides[] = {{{allowed}}}; appearanceSide = "{entry["appearanceSide"]}"; '
            f'minLevel = {entry["minLevel"]};}};'
        )
    return "\n".join(lines) + "\n"

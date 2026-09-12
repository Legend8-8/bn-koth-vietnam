from __future__ import annotations

import csv
import io
import re
from typing import Any

from .catalogue import CatalogueError


LAUNCHER_MAGAZINE_CATEGORIES = {
    "grenade_20mm",
    "grenade_22mm",
    "grenade_40mm",
    "launcher_round",
}

SMALLARM_MAGAZINE_CATEGORIES = {
    "pistol_mag",
    "smg_mag",
    "rifle_mag",
    "lmg_mag",
    "shotgun_mag",
}


def validate_catalogue(catalogue: dict[str, Any]) -> dict[str, list[str]]:
    weapons = catalogue["weapons"]
    magazines = catalogue["magazines"]
    items = catalogue["items"]
    warnings: dict[str, list[str]] = {
        "baseMagazines": [],
        "duplicateRootDisplayNames": [],
        "integratedLauncherRoots": [],
        "relationships": [],
        "suspiciousLauncherRoots": [],
        "unresolvedRelatedRoots": [],
        "variants": [],
        "orphans": [],
        "exclusions": [],
    }

    if not weapons:
        raise CatalogueError("Zero weapons were parsed from the required source pages.")
    if not magazines:
        raise CatalogueError("Zero magazines were parsed from the required source pages.")

    assert_unique_classes(weapons, magazines, items)
    assert_no_vnx_assets(weapons, magazines, items)

    all_assets = {record["class"] for record in weapons} | {record["class"] for record in magazines} | {record["class"] for record in items}

    for weapon in weapons:
        primary_mags = weapon.get("muzzles", {}).get("primary", {}).get("magazines", [])
        base_magazine = weapon.get("baseMagazine")
        if base_magazine is not None and base_magazine not in primary_mags:
            raise CatalogueError(
                f"Weapon {weapon['class']} has baseMagazine {base_magazine} outside primary muzzle candidates."
            )
        if weapon.get("baseMagazineConfidence") in {"ambiguous", "missing"}:
            warnings["baseMagazines"].append(
                f"{weapon['class']}: {weapon['baseMagazineConfidence']} ({', '.join(candidate['class'] for candidate in weapon.get('baseMagazineCandidates', []))})"
            )
        if weapon.get("variantOf"):
            if weapon["variantOf"] not in all_assets:
                raise CatalogueError(
                    f"Weapon {weapon['class']} variantOf {weapon['variantOf']} is not present in the catalogue."
                )
            for requirement in weapon["derivedRequirements"]:
                if requirement not in all_assets:
                    raise CatalogueError(
                        f"Weapon {weapon['class']} derived requirement {requirement} is not present in the catalogue."
                    )
        elif weapon.get("variantCandidateOf"):
            warnings["variants"].append(
                f"{weapon['class']}: family={weapon['family']} candidate={weapon['variantCandidateOf']} remains ambiguous"
            )

    root_audit_warnings = build_root_audit_warnings(weapons, magazines)
    for category, entries in root_audit_warnings.items():
        warnings[category].extend(entries)

    relationship_state = catalogue["relationships"]
    for weapon_class, magazine_class in relationship_state["oneSidedWeaponToMagazine"]:
        warnings["relationships"].append(f"forward only: {weapon_class} -> {magazine_class}")
    for magazine_class, weapon_class in relationship_state["oneSidedMagazineToWeapon"]:
        warnings["relationships"].append(f"reverse only: {magazine_class} -> {weapon_class}")
    for weapon_class, magazine_class in relationship_state["missingMagazines"]:
        warnings["orphans"].append(f"missing magazine: {weapon_class} -> {magazine_class}")
    for weapon_class, attachment_class in relationship_state["missingAttachments"]:
        warnings["orphans"].append(f"missing attachment: {weapon_class} -> {attachment_class}")

    for entry in catalogue["summary"]["exclusions"]["vnx"]:
        warnings["exclusions"].append(entry)

    return warnings


def normalize_display_name(value: str) -> str:
    normalized = value.strip().lower()
    normalized = re.sub(r"\s+", " ", normalized)
    return normalized


def root_weapon_records(weapons: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return [weapon for weapon in weapons if not weapon.get("variantOf")]


def weapon_muzzle_kinds(weapon: dict[str, Any]) -> list[str]:
    return sorted(
        {
            muzzle.get("kind", "")
            for muzzle in weapon.get("muzzles", {}).values()
            if muzzle.get("kind", "")
        }
    )


def weapon_magazine_categories(weapon: dict[str, Any], magazine_map: dict[str, dict[str, Any]]) -> list[str]:
    return sorted(
        {
            magazine_map[magazine_class]["category"]
            for magazine_class in weapon.get("compatibleMagazines", [])
            if magazine_class in magazine_map
        }
    )


def format_root_details(weapon: dict[str, Any], magazine_map: dict[str, dict[str, Any]]) -> str:
    muzzle_kinds = weapon_muzzle_kinds(weapon)
    magazine_categories = weapon_magazine_categories(weapon, magazine_map)
    return (
        f"{weapon['class']} display={weapon.get('displayName', '')} "
        f"type={weapon.get('weaponType', '')} family={weapon.get('family', '')} "
        f"muzzles={'+'.join(muzzle_kinds) if muzzle_kinds else 'none'} "
        f"magCategories={'+'.join(magazine_categories) if magazine_categories else 'none'}"
    )


def root_sort_key(weapon: dict[str, Any]) -> tuple[str, str, str]:
    return (
        weapon.get("family") or "",
        normalize_display_name(weapon.get("displayName", "")),
        weapon["class"],
    )


def build_root_audit_warnings(weapons: list[dict[str, Any]], magazines: list[dict[str, Any]]) -> dict[str, list[str]]:
    roots = root_weapon_records(weapons)
    magazine_map = {magazine["class"]: magazine for magazine in magazines}

    roots_by_family: dict[str, list[dict[str, Any]]] = {}
    for weapon in roots:
        family = weapon.get("family") or ""
        roots_by_family.setdefault(family, []).append(weapon)

    unresolved_related_roots = []
    for family, family_roots in roots_by_family.items():
        if family == "" or len(family_roots) <= 1:
            continue

        sorted_family_roots = sorted(family_roots, key=root_sort_key)
        for weapon in sorted_family_roots:
            related_classes = [candidate["class"] for candidate in sorted_family_roots if candidate["class"] != weapon["class"]]
            unresolved_related_roots.append(
                (
                    root_sort_key(weapon),
                    f"{format_root_details(weapon, magazine_map)} relatedRoots={','.join(related_classes)}"
                )
            )

    roots_by_display: dict[str, list[dict[str, Any]]] = {}
    for weapon in roots:
        display_key = normalize_display_name(weapon.get("displayName", ""))
        if display_key == "":
            continue
        roots_by_display.setdefault(display_key, []).append(weapon)

    duplicate_root_display_names = []
    for display_key, display_roots in roots_by_display.items():
        if len(display_roots) <= 1:
            continue

        sorted_display_roots = sorted(display_roots, key=root_sort_key)
        duplicate_root_display_names.append(
            (
                (
                    sorted_display_roots[0].get("family") or "",
                    display_key,
                    sorted_display_roots[0]["class"],
                ),
                f"display={display_key} roots=" + " | ".join(format_root_details(weapon, magazine_map) for weapon in sorted_display_roots),
            )
        )

    suspicious_launcher_roots = []
    integrated_launcher_roots = []
    for weapon in roots:
        muzzle_kinds = set(weapon_muzzle_kinds(weapon))
        magazine_categories = set(weapon_magazine_categories(weapon, magazine_map))
        has_launcher_path = "launcher" in muzzle_kinds or bool(magazine_categories & LAUNCHER_MAGAZINE_CATEGORIES)
        has_smallarm_path = "primary_firearm" in muzzle_kinds or "rifle_mag" in muzzle_kinds or bool(magazine_categories & SMALLARM_MAGAZINE_CATEGORIES)

        if weapon.get("weaponType") == "launcher" and not has_launcher_path:
            suspicious_launcher_roots.append((root_sort_key(weapon), format_root_details(weapon, magazine_map)))

        if has_smallarm_path and has_launcher_path:
            integrated_launcher_roots.append((root_sort_key(weapon), format_root_details(weapon, magazine_map)))

    return {
        "duplicateRootDisplayNames": [entry for _key, entry in sorted(duplicate_root_display_names, key=lambda item: item[0])],
        "integratedLauncherRoots": [entry for _key, entry in sorted(integrated_launcher_roots, key=lambda item: item[0])],
        "suspiciousLauncherRoots": [entry for _key, entry in sorted(suspicious_launcher_roots, key=lambda item: item[0])],
        "unresolvedRelatedRoots": [entry for _key, entry in sorted(unresolved_related_roots, key=lambda item: item[0])],
    }


def assert_unique_classes(weapons: list[dict[str, Any]], magazines: list[dict[str, Any]], items: list[dict[str, Any]]) -> None:
    all_classes = [record["class"] for record in weapons] + [record["class"] for record in magazines] + [record["class"] for record in items]
    duplicates = sorted({class_name for class_name in all_classes if all_classes.count(class_name) > 1})
    if duplicates:
        raise CatalogueError(f"Duplicate canonical class IDs detected: {', '.join(duplicates)}")


def assert_no_vnx_assets(weapons: list[dict[str, Any]], magazines: list[dict[str, Any]], items: list[dict[str, Any]]) -> None:
    vnx_assets = [record["class"] for record in [*weapons, *magazines, *items] if record["class"].startswith("vnx_")]
    if vnx_assets:
        raise CatalogueError(f"Generated catalogue still contains VNX assets: {', '.join(sorted(vnx_assets))}")


def render_report(catalogue: dict[str, Any], warnings: dict[str, list[str]]) -> str:
    summary = catalogue["summary"]
    relationship_state = catalogue["relationships"]

    sections = [
        "SOURCE COVERAGE",
        f"- weapon rows found: {summary['sourceCoverage']['weaponRows']}",
        f"- item rows found: {summary['sourceCoverage']['itemRows']}",
        f"- magazine rows found: {summary['sourceCoverage']['magazineRows']}",
        "",
        "FILTERING",
        f"- accepted weapons: {summary['filtering']['accepted']['weapons']}",
        f"- accepted items: {summary['filtering']['accepted']['items']}",
        f"- accepted magazines: {summary['filtering']['accepted']['magazines']}",
    ]

    for group, counts in summary["filtering"]["rejectedReasons"].items():
        sections.append(f"- rejected {group}: {counts}")

    sections.extend(
        [
            "",
            "SOURCE AFFILIATIONS (FACTUAL)",
            f"- WEST evidence only: {summary['sourceAffiliations']['weaponBuckets']['WEST']}",
            f"- EAST evidence only: {summary['sourceAffiliations']['weaponBuckets']['EAST']}",
            f"- INDEPENDENT evidence only: {summary['sourceAffiliations']['weaponBuckets']['INDEPENDENT']}",
            f"- WEST+EAST shared evidence: {summary['sourceAffiliations']['weaponBuckets']['WEST+EAST']}",
            f"- WEST+INDEPENDENT shared evidence: {summary['sourceAffiliations']['weaponBuckets']['WEST+INDEPENDENT']}",
            f"- EAST+INDEPENDENT shared evidence: {summary['sourceAffiliations']['weaponBuckets']['EAST+INDEPENDENT']}",
            f"- WEST+EAST+INDEPENDENT shared evidence: {summary['sourceAffiliations']['weaponBuckets']['WEST+EAST+INDEPENDENT']}",
            f"- no affiliation evidence: {summary['sourceAffiliations']['weaponBuckets']['NONE']}",
            f"- ambiguous/shared (including INDEPENDENT-only): {summary['sourceAffiliations']['ambiguousOrShared']}",
            "",
            "RELATIONSHIPS",
            f"- weapon-magazine links: {summary['relationships']['weaponMagazineLinks']}",
            f"- weapon-attachment links: {summary['relationships']['weaponAttachmentLinks']}",
            f"- confirmed reverse relationships: {summary['relationships']['confirmedReverseRelationships']}",
            f"- one-sided weapon->magazine: {summary['relationships']['oneSidedWeaponToMagazine']}",
            f"- one-sided magazine->weapon: {summary['relationships']['oneSidedMagazineToWeapon']}",
            f"- unexplained relationship mismatches: {summary['relationships']['unexplainedMismatches']}",
            f"- excluded-target reverse relationships: {summary['relationships']['excludedTargetReverseRelationships']}",
            "",
            "MUZZLES",
            f"- multi-muzzle weapons found: {summary['muzzles']['multiMuzzleWeapons']}",
            f"- primary/secondary grouping confidence: {summary['muzzles']['primarySecondaryGroupingConfidence']}",
            f"- ambiguous grouping: {summary['muzzles']['ambiguousGrouping']}",
            "",
            "BASE MAGAZINES",
            f"- high-confidence assignments: {summary['baseMagazines']['highConfidence']}",
            f"- ambiguous weapon records: {summary['baseMagazines']['ambiguous']}",
            f"- unique ambiguous primary-magazine candidate sets: {summary['baseMagazines']['uniqueAmbiguousCandidateSets']}",
            f"- unique ambiguous weapon families: {summary['baseMagazines']['uniqueAmbiguousFamilies']}",
            f"- missing candidates: {summary['baseMagazines']['missing']}",
            f"- overrides applied: {summary['baseMagazines']['overrides']}",
            "",
            "VARIANTS",
            f"- families detected: {summary['variants']['families']}",
            f"- variant candidates: {summary['variants']['candidates']}",
            f"- confidently derived relationships: {summary['variants']['derived']}",
            f"- ambiguous relationships: {summary['variants']['ambiguous']}",
            f"- overrides applied: {summary['variants']['overrides']}",
            "",
            "ORPHANS / ERRORS",
            f"- referenced magazine missing from catalogue: {summary['orphans']['missingMagazines']}",
            f"- referenced attachment missing from catalogue: {summary['orphans']['missingAttachments']}",
            "",
            "PROGRESSION WORK",
            f"- weapon count: {summary['progression']['weapons']}",
            f"- unique progression-weapon count: {summary['progression']['progressionWeapons']}",
            f"- unique included base-mag count: {summary['progression']['includedBaseMagazines']}",
            f"- unique extra-mag count: {summary['progression']['extraMagazines']}",
            f"- unique attachment count: {summary['progression']['attachments']}",
            f"- unique confirmed derived-class count: {summary['progression']['derivedClasses']}",
            f"- total unique future progression assets: {summary['progression']['totalFutureProgressionAssets']}",
            f"- weapon-magazine relationship links: {summary['progression']['weaponMagazineRelationships']}",
            f"- weapon-attachment relationship links: {summary['progression']['weaponAttachmentRelationships']}",
            "",
            "EXCLUSIONS",
            f"- vnx_* records excluded: {len(summary['exclusions']['vnx'])}",
        ]
    )

    if summary["overridesApplied"]:
        sections.extend(["", "OVERRIDES", *[f"- {entry}" for entry in summary["overridesApplied"]]])

    sections.extend(["", "VALIDATION WARNINGS"])
    if not any(warnings.values()):
        sections.append("- none")
    else:
        for category in sorted(warnings):
            entries = warnings[category]
            if not entries:
                continue
            sections.append(f"- {category}: {len(entries)}")
            sections.extend(f"  - {entry}" for entry in entries[:25])

    sections.extend(
        [
            "",
            "RELATIONSHIP DETAILS",
            *[f"- forward only: {weapon} -> {magazine}" for weapon, magazine in relationship_state["oneSidedWeaponToMagazine"][:25]],
            *[f"- reverse only: {magazine} -> {weapon}" for magazine, weapon in relationship_state["oneSidedMagazineToWeapon"][:25]],
            *[
                f"- excluded reverse only: {magazine} -> {weapon} ({reason})"
                for magazine, weapon, reason in relationship_state["excludedTargetReverseRelationships"][:25]
            ],
        ]
    )

    return "\n".join(sections).rstrip() + "\n"


def build_progression_rows(catalogue: dict[str, Any]) -> list[list[str]]:
    rows = [["Asset", "Type", "ProgressionRequired", "Families", "UsedByCount", "UsedBy", "RelatedWeapons", "Reason"]]

    assets: dict[str, dict[str, Any]] = {}

    def ensure_asset(asset_class: str, asset_type: str, progression_required: str) -> dict[str, Any]:
        if asset_class not in assets:
            assets[asset_class] = {
                "type": asset_type,
                "progressionRequired": progression_required,
                "families": set(),
                "usedBy": set(),
                "relatedWeapons": set(),
                "reasons": set(),
            }
        return assets[asset_class]

    for weapon in catalogue["weapons"]:
        family = weapon.get("family") or ""
        if weapon.get("variantOf"):
            weapon_row = ensure_asset(weapon["class"], "Derived Weapon", "NO")
            weapon_row["reasons"].add(f"canonical alias of {weapon['variantOf']}")
            weapon_row["relatedWeapons"].add(weapon["variantOf"])
        else:
            weapon_row = ensure_asset(weapon["class"], "Weapon", "YES")
            weapon_row["reasons"].add("weapon")

        if family:
            weapon_row["families"].add(family)

        if weapon.get("baseMagazine"):
            base_row = ensure_asset(weapon["baseMagazine"], "Base Magazine", "NO")
            if family:
                base_row["families"].add(family)
            base_row["usedBy"].add(weapon["class"])
            base_row["reasons"].add("included base magazine")

        for magazine_class in weapon.get("unlockableMagazines", []):
            mag_row = ensure_asset(magazine_class, "Magazine", "YES")
            if family:
                mag_row["families"].add(family)
            mag_row["usedBy"].add(weapon["class"])
            mag_row["reasons"].add("additional compatible magazine")

        for attachment_class in weapon.get("unlockableAttachments", []):
            attachment_row = ensure_asset(attachment_class, "Attachment", "YES")
            if family:
                attachment_row["families"].add(family)
            attachment_row["usedBy"].add(weapon["class"])
            attachment_row["reasons"].add("compatible attachment")

    for asset_class in sorted(assets):
        entry = assets[asset_class]
        used_by = sorted(entry["usedBy"])
        rows.append(
            [
                asset_class,
                entry["type"],
                entry["progressionRequired"],
                ";".join(sorted(entry["families"])),
                str(len(used_by)),
                ";".join(used_by),
                ";".join(sorted(entry["relatedWeapons"])),
                ";".join(sorted(entry["reasons"])),
            ]
        )

    return rows


def render_progression_csv(catalogue: dict[str, Any]) -> str:
    output = io.StringIO()
    writer = csv.writer(output, lineterminator="\n")
    writer.writerows(build_progression_rows(catalogue))
    return output.getvalue()
from __future__ import annotations

import json
from pathlib import Path
import unittest

from tools.sog_catalogue.catalogue import CatalogueError, parse_all_pages, parse_main_table
from tools.sog_catalogue.classify import build_base_candidate_groups, build_catalogue, derive_source_affiliations, find_variant_base_candidate
from tools.sog_catalogue.validate import build_root_audit_warnings, build_progression_rows, validate_catalogue


WEAPONS_SAMPLE = """{{Template:AssetsMenu}}<br />
{| class="wikitable sortable"
! Ver.<br />
! Preview<br />
! Class<br />
! Name<br />
! Inventory description<br />
! Magazines<br />
! Accessories<br />
! Used by<br />
|-
| 1.0
|[[File:preview_vn_m16.jpg|150px|&nbsp;]]
| <span id="vn_m16" >'''vn_m16'''</span>
| ''M16A1''
| ''M16A1 5.56mm Assault Rifle. 20-round mag''
|
:[[CfgMagazines#vn_m16_20_mag|vn_m16_20_mag]]
|
:[[CfgWeapons_Items#vn_s_m16|vn_s_m16]]
|
{| class="wikitable mw-collapsible mw-collapsed"
! Objects
|-
|
:[[CfgVehicles WEST#vn_b_men_sog_07|vn_b_men_sog_07]]
|}
|}
"""

ITEMS_SAMPLE = """{{Template:AssetsMenu}}<br />
{| class="wikitable sortable"
! Ver.<br />
! Preview<br />
! Class<br />
! Name<br />
! Inventory description<br />
! Magazines<br />
! Used by<br />
|-
| 1.0
|[[File:preview_vn_s_m16.jpg|150px|&nbsp;]]
| <span id="vn_s_m16" >'''vn_s_m16'''</span>
| ''Suppressor [M16]''
| ''''
|
|
|}
"""

MAGAZINES_SAMPLE = """{{Template:AssetsMenu}}<br />
{| class="wikitable sortable"
! Ver.<br />
! Class<br />
! Name<br />
! Inventory description<br />
! Ammo<br />
! Used by<br />
|-
| 1.0
| <span id="vn_m16_20_mag" >'''vn_m16_20_mag'''</span>
| ''20Rnd. M16 Mag''
| ''20Rnd. M16 Magazine. Caliber: 5.56x45mm. Used in M16 and XM177''
| vn_556x45
|
:[[CfgWeapons_Weapons#vn_m16|vn_m16]]
|}
"""


def root_weapon(
    class_name: str,
    display_name: str,
    weapon_type: str,
    family: str,
    compatible_magazines: list[str],
) -> dict[str, object]:
    return {
        "class": class_name,
        "displayName": display_name,
        "weaponType": weapon_type,
        "family": family,
        "variantOf": None,
        "variantCandidateOf": None,
        "derivedRequirements": [],
        "compatibleMagazines": compatible_magazines,
        "compatibleAttachments": [],
        "muzzles": {"primary": {"kind": "rifle_mag", "magazines": compatible_magazines}},
        "baseMagazine": compatible_magazines[0] if compatible_magazines else None,
        "baseMagazineConfidence": "high",
        "baseMagazineCandidates": [],
    }


def variant_weapon(
    class_name: str,
    display_name: str,
    weapon_type: str,
    family: str,
    variant_of: str,
    derived_requirements: list[str],
) -> dict[str, object]:
    return {
        "class": class_name,
        "displayName": display_name,
        "weaponType": weapon_type,
        "family": family,
        "variantOf": variant_of,
        "variantCandidateOf": None,
        "derivedRequirements": derived_requirements,
        "compatibleMagazines": [],
        "compatibleAttachments": [],
        "muzzles": {},
        "baseMagazine": None,
        "baseMagazineConfidence": "high",
        "baseMagazineCandidates": [],
    }


def magazine(class_name: str, category: str) -> dict[str, str]:
    return {"class": class_name, "category": category}


def load_generated_catalogue() -> dict[str, object]:
    path = Path(__file__).resolve().parents[2] / "data" / "generated" / "sog_catalogue.json"
    return json.loads(path.read_text(encoding="utf-8"))


def resolve_variant_root(class_name: str, weapons: dict[str, dict[str, object]]) -> str:
    cursor = class_name
    safety = 0
    while safety < 16 and weapons[cursor].get("variantOf"):
        cursor = str(weapons[cursor]["variantOf"])
        safety += 1
    return cursor


class ParseTests(unittest.TestCase):
    def test_parse_main_table_handles_nested_subtables(self) -> None:
        headers, rows = parse_main_table(WEAPONS_SAMPLE)
        self.assertEqual(8, len(headers))
        self.assertEqual(1, len(rows))

    def test_parse_all_pages_fails_when_required_headers_missing(self) -> None:
        bad_weapons = WEAPONS_SAMPLE.replace("! Accessories<br />\n", "")
        with self.assertRaises(CatalogueError):
            parse_all_pages({"weapons": bad_weapons, "items": ITEMS_SAMPLE, "magazines": MAGAZINES_SAMPLE})


class ValidationTests(unittest.TestCase):
    def test_validate_rejects_base_magazine_outside_primary_muzzle(self) -> None:
        catalogue = {
            "weapons": [
                {
                    "class": "vn_test",
                    "baseMagazine": "vn_bad_mag",
                    "baseMagazineConfidence": "high",
                    "baseMagazineCandidates": [],
                    "variantOf": None,
                    "variantCandidateOf": None,
                    "derivedRequirements": [],
                    "family": "test",
                    "compatibleAttachments": [],
                    "muzzles": {"primary": {"magazines": ["vn_good_mag"]}},
                }
            ],
            "magazines": [{"class": "vn_good_mag"}],
            "items": [],
            "relationships": {
                "oneSidedWeaponToMagazine": [],
                "oneSidedMagazineToWeapon": [],
                "excludedTargetReverseRelationships": [],
                "missingMagazines": [],
                "missingAttachments": [],
            },
            "summary": {"exclusions": {"vnx": []}},
        }
        with self.assertRaises(CatalogueError):
            validate_catalogue(catalogue)

    def test_root_audit_reports_unresolved_related_roots_deterministically(self) -> None:
        weapons = [
            root_weapon("vn_alpha_camo", "Alpha Camo", "rifle", "alpha", ["vn_alpha_mag"]),
            root_weapon("vn_alpha", "Alpha", "rifle", "alpha", ["vn_alpha_mag"]),
            root_weapon("vn_bravo", "Bravo", "rifle", "bravo", ["vn_bravo_mag"]),
        ]
        magazines = [magazine("vn_alpha_mag", "rifle_mag"), magazine("vn_bravo_mag", "rifle_mag")]

        warnings = build_root_audit_warnings(weapons, magazines)

        self.assertEqual(2, len(warnings["unresolvedRelatedRoots"]))
        self.assertIn("vn_alpha", warnings["unresolvedRelatedRoots"][0])
        self.assertIn("vn_alpha_camo", warnings["unresolvedRelatedRoots"][1])
        self.assertEqual([], [entry for entry in warnings["unresolvedRelatedRoots"] if "vn_bravo" in entry])

    def test_confirmed_structural_variants_are_not_reported_as_roots(self) -> None:
        weapons = [
            root_weapon("vn_m16", "M16A1", "rifle", "m16", ["vn_m16_mag"]),
            variant_weapon("vn_m16_sd", "M16A1 (S)", "rifle", "m16", "vn_m16", ["vn_m16", "vn_s_m16"]),
        ]
        magazines = [magazine("vn_m16_mag", "rifle_mag")]

        warnings = build_root_audit_warnings(weapons, magazines)

        self.assertEqual([], warnings["unresolvedRelatedRoots"])
        self.assertEqual([], warnings["duplicateRootDisplayNames"])

    def test_duplicate_root_display_names_require_two_roots(self) -> None:
        weapons = [
            root_weapon("vn_m16_xm148", "M16A1 (XM148)", "rifle", "m16", ["vn_m16_mag"]),
            root_weapon("vn_m16_muzzle", "M16A1 (XM148)", "launcher", "m16_muzzle", ["vn_m16_mag"]),
            variant_weapon("vn_m16_shadow", "M16A1 (XM148)", "rifle", "m16", "vn_m16_xm148", ["vn_m16_xm148", "vn_o_m16"]),
        ]
        magazines = [magazine("vn_m16_mag", "rifle_mag")]

        warnings = build_root_audit_warnings(weapons, magazines)

        self.assertEqual(1, len(warnings["duplicateRootDisplayNames"]))
        self.assertIn("vn_m16_muzzle", warnings["duplicateRootDisplayNames"][0])
        self.assertIn("vn_m16_xm148", warnings["duplicateRootDisplayNames"][0])
        self.assertNotIn("vn_m16_shadow", warnings["duplicateRootDisplayNames"][0])

    def test_launcher_and_integrated_launcher_audit_warnings(self) -> None:
        weapons = [
            root_weapon("vn_m16_muzzle", "M16A1 (XM148)", "launcher", "m16_muzzle", ["vn_m16_mag"]),
            root_weapon("vn_m16_xm148", "M16A1 (XM148)", "rifle", "m16", ["vn_m16_mag", "vn_40mm_he_mag"]),
            root_weapon("vn_rpg", "RPG", "launcher", "rpg", ["vn_rpg_mag"]),
        ]
        weapons[1]["muzzles"] = {
            "primary": {"kind": "primary_firearm", "magazines": ["vn_m16_mag"]},
            "secondary_1": {"kind": "launcher", "magazines": ["vn_40mm_he_mag"]},
        }
        weapons[2]["muzzles"] = {"primary": {"kind": "launcher", "magazines": ["vn_rpg_mag"]}}
        magazines = [
            magazine("vn_m16_mag", "rifle_mag"),
            magazine("vn_40mm_he_mag", "grenade_40mm"),
            magazine("vn_rpg_mag", "launcher_round"),
        ]

        warnings = build_root_audit_warnings(weapons, magazines)

        self.assertEqual(1, len(warnings["suspiciousLauncherRoots"]))
        self.assertIn("vn_m16_muzzle", warnings["suspiciousLauncherRoots"][0])
        self.assertEqual(1, len(warnings["integratedLauncherRoots"]))
        self.assertIn("vn_m16_xm148", warnings["integratedLauncherRoots"][0])
        self.assertNotIn("vn_rpg", "\n".join(warnings["suspiciousLauncherRoots"]))

    def test_root_audit_does_not_mutate_classification(self) -> None:
        weapons = [root_weapon("vn_m16_xm148", "M16A1 (XM148)", "rifle", "m16", ["vn_m16_mag"])]
        before = [dict(weapon) for weapon in weapons]

        build_root_audit_warnings(weapons, [magazine("vn_m16_mag", "rifle_mag")])

        self.assertEqual(before, weapons)

    def test_live_m16_root_audit_expectations(self) -> None:
        catalogue = load_generated_catalogue()
        warnings = validate_catalogue(catalogue)
        text_by_category = {category: "\n".join(entries) for category, entries in warnings.items()}
        weapons = {weapon["class"]: weapon for weapon in catalogue["weapons"]}

        for class_name in ["vn_m16_bayo", "vn_m16_mrk", "vn_m16_sd", "vn_m16_nvg", "vn_m16_sniper"]:
            self.assertEqual("vn_m16", resolve_variant_root(class_name, weapons))
            self.assertTrue(weapons[class_name].get("derivedRequirements"))
            self.assertNotIn(class_name, text_by_category["unresolvedRelatedRoots"])

        for class_name in ["vn_m16_camo", "vn_m16_xm148", "vn_m16_m203", "vn_m16_m203_camo", "vn_m16_muzzle"]:
            self.assertEqual("vn_m16", resolve_variant_root(class_name, weapons))
            self.assertNotIn(class_name, text_by_category["unresolvedRelatedRoots"])

        self.assertEqual("smg", weapons["vn_mc10"]["weaponType"])
        self.assertEqual("smg", weapons["vn_mc10_sd"]["weaponType"])
        self.assertEqual("vn_mc10", weapons["vn_mc10_sd"].get("variantOf"))
        self.assertEqual(["vn_mc10", "vn_s_mc10"], weapons["vn_mc10_sd"].get("derivedRequirements"))

        self.assertEqual("vn_m21", resolve_variant_root("vn_m21_nvg", weapons))
        self.assertEqual(
            ["vn_m21", "vn_o_anpvs2_m14"],
            weapons["vn_m21_nvg"].get("derivedRequirements"),
        )
        self.assertEqual("vn_m21", resolve_variant_root("vn_m21_nvg_sd", weapons))
        self.assertEqual(
            ["vn_m21_nvg", "vn_s_m14"],
            weapons["vn_m21_nvg_sd"].get("derivedRequirements"),
        )

    def test_live_m16_duplicate_and_launcher_audit_expectations(self) -> None:
        warnings = validate_catalogue(load_generated_catalogue())
        duplicate_text = "\n".join(warnings["duplicateRootDisplayNames"])
        suspicious_text = "\n".join(warnings["suspiciousLauncherRoots"])
        integrated_text = "\n".join(warnings["integratedLauncherRoots"])

        self.assertNotIn("vn_m16_muzzle", duplicate_text)
        self.assertNotIn("vn_m16_xm148", duplicate_text)
        self.assertNotIn("vn_m16_muzzle", suspicious_text)
        for class_name in ["vn_m16_xm148", "vn_m16_m203", "vn_m16_m203_camo"]:
            self.assertNotIn(class_name, integrated_text)


class ClassificationTests(unittest.TestCase):
    def test_explicit_base_game_item_absent_from_sog_table_is_added(self) -> None:
        parsed_pages, _counts = parse_all_pages(
            {"weapons": WEAPONS_SAMPLE, "items": ITEMS_SAMPLE, "magazines": MAGAZINES_SAMPLE}
        )
        catalogue, summary = build_catalogue(
            parsed_pages,
            overrides={
                "additionalItems": [
                    {
                        "class": "ItemGPS",
                        "displayName": "GPS",
                        "source": "arma3",
                        "sourcePage": "CfgWeapons",
                        "itemType": "item",
                    }
                ]
            },
        )
        item = next(record for record in catalogue["items"] if record["class"] == "ItemGPS")

        self.assertEqual("arma3", item["source"])
        self.assertEqual("item", item["itemType"])
        self.assertEqual([], item["sourceAffiliations"])
        self.assertIn("additionalItem:ItemGPS", summary["overridesApplied"])

    def test_item_type_override_drives_traits_before_variant_classification(self) -> None:
        item_sample = ITEMS_SAMPLE.replace("vn_s_m16", "vn_b_camo_m16").replace(
            "Suppressor [M16]", "Camo wrap [M16]"
        )
        parsed_pages, _counts = parse_all_pages(
            {"weapons": WEAPONS_SAMPLE, "items": item_sample, "magazines": MAGAZINES_SAMPLE}
        )
        catalogue, _summary = build_catalogue(
            parsed_pages,
            overrides={"itemType": {"vn_b_camo_m16": "camo"}},
        )
        item = next(record for record in catalogue["items"] if record["class"] == "vn_b_camo_m16")

        self.assertEqual("camo", item["itemType"])
        self.assertEqual(["camo"], item["traits"])

    def test_used_by_survives_into_catalogue_and_west_affiliation_derives(self) -> None:
        parsed_pages, _counts = parse_all_pages({"weapons": WEAPONS_SAMPLE, "items": ITEMS_SAMPLE, "magazines": MAGAZINES_SAMPLE})
        catalogue, _summary = build_catalogue(parsed_pages, overrides={})
        weapon = next(record for record in catalogue["weapons"] if record["class"] == "vn_m16")
        self.assertIn("vn_b_men_sog_07", weapon["usedBy"])
        self.assertEqual(["WEST"], weapon["sourceAffiliations"])

    def test_source_affiliation_derivation_east_and_independent(self) -> None:
        self.assertEqual(["EAST"], derive_source_affiliations(["vn_o_men_nva_04"]))
        self.assertEqual(["INDEPENDENT"], derive_source_affiliations(["vn_i_men_army_02"]))

    def test_source_affiliation_mixed_and_missing_are_not_collapsed(self) -> None:
        self.assertEqual(["WEST", "EAST"], derive_source_affiliations(["vn_b_men_sog_07", "vn_o_men_nva_04"]))
        self.assertEqual([], derive_source_affiliations(["not_side_prefixed_class"]))

    def test_base_magazine_groups_collapse_tracer_pair(self) -> None:
        weapon = {"weaponType": "smg"}
        magazine_map = {
            "vn_f1_smg_mag": {
                "class": "vn_f1_smg_mag",
                "displayName": "34Rnd. F1 Mag",
                "description": "34Rnd. F1 Mag. Used in F1 SMG",
                "ammoClass": "vn_9x19",
                "category": "smg_mag",
                "traits": ["smg_mag"],
            },
            "vn_f1_smg_t_mag": {
                "class": "vn_f1_smg_t_mag",
                "displayName": "34Rnd. F1 Mag (Tracer)",
                "description": "34Rnd. F1 Mag tracer. Used in F1 SMG",
                "ammoClass": "vn_9x19",
                "category": "smg_mag",
                "traits": ["smg_mag", "tracer"],
            },
        }
        groups = build_base_candidate_groups(["vn_f1_smg_mag", "vn_f1_smg_t_mag"], weapon, magazine_map)
        self.assertEqual(1, len(groups))
        self.assertEqual("vn_f1_smg_mag", groups[0]["class"])
        self.assertEqual(["vn_f1_smg_mag", "vn_f1_smg_t_mag"], groups[0]["alternatives"])

    def test_variant_candidate_requires_structural_class_relation(self) -> None:
        weapon = {
            "class": "vn_m21",
            "displayName": "M21",
            "description": "M21 marksman rifle",
            "compatibleMagazines": ["vn_m14_mag"],
            "compatibleAttachments": ["vn_o_9x_m14"],
            "muzzles": {"primary": {"magazines": ["vn_m14_mag"]}},
        }
        family_group = [
            {
                "class": "vn_m14",
                "displayName": "M14",
                "description": "M14 battle rifle",
                "compatibleMagazines": ["vn_m14_mag"],
                "compatibleAttachments": [],
                "muzzles": {"primary": {"magazines": ["vn_m14_mag"]}},
            },
            weapon,
        ]
        item_map = {"vn_o_9x_m14": {"itemType": "optic"}}
        candidate = find_variant_base_candidate(weapon, family_group, item_map)
        if candidate is None:
            self.fail("Expected a variant candidate")
        self.assertFalse(candidate["confirmed"])

    def test_variant_candidate_confirms_with_explicit_source_evidence(self) -> None:
        weapon = {
            "class": "vn_m16_sd",
            "displayName": "M16A1 (S)",
            "description": "M16A1 fitted with suppressor",
            "compatibleMagazines": ["vn_m16_20_mag"],
            "compatibleAttachments": ["vn_s_m16"],
            "muzzles": {"primary": {"magazines": ["vn_m16_20_mag"]}},
        }
        family_group = [
            {
                "class": "vn_m16",
                "displayName": "M16A1",
                "description": "M16A1 5.56mm Assault Rifle",
                "compatibleMagazines": ["vn_m16_20_mag"],
                "compatibleAttachments": [],
                "muzzles": {"primary": {"magazines": ["vn_m16_20_mag"]}},
            },
            weapon,
        ]
        item_map = {"vn_s_m16": {"itemType": "suppressor"}}
        candidate = find_variant_base_candidate(weapon, family_group, item_map)
        if candidate is None:
            self.fail("Expected a variant candidate")
        self.assertTrue(candidate["confirmed"])


class ProgressionTests(unittest.TestCase):
    def test_progression_rows_are_canonical_per_asset(self) -> None:
        catalogue = {
            "weapons": [
                {
                    "class": "vn_w1",
                    "family": "f1",
                    "variantOf": None,
                    "derivedRequirements": [],
                    "baseMagazine": "vn_base_mag",
                    "unlockableMagazines": ["vn_extra_mag"],
                    "unlockableAttachments": ["vn_o_scope"],
                },
                {
                    "class": "vn_w2",
                    "family": "f2",
                    "variantOf": None,
                    "derivedRequirements": [],
                    "baseMagazine": "vn_base_mag",
                    "unlockableMagazines": ["vn_extra_mag"],
                    "unlockableAttachments": ["vn_o_scope"],
                },
            ]
        }
        rows = build_progression_rows(catalogue)
        assets = [row[0] for row in rows[1:]]
        self.assertEqual(len(assets), len(set(assets)))
        self.assertIn("vn_extra_mag", assets)
        self.assertIn("vn_o_scope", assets)


if __name__ == "__main__":
    unittest.main()

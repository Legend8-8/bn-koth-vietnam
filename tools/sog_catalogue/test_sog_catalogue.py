from __future__ import annotations

import unittest

from tools.sog_catalogue.catalogue import CatalogueError, parse_all_pages, parse_main_table
from tools.sog_catalogue.classify import build_base_candidate_groups, find_variant_base_candidate
from tools.sog_catalogue.validate import build_progression_rows, validate_catalogue


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


class ClassificationTests(unittest.TestCase):
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
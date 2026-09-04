"""
Author: Legend

Focused tests for the frozen one-time S.O.G. wearable inventory and its
human-authored appearance-policy projection.
"""

from __future__ import annotations

import csv
from io import StringIO
from pathlib import Path
import re
import unittest

from tools.sog_catalogue.catalogue import WEARABLE_SOURCE_PAGE, parse_wearable_page
from tools.sog_catalogue.wearables import (
    build_backpack_inventory,
    build_curated_metadata,
    build_wearable_inventory,
    render_inventory_csv,
)


EQUIPMENT_SAMPLE = """{| class="wikitable sortable"
! Ver.<br />
! Preview<br />
! Class<br />
! Name<br />
! Inventory description<br />
! Magazines<br />
! Used by<br />
|-
| 1.0
| [[File:uniform.jpg]]
| <span>'''vn_b_uniform_test_01'''</span>
| ''Test Uniform''
| ''A uniform''
|
|
:[[CfgVehicles WEST#vn_b_men_test|vn_b_men_test]]
|-
| 1.0
| [[File:hat.jpg]]
| <span>'''vn_b_boonie_test'''</span>
| ''Test Hat''
| ''A hat''
|
|
|}
"""


REPO_ROOT = Path(__file__).resolve().parents[2]
INVENTORY_PATH = REPO_ROOT / "data" / "wearable_inventory.csv"
METADATA_PATH = REPO_ROOT / "config" / "arsenal" / "wearables.hpp"
CLASS_PATTERN = re.compile(
    r'class\s+(\S+)\s+\{allowedSides\[\]\s*=\s*\{([^}]*)\};\s*'
    r'appearanceSide\s*=\s*"([^"]+)";\s*minLevel\s*=\s*(\d+);\};'
)


class WearableParserTests(unittest.TestCase):
    def test_official_equipment_shape_is_parsed_and_classified(self) -> None:
        rows = parse_wearable_page(EQUIPMENT_SAMPLE)
        inventory, review = build_wearable_inventory(rows, WEARABLE_SOURCE_PAGE["url"])

        self.assertEqual(2, len(inventory))
        by_class = {entry["classname"]: entry for entry in inventory}
        self.assertEqual("uniform", by_class["vn_b_uniform_test_01"]["category"])
        self.assertEqual(["WEST"], by_class["vn_b_uniform_test_01"]["sourceAffiliations"])
        self.assertEqual("headgear", by_class["vn_b_boonie_test"]["category"])
        self.assertEqual([], review)

    def test_csv_render_is_deterministic(self) -> None:
        rows = parse_wearable_page(EQUIPMENT_SAMPLE)
        inventory, _ = build_wearable_inventory(rows, WEARABLE_SOURCE_PAGE["url"])
        first = render_inventory_csv(inventory)
        second = render_inventory_csv(list(reversed(inventory)))
        self.assertEqual(first, second)

    def test_backpack_dump_filters_non_wearable_variants(self) -> None:
        inventory, review = build_backpack_inventory([
            "vn_b_pack_01",
            "vn_o_pack_01",
            "vn_b_pack_01_m79_pl",
            "vn_o_pack_static_rpd_01",
            "vn_o_pack_parachute_01",
            "vn_c_pack_01",
        ])
        self.assertEqual(["vn_b_pack_01", "vn_o_pack_01"], [entry["classname"] for entry in inventory])
        reasons = {entry["classname"]: entry["reason"] for entry in review}
        self.assertIn("Preloaded/role", reasons["vn_b_pack_01_m79_pl"])
        self.assertIn("Static-weapon", reasons["vn_o_pack_static_rpd_01"])
        self.assertIn("Parachute", reasons["vn_o_pack_parachute_01"])
        self.assertIn("Civilian", reasons["vn_c_pack_01"])


class WearableIntegrityTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.inventory = list(csv.DictReader(StringIO(INVENTORY_PATH.read_text(encoding="utf-8"))))
        cls.categories = {row["classname"]: row["category"] for row in cls.inventory}
        cls.metadata_text = METADATA_PATH.read_text(encoding="utf-8")
        cls.metadata = {}
        for match in CLASS_PATTERN.finditer(cls.metadata_text):
            allowed = [value.strip().strip('"') for value in match.group(2).split(",")]
            cls.metadata[match.group(1)] = {
                "allowedSides": allowed,
                "appearanceSide": match.group(3),
                "minLevel": int(match.group(4)),
            }

    def test_every_curated_entry_has_expected_appearance_policy(self) -> None:
        self.assertEqual(562, len(self.metadata))
        for class_name, metadata in self.metadata.items():
            category = self.categories[class_name]
            self.assertGreaterEqual(metadata["minLevel"], 1, class_name)
            if category == "headgear":
                self.assertEqual("BOTH", metadata["appearanceSide"], class_name)
                self.assertEqual(["WEST", "EAST"], metadata["allowedSides"], class_name)
            else:
                self.assertIn(category, {"uniform", "vest", "backpack"}, class_name)
                self.assertIn(metadata["appearanceSide"], {"WEST", "EAST"}, class_name)
                self.assertNotEqual("BOTH", metadata["appearanceSide"], class_name)
                self.assertEqual([metadata["appearanceSide"]], metadata["allowedSides"], class_name)

    def test_no_forbidden_economy_or_mastery_fields_exist(self) -> None:
        for field in ["masteryKillsRequired", "purchasePrice", "rentalPrice", "crossSideAllowed"]:
            self.assertNotIn(field, self.metadata_text)

    def test_starter_appearance_remains_level_one(self) -> None:
        for class_name in [
            "vn_b_uniform_aus_01_01",
            "vn_b_vest_sog_04",
            "vn_o_uniform_nva_army_03_03",
            "vn_o_vest_01",
        ]:
            self.assertEqual(1, self.metadata[class_name]["minLevel"], class_name)

    def test_frozen_inventory_excludes_vnx_and_contains_only_curated_backpacks(self) -> None:
        self.assertFalse(any("vnx" in row["classname"].lower() for row in self.inventory))
        backpacks = [row["classname"] for row in self.inventory if row["category"] == "backpack"]
        self.assertEqual(57, len(backpacks))
        self.assertTrue(all(class_name.startswith(("vn_b_", "vn_o_")) for class_name in backpacks))
        self.assertFalse(any("_pl" in class_name.lower() for class_name in backpacks))
        self.assertFalse(any("static" in class_name.lower() for class_name in backpacks))
        self.assertFalse(any("parachute" in class_name.lower() for class_name in backpacks))

    def test_curated_metadata_matches_pure_projection(self) -> None:
        normalized = []
        for row in self.inventory:
            normalized.append({
                **row,
                "sourceAffiliations": [value for value in row["sourceAffiliations"].split(";") if value],
                "usedBy": [value for value in row["usedBy"].split(";") if value],
            })
        expected = build_curated_metadata(normalized)
        self.assertEqual({entry["classname"] for entry in expected}, set(self.metadata))


if __name__ == "__main__":
    unittest.main()

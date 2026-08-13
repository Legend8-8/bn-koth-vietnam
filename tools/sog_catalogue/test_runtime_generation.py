from __future__ import annotations

import unittest

from tools.sog_catalogue.generate_runtime_config import build_runtime_hpp_text


class RuntimeGenerationTests(unittest.TestCase):
    def test_hpp_generation_is_deterministic(self) -> None:
        catalogue = {
            "weapons": [
                {
                    "class": "vn_m16",
                    "displayName": "M16A1",
                    "weaponType": "rifle",
                    "family": "m16",
                    "variantOf": None,
                    "variantTraits": [],
                    "derivedRequirements": [],
                    "baseMagazine": "vn_m16_20_mag",
                    "baseMagazineConfidence": "high",
                    "compatibleMagazines": ["vn_m16_20_mag", "vn_m16_30_mag"],
                    "compatibleAttachments": ["vn_s_m16"],
                    "usedBy": ["vn_b_men_sog_07"],
                    "sourceAffiliations": ["WEST"],
                }
            ],
            "magazines": [
                {
                    "class": "vn_m16_20_mag",
                    "displayName": "20Rnd M16 Mag",
                    "category": "rifle_mag",
                    "ammoClass": "vn_556x45",
                    "traits": ["rifle_mag"],
                    "compatibleWeapons": ["vn_m16"],
                    "usedBy": ["vn_m16"],
                    "sourceAffiliations": [],
                }
            ],
            "items": [
                {
                    "class": "vn_s_m16",
                    "displayName": "Suppressor [M16]",
                    "itemType": "suppressor",
                    "traits": ["suppressor"],
                    "magazines": [],
                    "compatibleWeapons": ["vn_m16"],
                    "usedBy": [],
                    "sourceAffiliations": [],
                }
            ],
        }

        first = build_runtime_hpp_text(catalogue)
        second = build_runtime_hpp_text(catalogue)
        self.assertEqual(first, second)

    def test_hpp_source_comment_is_machine_independent(self) -> None:
        catalogue = {"weapons": [], "magazines": [], "items": []}
        first = build_runtime_hpp_text(catalogue)
        second = build_runtime_hpp_text(catalogue)
        self.assertEqual(first, second)
        self.assertIn("// Source: data/generated/sog_catalogue.json", first)

    def test_hpp_contains_factual_fields_and_excludes_balance_fields(self) -> None:
        catalogue = {
            "weapons": [
                {
                    "class": "vn_m16_sd",
                    "displayName": "M16 \"SD\" \\\\ Variant",
                    "weaponType": "rifle",
                    "family": "m16",
                    "variantOf": "vn_m16",
                    "variantTraits": ["suppressed"],
                    "derivedRequirements": ["vn_m16", "vn_s_m16"],
                    "baseMagazine": "vn_m16_20_mag",
                    "baseMagazineConfidence": "high",
                    "compatibleMagazines": ["vn_m16_20_mag"],
                    "compatibleAttachments": ["vn_s_m16"],
                    "usedBy": ["vn_b_men_sog_07", "vn_o_men_nva_04"],
                    "sourceAffiliations": ["WEST", "EAST"],
                },
                {
                    "class": "vn_m16_amb",
                    "displayName": "M16 Ambiguous",
                    "weaponType": "rifle",
                    "family": "m16",
                    "variantOf": None,
                    "variantTraits": [],
                    "derivedRequirements": [],
                    "baseMagazine": None,
                    "baseMagazineConfidence": "ambiguous",
                    "compatibleMagazines": ["vn_m16_20_mag"],
                    "compatibleAttachments": [],
                    "usedBy": [],
                    "sourceAffiliations": [],
                },
            ],
            "magazines": [],
            "items": [],
        }

        text = build_runtime_hpp_text(catalogue)
        self.assertIn("class vn_m16_sd", text)
        self.assertIn("compatibleMagazines[]", text)
        self.assertIn("compatibleAttachments[]", text)
        self.assertIn("sourceAffiliations[]", text)
        self.assertIn("class WeaponVariants", text)
        self.assertIn("base = \"vn_m16\";", text)
        self.assertNotIn("class vn_m16_amb\n        {\n            base =", text)
        self.assertIn('displayName = "M16 ""SD"" \\\\ Variant";', text)
        self.assertNotIn("usedBy[]", text)
        self.assertNotIn("allowedSides", text)
        self.assertNotIn("price", text)
        self.assertNotIn("rental", text)
        self.assertNotIn("level", text)

    def test_arma_escape_quote_and_backslash_exact_text(self) -> None:
        catalogue = {
            "weapons": [
                {
                    "class": "vn_test_w",
                    "displayName": "Quoted \"Name\" \\ Path",
                    "weaponType": "rifle",
                    "family": "test",
                    "variantOf": None,
                    "variantTraits": [],
                    "derivedRequirements": [],
                    "baseMagazine": None,
                    "baseMagazineConfidence": "unknown",
                    "compatibleMagazines": [],
                    "compatibleAttachments": [],
                    "usedBy": ["vn_b_men_sog_07"],
                    "sourceAffiliations": ["WEST"],
                }
            ],
            "magazines": [],
            "items": [],
        }
        text = build_runtime_hpp_text(catalogue)
        self.assertIn('displayName = "Quoted ""Name"" \\ Path";', text)


if __name__ == "__main__":
    unittest.main()

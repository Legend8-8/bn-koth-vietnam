from __future__ import annotations

import argparse
from pathlib import Path
import json
from typing import Any


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_JSON_INPUT = REPO_ROOT / "data" / "generated" / "sog_catalogue.json"
DEFAULT_HPP_OUTPUT = REPO_ROOT / "config" / "arsenal" / "generated" / "sog_catalogue.hpp"
DEFAULT_AFFILIATION_REVIEW_OUTPUT = REPO_ROOT / "reports" / "generated" / "source_affiliation_review.csv"
GENERATOR_COMMAND = "python -m tools.sog_catalogue.generate_runtime_config"
CANONICAL_SOURCE_COMMENT = "data/generated/sog_catalogue.json"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate static Arsenal config from factual SOG catalogue JSON.")
    parser.add_argument("--json-in", type=Path, default=DEFAULT_JSON_INPUT)
    parser.add_argument("--hpp-out", type=Path, default=DEFAULT_HPP_OUTPUT)
    parser.add_argument("--affiliation-review-out", type=Path, default=DEFAULT_AFFILIATION_REVIEW_OUTPUT)
    return parser.parse_args()


def load_catalogue(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def arma_escape(value: str) -> str:
    escaped = value.replace("\r\n", "\n").replace("\r", "\n")
    escaped = escaped.replace("\n", " ").replace('"', '""')
    return f'"{escaped}"'


def arma_array(values: list[str]) -> str:
    return "{" + ", ".join(arma_escape(value) for value in values) + "}"


def write_output(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8", newline="\n")


def append_optional_string(lines: list[str], key: str, value: str | None, indent: str = "            ") -> None:
    if value:
        lines.append(f"{indent}{key} = {arma_escape(value)};")


def append_optional_array(lines: list[str], key: str, values: list[str], indent: str = "            ") -> None:
    if values:
        lines.append(f"{indent}{key}[] = {arma_array(values)};")


def is_confirmed_variant(weapon: dict[str, Any]) -> bool:
    return bool(weapon.get("variantOf") and weapon.get("derivedRequirements"))


def is_canonical_alias(weapon: dict[str, Any]) -> bool:
    return bool(weapon.get("variantOf"))


def build_weapon_classes(weapons: list[dict[str, Any]]) -> list[str]:
    lines: list[str] = ["    class SourceWeapons", "    {"]
    for weapon in sorted(weapons, key=lambda record: record["class"]):
        lines.append(f"        class {weapon['class']}")
        lines.append("        {")
        lines.append(f"            className = {arma_escape(weapon['class'])};")
        lines.append(f"            displayName = {arma_escape(weapon.get('displayName', ''))};")
        lines.append(f"            weaponType = {arma_escape(weapon.get('weaponType', ''))};")
        append_optional_string(lines, "family", weapon.get("family"))
        if is_canonical_alias(weapon):
            append_optional_string(lines, "variantOf", weapon.get("variantOf"))
            if is_confirmed_variant(weapon):
                append_optional_array(lines, "variantTraits", sorted(weapon.get("variantTraits", [])))
                append_optional_array(lines, "derivedRequirements", sorted(weapon.get("derivedRequirements", [])))
        append_optional_string(lines, "baseMagazine", weapon.get("baseMagazine"))
        lines.append(f"            baseMagazineConfidence = {arma_escape(weapon.get('baseMagazineConfidence', 'unknown'))};")
        append_optional_array(lines, "compatibleMagazines", sorted(weapon.get("compatibleMagazines", [])))
        append_optional_array(lines, "compatibleAttachments", sorted(weapon.get("compatibleAttachments", [])))
        append_optional_array(lines, "sourceAffiliations", sorted(weapon.get("sourceAffiliations", [])))
        lines.append("        };")
    lines.append("    };")
    return lines


def build_magazine_classes(magazines: list[dict[str, Any]]) -> list[str]:
    lines: list[str] = ["    class SourceMagazines", "    {"]
    for magazine in sorted(magazines, key=lambda record: record["class"]):
        lines.append(f"        class {magazine['class']}")
        lines.append("        {")
        lines.append(f"            className = {arma_escape(magazine['class'])};")
        lines.append(f"            displayName = {arma_escape(magazine.get('displayName', ''))};")
        lines.append(f"            category = {arma_escape(magazine.get('category', ''))};")
        lines.append(f"            ammoClass = {arma_escape(magazine.get('ammoClass', ''))};")
        append_optional_array(lines, "traits", sorted(magazine.get("traits", [])))
        append_optional_array(lines, "compatibleWeapons", sorted(magazine.get("compatibleWeapons", [])))
        append_optional_array(lines, "sourceAffiliations", sorted(magazine.get("sourceAffiliations", [])))
        lines.append("        };")
    lines.append("    };")
    return lines


def build_item_classes(items: list[dict[str, Any]]) -> list[str]:
    lines: list[str] = ["    class SourceItems", "    {"]
    for item in sorted(items, key=lambda record: record["class"]):
        lines.append(f"        class {item['class']}")
        lines.append("        {")
        lines.append(f"            className = {arma_escape(item['class'])};")
        lines.append(f"            displayName = {arma_escape(item.get('displayName', ''))};")
        lines.append(f"            itemType = {arma_escape(item.get('itemType', ''))};")
        append_optional_array(lines, "traits", sorted(item.get("traits", [])))
        append_optional_array(lines, "magazines", sorted(item.get("magazines", [])))
        append_optional_array(lines, "compatibleWeapons", sorted(item.get("compatibleWeapons", [])))
        append_optional_array(lines, "sourceAffiliations", sorted(item.get("sourceAffiliations", [])))
        lines.append("        };")
    lines.append("    };")
    return lines


def build_relationship_classes(weapons: list[dict[str, Any]]) -> list[str]:
    lines: list[str] = [
        "    class WeaponMagazines",
        "    {",
    ]
    for weapon in sorted(weapons, key=lambda record: record["class"]):
        lines.append(f"        class {weapon['class']}")
        lines.append("        {")
        append_optional_array(lines, "values", sorted(weapon.get("compatibleMagazines", [])), indent="            ")
        lines.append("        };")
    lines.extend(["    };", "", "    class WeaponAttachments", "    {"])
    for weapon in sorted(weapons, key=lambda record: record["class"]):
        lines.append(f"        class {weapon['class']}")
        lines.append("        {")
        append_optional_array(lines, "values", sorted(weapon.get("compatibleAttachments", [])), indent="            ")
        lines.append("        };")
    lines.extend(["    };", "", "    class WeaponVariants", "    {"])
    for weapon in sorted(weapons, key=lambda record: record["class"]):
        if not is_confirmed_variant(weapon):
            continue
        lines.append(f"        class {weapon['class']}")
        lines.append("        {")
        append_optional_string(lines, "base", weapon.get("variantOf"), indent="            ")
        append_optional_array(lines, "traits", sorted(weapon.get("variantTraits", [])), indent="            ")
        append_optional_array(lines, "requirements", sorted(weapon.get("derivedRequirements", [])), indent="            ")
        lines.append("        };")
    lines.append("    };")
    return lines


def build_variant_index_classes(weapons: list[dict[str, Any]], items: list[dict[str, Any]]) -> list[str]:
    lines: list[str] = ["    class WeaponVariantByBaseAndAttachments", "    {"]

    weapon_map = {weapon["class"]: weapon for weapon in weapons}
    item_classes = {item["class"] for item in items}
    processing: set[str] = set()
    signature_cache: dict[str, tuple[str, tuple[str, ...]] | None] = {}

    def resolve_signature(weapon_class: str) -> tuple[str, tuple[str, ...]] | None:
        if weapon_class in signature_cache:
            return signature_cache[weapon_class]
        if weapon_class in processing:
            signature_cache[weapon_class] = None
            return None

        weapon = weapon_map.get(weapon_class)
        if weapon is None:
            signature_cache[weapon_class] = None
            return None

        if not is_confirmed_variant(weapon):
            signature_cache[weapon_class] = (weapon_class, tuple())
            return signature_cache[weapon_class]

        base_class = weapon.get("variantOf") or ""
        if not base_class:
            signature_cache[weapon_class] = None
            return None

        processing.add(weapon_class)
        base_signature = resolve_signature(base_class)
        processing.remove(weapon_class)
        if base_signature is None:
            signature_cache[weapon_class] = None
            return None

        requirements = weapon.get("derivedRequirements", [])
        if base_class not in requirements:
            signature_cache[weapon_class] = None
            return None

        step_attachments = sorted(
            {
                requirement
                for requirement in requirements
                if requirement != base_class and requirement in item_classes
            }
        )

        root_class, base_attachments = base_signature
        combined_attachments = tuple(sorted(set(base_attachments) | set(step_attachments)))
        signature_cache[weapon_class] = (root_class, combined_attachments)
        return signature_cache[weapon_class]

    root_keys_to_targets: dict[str, dict[tuple[str, ...], list[str]]] = {}
    root_transforming_attachments: dict[str, set[str]] = {}

    for weapon in sorted(weapons, key=lambda record: record["class"]):
        if weapon.get("variantOf"):
            continue
        root_class = weapon["class"]
        root_keys_to_targets[root_class] = {tuple(): [root_class]}
        root_transforming_attachments[root_class] = set()

    for weapon in sorted(weapons, key=lambda record: record["class"]):
        if not is_confirmed_variant(weapon):
            continue

        signature = resolve_signature(weapon["class"])
        if signature is None:
            continue

        root_class, attachment_key = signature
        if root_class not in root_keys_to_targets:
            continue

        root_keys_to_targets[root_class].setdefault(attachment_key, []).append(weapon["class"])
        root_transforming_attachments[root_class].update(attachment_key)

    def attachment_key_to_class_name(attachments: tuple[str, ...]) -> str:
        if not attachments:
            return "k_none"
        return "k_" + "__".join(attachments)

    for root_class in sorted(root_keys_to_targets):
        lines.append(f"        class {root_class}")
        lines.append("        {")
        attachment_map = root_keys_to_targets[root_class]
        for attachment_key in sorted(attachment_map.keys()):
            candidate_targets = sorted(set(attachment_map[attachment_key]))
            key_class_name = attachment_key_to_class_name(attachment_key)
            lines.append(f"            class {key_class_name}")
            lines.append("            {")
            lines.append(f"                structuralAttachments[] = {arma_array(list(attachment_key))};")
            if len(candidate_targets) == 1:
                lines.append('                ambiguous = 0;')
                lines.append(f"                resolvedWeaponClass = {arma_escape(candidate_targets[0])};")
            else:
                lines.append('                ambiguous = 1;')
                lines.append('                resolvedWeaponClass = "";')
                lines.append(f"                candidates[] = {arma_array(candidate_targets)};")
            lines.append("            };")
        lines.append("        };")
    lines.append("    };")
    lines.append("")

    lines.append("    class WeaponVariantTransformingAttachments")
    lines.append("    {")
    for root_class in sorted(root_transforming_attachments):
        attachments = sorted(root_transforming_attachments[root_class])
        lines.append(f"        class {root_class}")
        lines.append("        {")
        lines.append(f"            values[] = {arma_array(attachments)};")
        lines.append("        };")
    lines.append("    };")
    return lines


def build_runtime_hpp_text(catalogue: dict[str, Any]) -> str:
    weapons = catalogue.get("weapons", [])
    magazines = catalogue.get("magazines", [])
    items = catalogue.get("items", [])

    lines = [
        "// MACHINE GENERATED FILE - DO NOT EDIT BY HAND.",
        f"// Source: {CANONICAL_SOURCE_COMMENT}",
        f"// Generator: {GENERATOR_COMMAND}",
        "// This file is included under CfgBnKothArsenal > Equipment > Compatibility.",
        "",
    ]
    lines.extend(build_weapon_classes(weapons))
    lines.append("")
    lines.extend(build_magazine_classes(magazines))
    lines.append("")
    lines.extend(build_item_classes(items))
    lines.append("")
    lines.extend(build_relationship_classes(weapons))
    lines.append("")
    lines.extend(build_variant_index_classes(weapons, items))
    lines.append("")
    return "\n".join(lines)


def build_affiliation_review_rows(catalogue: dict[str, Any]) -> list[list[str]]:
    rows = [["WeaponClass", "DisplayName", "SourceAffiliations", "UsedByCount", "UsedBy"]]
    for weapon in sorted(catalogue.get("weapons", []), key=lambda record: record["class"]):
        affiliations = weapon.get("sourceAffiliations", [])
        include = len(affiliations) != 1 or affiliations[0] == "INDEPENDENT"
        if not include:
            continue
        used_by = sorted(weapon.get("usedBy", []))
        rows.append(
            [
                weapon["class"],
                weapon.get("displayName", ""),
                "+".join(affiliations) if affiliations else "NONE",
                str(len(used_by)),
                ";".join(used_by),
            ]
        )
    return rows


def render_csv(rows: list[list[str]]) -> str:
    output_lines: list[str] = []
    for row in rows:
        escaped = []
        for value in row:
            if any(char in value for char in [",", '"', "\n"]):
                escaped_value = '"' + value.replace('"', '""') + '"'
                escaped.append(escaped_value)
            else:
                escaped.append(value)
        output_lines.append(",".join(escaped))
    return "\n".join(output_lines) + "\n"


def main() -> int:
    args = parse_args()
    catalogue = load_catalogue(args.json_in)
    hpp_text = build_runtime_hpp_text(catalogue)
    review_csv = render_csv(build_affiliation_review_rows(catalogue))

    write_output(args.hpp_out, hpp_text)
    write_output(args.affiliation_review_out, review_csv)

    print(f"HPP: {args.hpp_out}")
    print(f"AFFILIATION_REVIEW_CSV: {args.affiliation_review_out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

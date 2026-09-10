"""Validate authored AO metadata against each mission-ready map."""

from pathlib import Path
import re


REPOSITORY_ROOT = Path(__file__).resolve().parent.parent


def extract_class_body(text, class_name):
    match = re.search(rf"\bclass\s+{re.escape(class_name)}\s*\{{", text)
    if not match:
        return None
    start = text.find("{", match.start())
    depth = 0
    for index in range(start, len(text)):
        if text[index] == "{":
            depth += 1
        elif text[index] == "}":
            depth -= 1
            if depth == 0:
                return text[start + 1:index]
    return None


def direct_child_classes(class_body):
    children = []
    index = 0
    while index < len(class_body):
        match = re.search(r"\bclass\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{", class_body[index:])
        if not match:
            break
        name = match.group(1)
        opening = index + match.end() - 1
        depth = 0
        closing = None
        for cursor in range(opening, len(class_body)):
            if class_body[cursor] == "{":
                depth += 1
            elif class_body[cursor] == "}":
                depth -= 1
                if depth == 0:
                    closing = cursor
                    break
        if closing is None:
            break
        children.append((name, class_body[opening + 1:closing]))
        index = closing + 1
    return children


def validate_map(map_folder):
    config_path = map_folder / "map_config" / "locations.hpp"
    mission_path = map_folder / "mission.sqm"
    if not config_path.is_file():
        raise ValueError(f"{map_folder.name}: missing map_config/locations.hpp")

    config_text = config_path.read_text(encoding="utf-8-sig")
    mission_text = mission_path.read_text(encoding="utf-8-sig", errors="ignore")
    settings = extract_class_body(config_text, "CfgBnKothSettings")
    locations = extract_class_body(config_text, "CfgBnKothLocations")
    if settings is None or locations is None:
        raise ValueError(f"{map_folder.name}: locations config is missing settings or location classes")

    entries = direct_child_classes(locations)
    location_ids = [name for name, _body in entries]
    errors = []
    warnings = []
    if len(location_ids) != len(set(location_ids)):
        errors.append("location IDs are not unique")

    default_match = re.search(r'\bdefaultLocationId\s*=\s*"([^"]+)"', settings)
    default_id = default_match.group(1) if default_match else ""
    if default_id not in location_ids:
        errors.append(f"defaultLocationId '{default_id}' is not configured")
    rotation_match = re.search(r"\blocationRotation\[\]\s*=\s*\{([^}]*)\}", settings, re.DOTALL)
    rotation_ids = re.findall(r'"([^"]+)"', rotation_match.group(1)) if rotation_match else []
    if len(rotation_ids) != len(set(rotation_ids)):
        errors.append("locationRotation contains duplicate location IDs")
    for location_id in rotation_ids:
        if location_id not in location_ids:
            errors.append(f"rotation references unknown location '{location_id}'")
    for location_id in location_ids:
        if location_id not in rotation_ids:
            errors.append(f"configured location '{location_id}' is absent from locationRotation")

    required_roles = (
        ("zoneMarker", "zone"),
        ("respawnWestMarker", "respawn_west"),
        ("respawnEastMarker", "respawn_east"),
        ("westBaseZoneMarker", "west_base_zone"),
        ("eastBaseZoneMarker", "east_base_zone"),
        ("westCommand_mapboard", "west_command_mapboard"),
        ("eastCommand_mapboard", "east_command_mapboard"),
    )
    optional_vehicle_roles = (
        "westCommand_spawnpoint", "eastCommand_spawnpoint",
        "westPaidGround_spawnpoint", "westPaidAir_spawnpoint", "westPaidSea_spawnpoint",
        "westFreeGround_spawnpoint", "westFreeAir_spawnpoint", "westFreeSea_spawnpoint",
        "eastPaidGround_spawnpoint", "eastPaidAir_spawnpoint", "eastPaidSea_spawnpoint",
        "eastFreeGround_spawnpoint", "eastFreeAir_spawnpoint", "eastFreeSea_spawnpoint",
    )
    for location_id, body in entries:
        display_match = re.search(r'\bdisplayName\s*=\s*"([^"]*)"', body)
        description_match = re.search(r'\bdescription\s*=\s*"([^"]*)"', body)
        image_match = re.search(r'\bimage\s*=\s*"([^"]*)"', body)
        if not display_match or not display_match.group(1).strip():
            errors.append(f"{location_id}: displayName is missing")
        if not description_match or not description_match.group(1).strip():
            errors.append(f"{location_id}: description is missing")
        image_value = image_match.group(1) if image_match else ""
        image_path = Path(image_value.replace("\\", "/")) if image_value else None
        if image_path is None or not ((REPOSITORY_ROOT / image_path).is_file() or (map_folder / image_path).is_file()):
            warnings.append(f"{location_id}: image '{image_value}' does not resolve")

        min_match = re.search(r"\bminPlayers\s*=\s*(-?\d+)", body)
        max_match = re.search(r"\bmaxPlayers\s*=\s*(-?\d+)", body)
        minimum = int(min_match.group(1)) if min_match else 0
        maximum = int(max_match.group(1)) if max_match else -1
        if minimum < 0 or (maximum != -1 and maximum < minimum):
            errors.append(f"{location_id}: invalid minPlayers/maxPlayers range {minimum}/{maximum}")

        for config_key, suffix in required_roles:
            override = re.search(rf'\b{re.escape(config_key)}\s*=\s*"([^"]+)"', body)
            role = override.group(1) if override else f"{location_id}_{suffix}"
            if not re.search(rf'\b(?:name|text)\s*=\s*"{re.escape(role)}"', mission_text):
                errors.append(f"{location_id}: required role '{role}' is absent from mission.sqm")

        for config_key in optional_vehicle_roles:
            override = re.search(rf'\b{re.escape(config_key)}\s*=\s*"([^"]+)"', body)
            if override and not re.search(rf'\b(?:name|text)\s*=\s*"{re.escape(override.group(1))}"', mission_text):
                errors.append(f"{location_id}: configured vehicle role '{override.group(1)}' is absent from mission.sqm")

    if errors:
        raise ValueError(f"{map_folder.name}: AO validation failed:\n  - " + "\n  - ".join(errors))
    if warnings:
        print(f"AO validation warnings ({map_folder.name}):\n  - " + "\n  - ".join(warnings))
    print(f"Validated AO config ({map_folder.name}): {len(entries)} locations")


def main():
    validated = 0
    map_root = REPOSITORY_ROOT / "maps"
    for map_folder in sorted(path for path in map_root.iterdir() if path.is_dir()):
        if not (map_folder / "mission.sqm").is_file():
            print(f"Skipping map '{map_folder.name}' (missing maps/{map_folder.name}/mission.sqm)")
            continue
        validate_map(map_folder)
        validated += 1
    if validated == 0:
        raise ValueError("No mission-ready map folders found under maps/")
    print(f"AO validation complete: {validated} mission-ready map(s)")


if __name__ == "__main__":
    main()

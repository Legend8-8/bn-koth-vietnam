import ctypes
import os
from pathlib import Path
import shutil
import sys

import user_paths


def is_admin():
    try:
        return bool(ctypes.windll.shell32.IsUserAnAdmin())
    except Exception:
        return False


def rerun_as_admin_if_needed():
    if is_admin():
        return
    args = " ".join([f'"{arg}"' if " " in arg else arg for arg in sys.argv])
    ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, args, None, 1)
    sys.exit(0)


def symlink_immediate_children(target, source, exclude=None):
    for path in source.iterdir():
        if exclude and path.name in exclude:
            continue

        target_path = target / path.name
        if target_path.exists():
            continue

        target_path.symlink_to(path, target_is_directory=path.is_dir())


def replace_path(path):
    if not path.exists():
        return

    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.is_dir():
        shutil.rmtree(path)


def remove_excluded_paths(target_folder, excluded_names):
    for name in excluded_names:
        replace_path(target_folder / name)


def symlink_into_target(target, source, overwrite=False):
    for path in source.iterdir():
        target_path = target / path.name

        if target_path.exists():
            if not overwrite:
                continue
            replace_path(target_path)

        target_path.symlink_to(path, target_is_directory=path.is_dir())


def copy_into_target(target, source, overwrite=False):
    for path in source.iterdir():
        target_path = target / path.name

        if target_path.exists():
            if not overwrite:
                continue
            replace_path(target_path)

        if path.is_dir():
            shutil.copytree(path, target_path)
        else:
            shutil.copy2(path, target_path)


def ensure_merged_config_links(target_folder, content_root, map_folder):
    target_config = target_folder / "config"

    # Clean up old layout where config may have been linked directly from map folder.
    if target_config.exists() and (target_config.is_symlink() or target_config.is_file()):
        target_config.unlink()

    if not target_config.exists():
        target_config.mkdir(parents=True, exist_ok=True)

    shared_config = content_root / "config"
    if shared_config.exists() and shared_config.is_dir():
        copy_into_target(target_config, shared_config, overwrite=False)

    if map_folder is not None:
        map_config = map_folder / "config"
        if map_config.exists() and map_config.is_dir():
            # Map config overrides shared config file names.
            copy_into_target(target_config, map_config, overwrite=True)


def mission_folder_name(map_folder_name):
    return f"bn_koth_vietnam.{map_folder_name}"


def get_map_folders(content_root):
    map_root = content_root / "maps"
    if not map_root.exists():
        return []

    # Only include map folders that are actually mission-ready.
    mission_ready_maps = []
    for path in sorted([p for p in map_root.iterdir() if p.is_dir()], key=lambda p: p.name.lower()):
        if not (path / "mission.sqm").exists():
            print(f"Skipping map '{path.name}' (missing maps/{path.name}/mission.sqm)")
            continue
        mission_ready_maps.append(path)

    return mission_ready_maps


def main():
    rerun_as_admin_if_needed()

    content_root = Path(__file__).parent
    arma_missions_folder = Path(user_paths.MISSIONS_PATH)

    arma_missions_folder.mkdir(parents=True, exist_ok=True)

    map_folders = get_map_folders(content_root)

    if map_folders:
        mission_targets = [(map_folder.name, mission_folder_name(map_folder.name), map_folder) for map_folder in map_folders]
    else:
        raise ValueError("No mission-ready map folders found under maps/; expected maps/<map_name>/mission.sqm")

    exclude = {
        ".git",
        ".vscode",
        "build_output",
        "__pycache__",
        "maps",
        "config",
        "build.py",
        "setup_dev_environment.py",
        "user_paths.py",
        "user_paths_example.py",
        "docs",
    }

    for map_name, target_name, map_folder in mission_targets:
        target_folder = arma_missions_folder / target_name
        if target_folder.exists():
            print(f"Existing mission folder found, syncing missing links: {target_folder}")
        else:
            print(f"Creating mission folder: {target_folder}")
            target_folder.mkdir(parents=True, exist_ok=True)

        # Clean stale excluded content from older setups.
        remove_excluded_paths(target_folder, {"docs"})

        if map_folder is not None:
            print(f"Symlinking map-specific content ({map_name})...")
            symlink_immediate_children(target_folder, map_folder, exclude={"config"})

        print("Symlinking shared mission content...")
        symlink_immediate_children(target_folder, content_root, exclude=exclude)

        print("Merging config (shared + map)...")
        ensure_merged_config_links(target_folder, content_root, map_folder)

    print("Done.")
    input("Press any key to exit...")


if __name__ == "__main__":
    main()

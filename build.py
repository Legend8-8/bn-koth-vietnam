from pathlib import Path
import os
import shutil
import user_paths


ARMA_MISSIONS_FOLDER = Path(user_paths.MISSIONS_PATH)
MISSION_STEM = getattr(user_paths, "MISSION_STEM", "")
LEGACY_MISSION_FOLDER_NAME = getattr(user_paths, "MISSION_FOLDER_NAME", "")

# We do not need these in release-like output.
BLACKLISTED_FOLDERS = [
    ".git",
    ".vscode",
    "build_output",
    "__pycache__",
    "maps",
    "docs",
]

# Local tooling files that should not ship in mission output.
BLACKLISTED_FILES = {
    "build.py",
    "setup_dev_environment.py",
    "user_paths.py",
    "user_paths_example.py",
}


def ignore_unreadable_entries(base_dir, names):
    """Skip unreadable children so copytree does not fail on protected paths."""
    ignored = []
    for name in names:
        child_path = Path(base_dir) / name
        if not os.access(child_path, os.R_OK):
            print(f"  Skipping unreadable path: {child_path}")
            ignored.append(name)
    return ignored


def set_permissions_if_delete_fails(func, path, exc_info):
    """Allow cleanup of read-only files during rmtree."""
    import stat

    if not os.access(path, os.W_OK):
        os.chmod(path, stat.S_IWUSR)
        func(path)
    else:
        raise


def is_file_missing_copy_error(error_tuple):
    """True when copytree reported a non-fatal source file missing error."""
    _src_path, _dst_path, err_msg = error_tuple
    return "WinError 2" in err_msg or "No such file or directory" in err_msg


def copy_repo_fallback(repo_root, target_folder):
    """Copy missing files from repo in case live mission links are stale."""
    for item in repo_root.iterdir():
        if item.name in BLACKLISTED_FOLDERS or item.name in BLACKLISTED_FILES:
            continue

        target_item = target_folder / item.name
        if target_item.exists():
            continue

        if item.is_dir():
            print(f"  Adding folder from repo: {item.name}")
            shutil.copytree(item, target_item)
        else:
            print(f"  Adding file from repo: {item.name}")
            shutil.copy2(item, target_item)


def mission_folder_name(map_folder_name):
    if MISSION_STEM:
        return f"{MISSION_STEM}.{map_folder_name}"
    if LEGACY_MISSION_FOLDER_NAME:
        return LEGACY_MISSION_FOLDER_NAME
    raise ValueError("Set MISSION_STEM or MISSION_FOLDER_NAME in user_paths.py")


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


def copy_missing_from(source_root, target_folder):
    for item in source_root.iterdir():
        if item.name in BLACKLISTED_FOLDERS or item.name in BLACKLISTED_FILES:
            continue

        target_item = target_folder / item.name
        if target_item.exists():
            continue

        if item.is_dir():
            print(f"  Adding folder from source: {item.name}")
            shutil.copytree(item, target_item)
        else:
            print(f"  Adding file from source: {item.name}")
            shutil.copy2(item, target_item)


def replace_path(path):
    if not path.exists():
        return

    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.is_dir():
        shutil.rmtree(path, onerror=set_permissions_if_delete_fails)


def copy_into_target(target, source, overwrite=False):
    for item in source.iterdir():
        target_item = target / item.name

        if target_item.exists():
            if not overwrite:
                continue
            replace_path(target_item)

        if item.is_dir():
            shutil.copytree(item, target_item)
        else:
            shutil.copy2(item, target_item)


def merge_config_into_output(content_root, map_folder, target_folder):
    target_config = target_folder / "config"

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


def trim_output(target_folder):
    for folder_name in BLACKLISTED_FOLDERS:
        path_to_delete = target_folder / folder_name
        if path_to_delete.exists() and path_to_delete.is_dir():
            print(f"Removing {path_to_delete}")
            shutil.rmtree(path_to_delete, onerror=set_permissions_if_delete_fails)

    for file_name in BLACKLISTED_FILES:
        path_to_delete = target_folder / file_name
        if path_to_delete.exists() and path_to_delete.is_file():
            print(f"Removing {path_to_delete}")
            path_to_delete.unlink()


def main():
    content_root = Path(__file__).parent
    output_folder = content_root / "build_output"
    output_folder.mkdir(exist_ok=True)

    map_folders = get_map_folders(content_root)

    if map_folders:
        mission_targets = [(map_folder.name, mission_folder_name(map_folder.name), map_folder) for map_folder in map_folders]
    else:
        if not LEGACY_MISSION_FOLDER_NAME:
            raise ValueError("No maps folder found and MISSION_FOLDER_NAME is not set in user_paths.py")
        mission_targets = [("", LEGACY_MISSION_FOLDER_NAME, None)]

    for map_name, mission_name, map_folder in mission_targets:
        source_folder = ARMA_MISSIONS_FOLDER / mission_name
        target_folder = output_folder / mission_name

        if not source_folder.exists():
            print(
                "Skipping mission build (live mission folder missing): "
                f"{source_folder}. Run setup_dev_environment.py first."
            )
            continue

        if target_folder.exists():
            print(f"Removing existing folder: {target_folder}")
            shutil.rmtree(target_folder, onerror=set_permissions_if_delete_fails)

        print(f"Copying mission to {target_folder.name}")
        try:
            shutil.copytree(source_folder, target_folder, ignore=ignore_unreadable_entries)
        except shutil.Error as copy_error:
            error_items = copy_error.args[0]
            unexpected_errors = [item for item in error_items if not is_file_missing_copy_error(item)]
            if unexpected_errors:
                print("  Warning: partial copy from live mission source; continuing with repo/map fallback.")
                for src_path, dst_path, err_msg in unexpected_errors:
                    print(f"    {src_path} -> {dst_path}: {err_msg}")
            else:
                print("  Warning: source had missing linked files; continuing with repo/map fallback.")
            target_folder.mkdir(exist_ok=True)
        except OSError as os_error:
            print(f"  Warning: could not fully copy live mission source: {os_error}")
            target_folder.mkdir(exist_ok=True)

        if map_folder is not None:
            copy_missing_from(map_folder, target_folder)

        copy_repo_fallback(content_root, target_folder)

        merge_config_into_output(content_root, map_folder, target_folder)

        print("Trimming output...")
        trim_output(target_folder)

        if map_name:
            print(f"Build complete ({map_name}): {target_folder}")
        else:
            print(f"Build complete: {target_folder}")

    if os.environ.get("KOTH_BUILD_NO_PAUSE", "0") not in {"1", "true", "True"}:
        input("Press any key to exit...")


if __name__ == "__main__":
    main()

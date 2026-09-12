"""
Author: Legend

One-time importer for the frozen official S.O.G. Prairie Fire wearable table.
It is intentionally separate from the recurring weapon catalogue pipeline.
"""

from __future__ import annotations

import argparse
from collections import Counter
from pathlib import Path
import sys

from .catalogue import CatalogueError, WEARABLE_SOURCE_PAGE, fetch_raw_page, parse_wearable_page
from .scrape import write_output
from .wearables import (
    build_backpack_inventory,
    build_curated_metadata,
    build_wearable_inventory,
    render_inventory_csv,
    render_metadata_hpp,
    render_review_csv,
)


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_OUTPUT = REPO_ROOT / "data" / "wearable_inventory.csv"
DEFAULT_REVIEW_OUTPUT = REPO_ROOT / "reports" / "generated" / "wearable_inventory_review.csv"
DEFAULT_METADATA_OUTPUT = REPO_ROOT / "config" / "arsenal" / "wearables.hpp"
DEFAULT_BACKPACK_SOURCE = REPO_ROOT / "data" / "source" / "sog_bag_base_classes.txt"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Import the frozen official S.O.G. wearable inventory once.")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--review-output", type=Path, default=DEFAULT_REVIEW_OUTPUT)
    parser.add_argument("--metadata-output", type=Path, default=DEFAULT_METADATA_OUTPUT)
    parser.add_argument("--backpack-source", type=Path, default=DEFAULT_BACKPACK_SOURCE)
    parser.add_argument("--timeout", type=int, default=20)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        raw = fetch_raw_page(WEARABLE_SOURCE_PAGE["url"], args.timeout)
        rows = parse_wearable_page(raw)
        inventory, review = build_wearable_inventory(rows, WEARABLE_SOURCE_PAGE["url"])
        backpack_classes = args.backpack_source.read_text(encoding="utf-8-sig").splitlines()
        backpack_inventory, backpack_review = build_backpack_inventory(backpack_classes)
        inventory.extend(backpack_inventory)
        inventory.sort(key=lambda entry: (entry["category"], entry["classname"].lower()))
        review.extend(backpack_review)
        review.sort(key=lambda entry: (entry["category"], entry["classname"].lower()))
        curated = build_curated_metadata(inventory)
        write_output(args.output, render_inventory_csv(inventory))
        write_output(args.review_output, render_review_csv(review))
        write_output(args.metadata_output, render_metadata_hpp(curated))
        counts = Counter(entry["category"] for entry in inventory)
        print(f"CSV: {args.output}")
        print(f"REVIEW: {args.review_output}")
        print(f"METADATA: {args.metadata_output}")
        print("COUNTS: " + " ".join(f"{name}={counts[name]}" for name in sorted(counts)))
        print(f"REVIEW_COUNT: {len(review)}")
        curated_counts = Counter(entry["category"] for entry in curated)
        print("CURATED: " + " ".join(f"{name}={curated_counts[name]}" for name in sorted(curated_counts)))
        return 0
    except CatalogueError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    except OSError as exc:
        print(f"ERROR: failed to write output: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

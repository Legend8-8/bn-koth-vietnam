from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import sys

from .catalogue import CatalogueError, SOURCE_PAGES, fetch_all_pages, load_overrides, parse_all_pages
from .classify import build_catalogue
from .validate import render_progression_csv, render_report, validate_catalogue


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_JSON_OUTPUT = REPO_ROOT / "data" / "generated" / "sog_catalogue.json"
DEFAULT_REPORT_OUTPUT = REPO_ROOT / "reports" / "generated" / "sog_catalogue_report.txt"
DEFAULT_PROGRESS_OUTPUT = REPO_ROOT / "reports" / "generated" / "progression_todo.csv"
DEFAULT_OVERRIDES = Path(__file__).with_name("overrides.json")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Extract factual BASE S.O.G. Prairie Fire equipment data into JSON and reports.")
    parser.add_argument("--json-out", type=Path, default=DEFAULT_JSON_OUTPUT)
    parser.add_argument("--report-out", type=Path, default=DEFAULT_REPORT_OUTPUT)
    parser.add_argument("--progress-out", type=Path, default=DEFAULT_PROGRESS_OUTPUT)
    parser.add_argument("--overrides", type=Path, default=DEFAULT_OVERRIDES)
    parser.add_argument("--timeout", type=int, default=20)
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    try:
        raw_pages = fetch_all_pages(args.timeout)
        overrides = load_overrides(args.overrides)
        parsed_pages, row_counts = parse_all_pages(raw_pages)
        catalogue, summary = build_catalogue(parsed_pages, overrides)
        warnings = validate_catalogue(catalogue)
        catalogue["sources"] = [
            {"name": name, "url": info["url"], "rowCount": row_counts[name]}
            for name, info in SOURCE_PAGES.items()
        ]

        json_text = render_catalogue_json(catalogue)
        report_text = render_report(catalogue, warnings)
        progress_text = render_progression_csv(catalogue)

        write_output(args.json_out, json_text)
        write_output(args.report_out, report_text)
        write_output(args.progress_out, progress_text)

        print(f"JSON: {args.json_out}")
        print(f"REPORT: {args.report_out}")
        print(f"CSV: {args.progress_out}")
        print(f"SHA256: {hashlib.sha256(json_text.encode('utf-8')).hexdigest()}")
        print(
            "COUNTS: "
            f"weapons={summary['filtering']['accepted']['weapons']} "
            f"magazines={summary['filtering']['accepted']['magazines']} "
            f"items={summary['filtering']['accepted']['items']}"
        )
        return 0
    except CatalogueError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    except OSError as exc:
        print(f"ERROR: failed to write output: {exc}", file=sys.stderr)
        return 1


def render_catalogue_json(catalogue: dict[str, object]) -> str:
    return json.dumps(catalogue, indent=2, sort_keys=False) + "\n"


def write_output(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


if __name__ == "__main__":
    raise SystemExit(main())
from __future__ import annotations

from collections import Counter
from html import unescape
import json
from pathlib import Path
import re
from typing import Any
from urllib.error import URLError
from urllib.request import Request, urlopen


SOURCE_PAGES = {
    "weapons": {
        "url": "https://wiki.sogpf.com/index.php?title=CfgWeapons_Weapons&action=raw",
        "headers": [
            "Ver.",
            "Preview",
            "Class",
            "Name",
            "Inventory description",
            "Magazines",
            "Accessories",
            "Used by",
        ],
    },
    "items": {
        "url": "https://wiki.sogpf.com/index.php?title=CfgWeapons_Items&action=raw",
        "headers": [
            "Ver.",
            "Preview",
            "Class",
            "Name",
            "Inventory description",
            "Magazines",
            "Used by",
        ],
    },
    "magazines": {
        "url": "https://wiki.sogpf.com/index.php?title=CfgMagazines&action=raw",
        "headers": [
            "Ver.",
            "Class",
            "Name",
            "Inventory description",
            "Ammo",
            "Used by",
        ],
    },
}

WEARABLE_SOURCE_PAGE = {
    "name": "equipment",
    "url": "https://wiki.sogpf.com/index.php?title=CfgWeapons_Equipment&action=raw",
    "headers": [
        "Ver.",
        "Preview",
        "Class",
        "Name",
        "Inventory description",
        "Magazines",
        "Used by",
    ],
}

USER_AGENT = "bn-koth-vietnam-sog-catalogue/1.0"

LINK_PATTERN = re.compile(r"\[\[(?:[^\]|]+\|)?([^\]]+)\]\]")
CLASS_PATTERN = re.compile(r"'''([^']+)'''")
TAG_PATTERN = re.compile(r"<[^>]+>")


class CatalogueError(RuntimeError):
    """Raised when the source wiki cannot be parsed into a valid catalogue."""


def fetch_raw_page(url: str, timeout_seconds: int) -> str:
    request = Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urlopen(request, timeout=timeout_seconds) as response:
            return response.read().decode("utf-8", errors="replace")
    except URLError as exc:
        raise CatalogueError(f"Failed to retrieve required source page: {url}: {exc}") from exc


def fetch_all_pages(timeout_seconds: int) -> dict[str, str]:
    return {
        page_name: fetch_raw_page(page_info["url"], timeout_seconds)
        for page_name, page_info in SOURCE_PAGES.items()
    }


def load_overrides(path: Path) -> dict[str, Any]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise CatalogueError(f"Overrides file is missing: {path}")
    except json.JSONDecodeError as exc:
        raise CatalogueError(f"Overrides file is not valid JSON: {path}: {exc}") from exc


def parse_all_pages(raw_pages: dict[str, str]) -> tuple[dict[str, list[dict[str, Any]]], dict[str, int]]:
    parsed: dict[str, list[dict[str, Any]]] = {}
    counts: dict[str, int] = {}
    for page_name, text in raw_pages.items():
        headers, rows = parse_main_table(text)
        required_headers = SOURCE_PAGES[page_name]["headers"]
        normalized_headers = [normalize_header(header) for header in headers]
        if normalized_headers[: len(required_headers)] != required_headers:
            raise CatalogueError(
                f"Required identifying columns missing on {page_name}: expected {required_headers}, got {normalized_headers}"
            )
        parsed_rows = [map_row(page_name, row, normalized_headers) for row in rows]
        parsed[page_name] = parsed_rows
        counts[page_name] = len(parsed_rows)
    return parsed, counts


def parse_wearable_page(text: str) -> list[dict[str, Any]]:
    """Parse the frozen official CfgWeapons equipment table for one-time curation."""
    headers, rows = parse_main_table(text)
    normalized_headers = [normalize_header(header) for header in headers]
    required_headers = WEARABLE_SOURCE_PAGE["headers"]
    if normalized_headers[: len(required_headers)] != required_headers:
        raise CatalogueError(
            f"Required identifying columns missing on equipment: expected {required_headers}, got {normalized_headers}"
        )
    return [map_row("equipment", row, normalized_headers) for row in rows]


def parse_main_table(text: str) -> tuple[list[str], list[list[str]]]:
    lines = text.splitlines()
    depth = 0
    in_main_table = False
    headers: list[str] = []
    rows: list[list[str]] = []
    current_row: list[str] = []

    for raw_line in lines:
        line = raw_line.rstrip("\n")
        stripped = line.strip()

        if stripped.startswith("{|"):
            depth += 1
            if depth == 1 and "wikitable sortable" in stripped:
                in_main_table = True
            if in_main_table and current_row:
                current_row.append(line)
            continue

        if stripped == "|}":
            if in_main_table and current_row:
                current_row.append(line)
            if depth == 1 and in_main_table:
                if current_row:
                    rows.append(current_row)
                    current_row = []
                in_main_table = False
            depth -= 1
            continue

        if not in_main_table:
            continue

        if depth == 1 and stripped.startswith("!"):
            headers.append(stripped)
            continue

        if depth == 1 and stripped == "|-":
            if current_row:
                rows.append(current_row)
            current_row = []
            continue

        if current_row or (depth == 1 and stripped.startswith("|")):
            current_row.append(line)

    if not headers:
        raise CatalogueError("Expected top-level sortable table was not found in source page.")

    return headers, rows


def normalize_header(header_line: str) -> str:
    header = header_line.lstrip("!").replace("<br />", " ").strip()
    return normalize_markup_text(header)


def map_row(page_name: str, row_lines: list[str], headers: list[str]) -> dict[str, Any]:
    cells = split_top_level_cells(row_lines)
    if len(cells) != len(headers):
        raise CatalogueError(
            f"Malformed source record on {page_name}: expected {len(headers)} cells, got {len(cells)}"
        )

    row = {
        "sourcePage": page_name,
        "raw": {header: cells[index] for index, header in enumerate(headers)},
    }

    if page_name == "weapons":
        return {
            **row,
            "version": normalize_markup_text(cells[0]),
            "class": parse_class_cell(cells[2]),
            "displayName": normalize_markup_text(cells[3]),
            "description": normalize_markup_text(cells[4]),
            "magazines": parse_links(cells[5]),
            "accessories": parse_links(cells[6]),
            "usedBy": parse_links(cells[7]),
        }
    if page_name == "items":
        return {
            **row,
            "version": normalize_markup_text(cells[0]),
            "class": parse_class_cell(cells[2]),
            "displayName": normalize_markup_text(cells[3]),
            "description": normalize_markup_text(cells[4]),
            "magazines": parse_links(cells[5]),
            "usedBy": parse_links(cells[6]),
        }
    if page_name == "equipment":
        return {
            **row,
            "version": normalize_markup_text(cells[0]),
            "class": parse_class_cell(cells[2]),
            "displayName": normalize_markup_text(cells[3]),
            "description": normalize_markup_text(cells[4]),
            "magazines": parse_links(cells[5]),
            "usedBy": parse_links(cells[6]),
        }
    if page_name == "magazines":
        return {
            **row,
            "version": normalize_markup_text(cells[0]),
            "class": parse_class_cell(cells[1]),
            "displayName": normalize_markup_text(cells[2]),
            "description": normalize_markup_text(cells[3]),
            "ammoClass": normalize_markup_text(cells[4]),
            "usedBy": parse_links(cells[5]),
        }
    raise CatalogueError(f"Unsupported source page mapping: {page_name}")


def split_top_level_cells(row_lines: list[str]) -> list[str]:
    cells: list[str] = []
    current: list[str] = []
    depth = 0

    for line in row_lines:
        stripped = line.strip()

        if stripped.startswith("{|"):
            depth += 1
            current.append(line)
            continue

        if stripped == "|}":
            current.append(line)
            depth = max(0, depth - 1)
            continue

        if depth == 0 and line.startswith("|"):
            if current:
                cells.append("\n".join(current).strip())
            current = [line[1:].lstrip()]
            continue

        current.append(line)

    if current:
        cells.append("\n".join(current).strip())

    return cells


def parse_class_cell(cell: str) -> str:
    match = CLASS_PATTERN.search(cell)
    if match:
        return normalize_markup_text(match.group(1))
    return normalize_markup_text(cell)


def parse_links(cell: str) -> list[str]:
    links = [normalize_markup_text(match.group(1)) for match in LINK_PATTERN.finditer(cell)]
    return [link for link in links if link]


def normalize_markup_text(value: str) -> str:
    text = value.replace("<br />", "\n").replace("'''", "").replace("''", "")
    text = TAG_PATTERN.sub("", text)
    text = unescape(text)
    text = text.replace("&nbsp;", " ")
    lines = [line.strip(" :") for line in text.splitlines()]
    joined = " ".join(line for line in lines if line)
    joined = re.sub(r"\s+", " ", joined)
    if joined == "'":
        return ""
    return joined.strip()


def sort_unique(values: list[str]) -> list[str]:
    return sorted({value for value in values if value})


def increment_reason(counter: Counter[str], reason: str) -> None:
    counter[reason] += 1

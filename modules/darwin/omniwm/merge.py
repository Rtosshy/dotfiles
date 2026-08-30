#!/usr/bin/env python3
"""Apply OmniWM overrides without re-serializing the canonical base TOML."""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
import tomllib
from dataclasses import dataclass
from pathlib import Path
from typing import Any


class MergeError(Exception):
    """An input or invariant violation that must fail the build."""


@dataclass(frozen=True)
class Assignment:
    key: str
    literal: str
    value_start: int
    value_end: int


TABLE_RE = re.compile(
    r"^\s*(?:\[\[(?P<array>[^\]]+)\]\]|\[(?P<table>[^\]]+)\])\s*(?:#.*)?$"
)
ASSIGNMENT_RE = re.compile(
    r"^\s*(?P<key>(?:[A-Za-z0-9_-]+|\"(?:\\.|[^\"])*\"|\'(?:[^\']*)\')"
    r"(?:\s*\.\s*(?:[A-Za-z0-9_-]+|\"(?:\\.|[^\"])*\"|\'(?:[^\']*)\'))*)"
    r"\s*=\s*(?P<value>.*)$"
)

EXPECTED_SETTINGS = 8
EXPECTED_HOTKEYS = 67
EXPECTED_CHANGED_LINES = EXPECTED_SETTINGS + EXPECTED_HOTKEYS


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", required=True, type=Path)
    parser.add_argument("--overrides", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    return parser.parse_args()


def read_utf8(path: Path) -> str:
    try:
        return path.read_bytes().decode("utf-8")
    except (OSError, UnicodeDecodeError) as exc:
        raise MergeError(f"cannot read {path}: {exc}") from exc


def parse_toml(text: str, source: Path) -> dict[str, Any]:
    try:
        value = tomllib.loads(text)
    except tomllib.TOMLDecodeError as exc:
        raise MergeError(f"{source} is not valid TOML: {exc}") from exc
    if not isinstance(value, dict):
        raise MergeError(f"{source} must decode to a TOML table")
    return value


def normalize_key(key: str) -> str:
    parts = []
    for part in key.split("."):
        part = part.strip()
        if len(part) >= 2 and part[0] == part[-1] and part[0] in "\"'":
            part = part[1:-1]
        parts.append(part)
    return ".".join(parts)


def parse_assignment(line: str) -> Assignment | None:
    body = line.rstrip("\r\n")
    match = ASSIGNMENT_RE.match(body)
    if match is None:
        return None

    value_start = match.start("value")
    value_text = match.group("value")
    comment_start = find_comment_start(value_text)
    literal_text = value_text if comment_start is None else value_text[:comment_start]
    literal = literal_text.strip()
    if not literal:
        return None

    leading = len(literal_text) - len(literal_text.lstrip())
    trailing = len(literal_text.rstrip())
    return Assignment(
        key=normalize_key(match.group("key")),
        literal=literal,
        value_start=value_start + leading,
        value_end=value_start + trailing,
    )


def find_comment_start(value: str) -> int | None:
    """Find a TOML comment marker outside basic or literal strings."""
    quote: str | None = None
    escaped = False
    index = 0
    while index < len(value):
        char = value[index]
        if quote == '"':
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                quote = None
        elif quote == "'":
            if char == "'":
                quote = None
        elif char in "\"'":
            quote = char
        elif char == "#":
            return index
        index += 1
    return None


def table_header(line: str) -> tuple[str, bool] | None:
    body = line.rstrip("\r\n")
    match = TABLE_RE.match(body)
    if match is None:
        return None
    if match.group("array") is not None:
        return normalize_key(match.group("array")), True
    return normalize_key(match.group("table")), False


def flatten_settings(value: Any, prefix: str = "") -> dict[str, Any]:
    if not isinstance(value, dict):
        if not prefix:
            raise MergeError("overrides.settings must be a non-empty attrset")
        return {prefix: value}

    flattened: dict[str, Any] = {}
    for key, child in value.items():
        if not isinstance(key, str) or not key:
            raise MergeError("overrides.settings keys must be non-empty strings")
        path = f"{prefix}.{key}" if prefix else key
        child_flattened = flatten_settings(child, path)
        for child_path, child_value in child_flattened.items():
            if child_path in flattened:
                raise MergeError(f"duplicate flattened settings path: {child_path}")
            flattened[child_path] = child_value
    if not value and prefix:
        raise MergeError(f"overrides.settings contains empty attrset at {prefix}")
    return flattened


def load_overrides(path: Path) -> tuple[dict[str, Any], dict[str, str]]:
    text = read_utf8(path)
    try:
        decoded = json.loads(text)
    except json.JSONDecodeError as exc:
        raise MergeError(f"{path} is not valid JSON: {exc}") from exc
    if not isinstance(decoded, dict):
        raise MergeError("overrides JSON must be an object")
    unexpected = set(decoded) - {"settings", "hotkeys"}
    if unexpected:
        names = ", ".join(sorted(unexpected))
        raise MergeError(f"unknown top-level override fields: {names}")
    if "settings" not in decoded or "hotkeys" not in decoded:
        raise MergeError("overrides JSON must contain settings and hotkeys")

    settings = flatten_settings(decoded["settings"])
    hotkeys = decoded["hotkeys"]
    if not isinstance(hotkeys, dict):
        raise MergeError("overrides.hotkeys must be a flat attrset")
    if any(not isinstance(key, str) or not key for key in hotkeys):
        raise MergeError("overrides.hotkeys keys must be non-empty strings")
    if any(not isinstance(value, str) for value in hotkeys.values()):
        raise MergeError("overrides.hotkeys values must be strings")
    return settings, hotkeys


def parse_literal(literal: str) -> Any:
    try:
        return tomllib.loads(f"value = {literal}\n")["value"]
    except (tomllib.TOMLDecodeError, KeyError) as exc:
        raise MergeError(f"invalid TOML literal: {literal!r}") from exc


def literal_kind(literal: str) -> str:
    value = parse_literal(literal)
    if isinstance(value, bool):
        return "bool"
    if isinstance(value, int):
        return "int"
    if isinstance(value, float):
        return "float"
    if isinstance(value, str):
        return "string"
    raise MergeError(
        f"unsupported base literal for override (only scalar values are supported): {literal!r}"
    )


def compatible_value(kind: str, value: Any) -> bool:
    if kind == "bool":
        return isinstance(value, bool)
    if kind == "int":
        return isinstance(value, int) and not isinstance(value, bool)
    if kind == "float":
        return (
            isinstance(value, (int, float))
            and not isinstance(value, bool)
            and math.isfinite(float(value))
        )
    if kind == "string":
        return isinstance(value, str)
    return False


def format_value(kind: str, value: Any) -> str:
    if not compatible_value(kind, value):
        raise MergeError(f"override value {value!r} cannot be represented as TOML {kind}")
    if kind == "bool":
        return "true" if value else "false"
    if kind == "int":
        return str(value)
    if kind == "float":
        number = float(value)
        if number.is_integer():
            return f"{number:.1f}"
        return repr(number)
    if kind == "string":
        return json.dumps(value, ensure_ascii=False)
    raise MergeError(f"unsupported TOML value kind: {kind}")


def replace_assignment(line: str, assignment: Assignment, value: str) -> str:
    newline = ""
    if line.endswith("\r\n"):
        newline = "\r\n"
    elif line.endswith("\n") or line.endswith("\r"):
        newline = line[-1]
    body = line[: len(line) - len(newline)] if newline else line
    return body[: assignment.value_start] + value + body[assignment.value_end :] + newline


def block_assignments(lines: list[str], start: int, end: int) -> dict[str, list[tuple[int, Assignment]]]:
    found: dict[str, list[tuple[int, Assignment]]] = {}
    for index in range(start + 1, end):
        assignment = parse_assignment(lines[index])
        if assignment is not None:
            found.setdefault(assignment.key, []).append((index, assignment))
    return found


def block_string_value(line: str, assignment: Assignment, block_name: str) -> str:
    value = parse_literal(assignment.literal)
    if not isinstance(value, str):
        raise MergeError(f"{block_name} field {assignment.key} must be a string")
    return value


def process_hotkey_block(
    lines: list[str],
    start: int,
    end: int,
    overrides: dict[str, str],
    match_counts: dict[str, int],
) -> tuple[str, str]:
    assignments = block_assignments(lines, start, end)
    id_entries = assignments.get("id", [])
    binding_entries = assignments.get("binding", [])
    if len(id_entries) != 1:
        raise MergeError(f"hotkeys block at line {start + 1} must contain exactly one id")
    if len(binding_entries) != 1:
        raise MergeError(f"hotkeys block at line {start + 1} must contain exactly one binding")

    id_index, id_assignment = id_entries[0]
    _, binding_assignment = binding_entries[0]
    hotkey_id = block_string_value(lines[id_index], id_assignment, "hotkeys")
    binding = block_string_value(lines[binding_entries[0][0]], binding_assignment, "hotkeys")
    if hotkey_id in overrides:
        match_counts[hotkey_id] = match_counts.get(hotkey_id, 0) + 1
        kind = literal_kind(binding_assignment.literal)
        replacement = format_value(kind, overrides[hotkey_id])
        lines[binding_entries[0][0]] = replace_assignment(
            lines[binding_entries[0][0]], binding_assignment, replacement
        )
        binding = overrides[hotkey_id]
    return hotkey_id, binding


def flattened_key_set(value: Any, prefix: str = "") -> set[str]:
    keys: set[str] = set()
    if isinstance(value, dict):
        if prefix and not value:
            keys.add(f"{prefix}{{}}")
        for key, child in value.items():
            path = f"{prefix}.{key}" if prefix else str(key)
            keys.add(path)
            keys.update(flattened_key_set(child, path))
    elif isinstance(value, list):
        if not value:
            keys.add(f"{prefix}[]")
        for index, child in enumerate(value):
            path = f"{prefix}[{index}]"
            keys.add(path)
            keys.update(flattened_key_set(child, path))
    elif prefix:
        keys.add(prefix)
    return keys


def get_dotted_value(data: dict[str, Any], path: str) -> Any:
    current: Any = data
    for component in path.split("."):
        if not isinstance(current, dict) or component not in current:
            raise MergeError(f"output is missing override path {path}")
        current = current[component]
    return current


def assert_expected_value(kind: str, actual: Any, expected: Any, path: str) -> None:
    if kind == "float":
        ok = isinstance(actual, float) and actual == float(expected)
    elif kind == "int":
        ok = isinstance(actual, int) and not isinstance(actual, bool) and actual == expected
    elif kind == "bool":
        ok = isinstance(actual, bool) and actual is expected
    elif kind == "string":
        ok = isinstance(actual, str) and actual == expected
    else:
        ok = False
    if not ok:
        raise MergeError(f"override {path} did not produce the requested value")


def validate_output(
    base_data: dict[str, Any],
    output_data: dict[str, Any],
    base_lines: list[str],
    output_lines: list[str],
    settings: dict[str, Any],
    setting_kinds: dict[str, str],
    hotkeys: dict[str, str],
    base_hotkey_ids: list[str],
    hotkey_blocks: list[str],
    hotkey_match_counts: dict[str, int],
    setting_match_counts: dict[str, int],
) -> None:
    for path, count in setting_match_counts.items():
        if count != 1:
            raise MergeError(f"settings override {path} matched {count} lines; expected exactly one")
    if len(setting_match_counts) != len(settings):
        missing = sorted(set(settings) - set(setting_match_counts))
        raise MergeError(f"settings overrides did not match: {', '.join(missing)}")
    for path, value in settings.items():
        assert_expected_value(setting_kinds[path], get_dotted_value(output_data, path), value, path)

    for hotkey_id in hotkeys:
        if hotkey_match_counts.get(hotkey_id, 0) != 1:
            raise MergeError(
                f"hotkey override {hotkey_id} matched {hotkey_match_counts.get(hotkey_id, 0)} blocks; "
                "expected exactly one"
            )

    if len(output_lines) != len(base_lines):
        raise MergeError(
            f"output has {len(output_lines)} lines, base has {len(base_lines)}"
        )
    # 上限のみを検査する。各オーバーライドが「ちょうど1行/1ブロックにマッチしたか」は
    # 上の setting_match_counts / hotkey_match_counts で既に保証済み。
    # 意図した値が base の既定値とたまたま一致する場合(focusMonitorNext など)は
    # 行が変化しないため、差分行数はオーバーライド数を下回りうる。上回るのは異常。
    changed_lines = sum(before != after for before, after in zip(base_lines, output_lines))
    if changed_lines > EXPECTED_CHANGED_LINES:
        raise MergeError(
            f"output changed {changed_lines} lines; expected at most {EXPECTED_CHANGED_LINES}"
        )

    base_keys = flattened_key_set(base_data)
    output_keys = flattened_key_set(output_data)
    if base_keys != output_keys:
        missing = sorted(base_keys - output_keys)
        added = sorted(output_keys - base_keys)
        raise MergeError(f"TOML key set changed (missing={missing}, added={added})")

    output_hotkeys = output_data.get("hotkeys")
    if not isinstance(output_hotkeys, list):
        raise MergeError("output hotkeys is not an array of tables")
    output_ids = [item.get("id") for item in output_hotkeys if isinstance(item, dict)]
    if len(output_hotkeys) != 169:
        raise MergeError(f"output hotkeys has {len(output_hotkeys)} blocks; expected 169")
    if len(output_ids) != len(output_hotkeys) or any(not isinstance(value, str) for value in output_ids):
        raise MergeError("output hotkeys contains a block without a string id")
    if len(set(output_ids)) != len(output_ids):
        raise MergeError("output hotkeys contains duplicate ids")
    if set(output_ids) != set(base_hotkey_ids):
        raise MergeError("output hotkey ID set differs from base")
    if len(hotkey_blocks) != 169:
        raise MergeError(f"base hotkeys has {len(hotkey_blocks)} blocks; expected 169")


def merge(base_path: Path, overrides_path: Path, out_path: Path) -> None:
    base_text = read_utf8(base_path)
    base_lines = base_text.splitlines(keepends=True)
    base_data = parse_toml(base_text, base_path)
    settings, hotkeys = load_overrides(overrides_path)
    if len(settings) != EXPECTED_SETTINGS:
        raise MergeError(
            f"overrides has {len(settings)} settings; expected {EXPECTED_SETTINGS}"
        )
    if len(hotkeys) != EXPECTED_HOTKEYS:
        raise MergeError(
            f"overrides has {len(hotkeys)} hotkeys; expected {EXPECTED_HOTKEYS}"
        )

    base_hotkey_data = base_data.get("hotkeys")
    if not isinstance(base_hotkey_data, list):
        raise MergeError("base does not contain a hotkeys array")
    base_hotkey_ids = []
    for item in base_hotkey_data:
        if not isinstance(item, dict) or not isinstance(item.get("id"), str):
            raise MergeError("base hotkeys contains a block without a string id")
        base_hotkey_ids.append(item["id"])
    if len(base_hotkey_ids) != 169:
        raise MergeError(f"base hotkeys has {len(base_hotkey_ids)} blocks; expected 169")
    if len(set(base_hotkey_ids)) != len(base_hotkey_ids):
        raise MergeError("base hotkeys contains duplicate ids")

    setting_match_counts = {path: 0 for path in settings}
    setting_kinds: dict[str, str] = {}
    hotkey_match_counts: dict[str, int] = {}
    output_lines = list(base_lines)
    current_section = ""
    hotkey_start: int | None = None
    hotkey_block_ids: list[str] = []

    def finish_hotkey(end: int) -> None:
        nonlocal hotkey_start
        if hotkey_start is None:
            return
        hotkey_id, _ = process_hotkey_block(
            output_lines, hotkey_start, end, hotkeys, hotkey_match_counts
        )
        hotkey_block_ids.append(hotkey_id)
        hotkey_start = None

    for index, line in enumerate(output_lines):
        header = table_header(line)
        if header is not None:
            finish_hotkey(index)
            current_section, is_array = header
            if is_array and current_section == "hotkeys":
                hotkey_start = index
            continue

        assignment = parse_assignment(line)
        if assignment is None:
            continue
        full_path = f"{current_section}.{assignment.key}" if current_section else assignment.key
        if full_path not in settings:
            continue
        setting_match_counts[full_path] += 1
        if full_path in setting_kinds:
            raise MergeError(f"settings override {full_path} matched more than one line")
        kind = literal_kind(assignment.literal)
        setting_kinds[full_path] = kind
        replacement = format_value(kind, settings[full_path])
        output_lines[index] = replace_assignment(output_lines[index], assignment, replacement)

    finish_hotkey(len(output_lines))

    if set(hotkey_block_ids) != set(base_hotkey_ids):
        raise MergeError("parsed hotkey block IDs differ from base")
    if len(hotkey_block_ids) != len(set(hotkey_block_ids)):
        raise MergeError("parsed base hotkey blocks contain duplicate ids")
    for path in settings:
        if setting_match_counts[path] != 1:
            raise MergeError(
                f"settings override {path} matched {setting_match_counts[path]} lines; expected exactly one"
            )
        if path not in setting_kinds:
            raise MergeError(f"settings override {path} has no base literal")

    output_text = "".join(output_lines)
    output_data = parse_toml(output_text, out_path)
    validate_output(
        base_data,
        output_data,
        base_lines,
        output_lines,
        settings,
        setting_kinds,
        hotkeys,
        base_hotkey_ids,
        hotkey_block_ids,
        hotkey_match_counts,
        setting_match_counts,
    )
    try:
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_bytes(output_text.encode("utf-8"))
    except OSError as exc:
        raise MergeError(f"cannot write {out_path}: {exc}") from exc


def main() -> int:
    args = parse_args()
    try:
        merge(args.base, args.overrides, args.out)
    except (MergeError, OSError, ValueError) as exc:
        print(f"merge.py: error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

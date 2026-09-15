"""
find_unused_strings.py
========================
Scans lib/core/constants/app_strings.dart for every `static const String X = ...;`
entry, then searches all of lib/ for `AppStrings.X` usage.

Any entry with zero usages is reported in the console. You're then asked
whether to remove some/all/none of them from app_strings.dart.

Usage:
    python find_unused_strings.py
    python find_unused_strings.py --dry-run   # report only, never writes
"""

import os
import re
import sys

ROOT = os.getcwd()
LIB_PATH = os.path.join(ROOT, "lib")
APP_STRINGS_PATH = os.path.join(LIB_PATH, "core", "constants", "app_strings.dart")

DECL_RE = re.compile(r"static\s+const\s+String\s+(\w+)\s*=")


# ============================================================
# Step 1 — parse declarations from app_strings.dart (line-based, comment-aware)
# ============================================================

class Declaration:
    def __init__(self, name, start_line, end_line, preview):
        self.name = name
        self.start_line = start_line  # 0-indexed, inclusive (includes leading /// comments)
        self.end_line = end_line      # 0-indexed, inclusive
        self.preview = preview


def parse_declarations(lines):
    declarations = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        m = DECL_RE.search(line)
        if not m:
            i += 1
            continue

        name = m.group(1)

        # walk backwards to include a contiguous /// doc-comment block right above
        comment_start = i
        j = i - 1
        while j >= 0 and lines[j].strip().startswith("///"):
            comment_start = j
            j -= 1

        # walk forwards until we hit a line ending with ';' (handles multi-line values)
        decl_end = i
        joined = line
        while ";" not in line:
            decl_end += 1
            if decl_end >= n:
                break
            line = lines[decl_end]
            joined += " " + line

        preview = joined.strip()
        if len(preview) > 90:
            preview = preview[:87] + "..."

        declarations.append(Declaration(name, comment_start, decl_end, preview))
        i = decl_end + 1

    return declarations


# ============================================================
# Step 2 — search lib/ for usage of AppStrings.<name>
# ============================================================

def collect_dart_files(exclude_path):
    dart_files = []
    for dirpath, _dirs, files in os.walk(LIB_PATH):
        for f in files:
            if f.endswith(".dart"):
                full = os.path.join(dirpath, f)
                if os.path.abspath(full) != os.path.abspath(exclude_path):
                    dart_files.append(full)
    return dart_files


def build_usage_index(dart_files):
    """Concatenate all lib/ dart file contents (excluding app_strings.dart) once,
    so each declaration only needs a single regex search over it."""
    chunks = []
    for path in dart_files:
        try:
            with open(path, "r", encoding="utf-8") as f:
                chunks.append(f.read())
        except UnicodeDecodeError:
            print(f"   ⚠️  skipped unreadable file: {os.path.relpath(path, ROOT)}")
    return "\n".join(chunks)


def find_unused(declarations, haystack):
    unused = []
    for decl in declarations:
        pattern = re.compile(r"AppStrings\." + re.escape(decl.name) + r"\b")
        if not pattern.search(haystack):
            unused.append(decl)
    return unused


# ============================================================
# Step 3 — remove selected declarations
# ============================================================

def remove_declarations(lines, declarations_to_remove):
    # remove from bottom to top so earlier line indices stay valid
    for decl in sorted(declarations_to_remove, key=lambda d: d.start_line, reverse=True):
        del lines[decl.start_line: decl.end_line + 1]
    return lines


def prompt_selection(unused):
    print("\nWhat would you like to do?")
    print("  a  = remove ALL unused strings")
    print("  n  = remove NONE, just exit")
    print("  or type comma-separated numbers to remove specific ones (e.g. 1,3,5)")
    choice = input("\nYour choice: ").strip().lower()

    if choice == "n" or choice == "":
        return []
    if choice == "a":
        return unused

    selected = []
    for part in choice.split(","):
        part = part.strip()
        if not part.isdigit():
            continue
        idx = int(part) - 1
        if 0 <= idx < len(unused):
            selected.append(unused[idx])
    return selected


# ============================================================
# Main
# ============================================================

def main():
    dry_run = "--dry-run" in sys.argv

    if not os.path.exists(APP_STRINGS_PATH):
        print(f"❌ Could not find {os.path.relpath(APP_STRINGS_PATH, ROOT)}")
        print("   Run this from your Flutter project root.")
        return

    with open(APP_STRINGS_PATH, "r", encoding="utf-8") as f:
        original_lines = f.readlines()

    declarations = parse_declarations(original_lines)
    if not declarations:
        print("⚠️  No `static const String` declarations found in app_strings.dart.")
        return
    print(f"📋 Found {len(declarations)} string constants in app_strings.dart")

    dart_files = collect_dart_files(exclude_path=APP_STRINGS_PATH)
    print(f"🔎 Scanning {len(dart_files)} .dart files under lib/ for usage...")
    haystack = build_usage_index(dart_files)

    unused = find_unused(declarations, haystack)

    if not unused:
        print("\n✅ No unused strings found — every AppStrings constant is referenced somewhere in lib/.")
        return

    print(f"\n🧹 Unused strings ({len(unused)} of {len(declarations)}):\n")
    for idx, decl in enumerate(unused, start=1):
        line_no = decl.start_line + 1
        print(f"  [{idx}] line {line_no}: {decl.preview}")

    print(
        "\n⚠️  Note: this only checks for `AppStrings.<name>` usage inside lib/. "
        "It won't catch references from generated code outside lib/, "
        "reflection/dynamic lookups, or strings used only in tests."
    )

    if dry_run:
        print("\n🔎 Dry run mode — nothing will be removed. Re-run without --dry-run to remove.")
        return

    selected = prompt_selection(unused)
    if not selected:
        print("❌ Nothing removed.")
        return

    print(f"\nAbout to remove {len(selected)} constant(s) from app_strings.dart:")
    for decl in selected:
        print(f"  - {decl.name}")
    confirm = input("\nType 'y' to confirm: ").strip().lower()
    if confirm != "y":
        print("❌ Cancelled. Nothing removed.")
        return

    new_lines = remove_declarations(original_lines[:], selected)
    with open(APP_STRINGS_PATH, "w", encoding="utf-8") as f:
        f.writelines(new_lines)

    print(f"\n🎉 Removed {len(selected)} unused string(s) from app_strings.dart")
    print("👉 Run `dart format .` and do a quick build to confirm nothing broke.")


if __name__ == "__main__":
    main()

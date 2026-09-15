import os
import re
import shutil
import sys

ROOT = os.getcwd()
LIB_PATH = os.path.join(ROOT, "lib")
PACKAGE_NAME = "template_test2"  # 👈 must match generate_module.py / pubspec.yaml name

ROUTE_NAMES_PATH = os.path.join(LIB_PATH, "routes", "route_names.dart")
APP_ROUTER_PATH = os.path.join(LIB_PATH, "routes", "app_router.dart")


def format_class_name(name):
    """Convert snake_case or clean string to PascalCase (e.g., product_list -> ProductList)"""
    words = name.replace("-", "_").split("_")
    return "".join([w.capitalize() for w in words])


def format_snake_case(name):
    """Convert PascalCase or space string to snake_case (e.g., productList -> product_list)"""
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()


def format_camel_case(name):
    snake = format_snake_case(name)
    words = snake.split("_")
    if not words:
        return name
    return words[0].lower() + "".join([w.capitalize() for w in words[1:]])


def _find_matching_paren_end(content, open_paren_index):
    """Given the index of an opening '(', return the index just after its matching ')'."""
    depth = 0
    i = open_paren_index
    while i < len(content):
        if content[i] == "(":
            depth += 1
        elif content[i] == ")":
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return -1  # unbalanced, bail out


# ============================================================
# Step 1 — find every GoRoute(...) block that builds this screen,
# wherever the route-name constant is called.
# ============================================================

def find_goroute_blocks(content, class_prefix):
    """Returns a list of dicts: {start, end, route_names(set of identifiers found inside)}"""
    screen_marker = re.compile(r"\b" + re.escape(class_prefix) + r"Screen\(")
    blocks = []
    claimed_starts = set()

    for m in screen_marker.finditer(content):
        goroute_start = content.rfind("GoRoute(", 0, m.start())
        if goroute_start == -1 or goroute_start in claimed_starts:
            continue
        open_paren_index = goroute_start + len("GoRoute")
        block_end = _find_matching_paren_end(content, open_paren_index)
        if block_end == -1:
            print(f"   ⚠️  Could not find matching ')' for a GoRoute block near offset {goroute_start} — skipping, please check manually.")
            continue
        claimed_starts.add(goroute_start)
        block_text = content[goroute_start:block_end]
        route_name_ids = set(re.findall(r"RouteNames\.(\w+)", block_text))
        blocks.append({"start": goroute_start, "end": block_end, "route_names": route_name_ids, "text": block_text})

    return blocks


def remove_goroute_blocks(content, blocks):
    """Remove each block (from bottom to top so offsets stay valid), plus trailing comma/newline
    and leading indentation on that line."""
    for block in sorted(blocks, key=lambda b: b["start"], reverse=True):
        tail = block["end"]
        while tail < len(content) and content[tail] in " \t":
            tail += 1
        if tail < len(content) and content[tail] == ",":
            tail += 1
        while tail < len(content) and content[tail] in " \t":
            tail += 1
        if tail < len(content) and content[tail] == "\n":
            tail += 1
        line_start = content.rfind("\n", 0, block["start"]) + 1
        content = content[:line_start] + content[tail:]
    return content


def remove_screen_import(content, module_snake):
    pattern = re.compile(
        r"^import\s+'package:"
        + re.escape(PACKAGE_NAME)
        + r"/features/"
        + re.escape(module_snake)
        + r"/presentation/screens/"
        + re.escape(module_snake)
        + r"_screen\.dart';\s*\n?",
        re.MULTILINE,
    )
    return pattern.subn("", content)


def remove_route_name_constants(content, route_name_ids):
    """Remove `static const String <id> = '...';` lines for each id in route_name_ids."""
    if not route_name_ids:
        return content, set()
    lines = content.splitlines(keepends=True)
    kept_lines = []
    removed = set()
    for line in lines:
        matched = False
        for rid in route_name_ids:
            pattern = re.compile(r"^\s*static\s+const\s+String\s+" + re.escape(rid) + r"\s*=.*;\s*$")
            if pattern.match(line):
                matched = True
                removed.add(rid)
                break
        if not matched:
            kept_lines.append(line)
    return "".join(kept_lines), removed


# ============================================================
# Step 2 — scan the rest of lib/ for anything still referencing this feature
# ============================================================

def collect_dart_files(exclude_dirs, exclude_files):
    dart_files = []
    for dirpath, _dirs, files in os.walk(LIB_PATH):
        if any(os.path.abspath(dirpath).startswith(os.path.abspath(ex)) for ex in exclude_dirs):
            continue
        for f in files:
            if f.endswith(".dart"):
                full = os.path.join(dirpath, f)
                if os.path.abspath(full) in exclude_files:
                    continue
                dart_files.append(full)
    return dart_files


def scan_external_references(module_snake, class_prefix, route_name_ids):
    feature_dir = os.path.join(LIB_PATH, "features", module_snake)
    dart_files = collect_dart_files(
        exclude_dirs=[feature_dir],
        exclude_files={os.path.abspath(ROUTE_NAMES_PATH), os.path.abspath(APP_ROUTER_PATH)},
    )

    terms = [
        f"{class_prefix}Screen",
        f"{class_prefix}Controller",
        f"{class_prefix}Repository",
        f"{class_prefix}State",
        f"features/{module_snake}/",
    ]
    for rid in route_name_ids:
        terms.append(f"RouteNames.{rid}")

    # longest terms first, so e.g. "RouteNames.checkoutPage" matches before "RouteNames.checkout"
    terms.sort(key=len, reverse=True)
    term_pattern = re.compile("|".join(re.escape(t) for t in terms))

    findings = []  # (relpath, line_no, line_text, matched_term)
    for path in dart_files:
        try:
            with open(path, "r", encoding="utf-8") as f:
                lines = f.readlines()
        except UnicodeDecodeError:
            continue
        for i, line in enumerate(lines, start=1):
            m = term_pattern.search(line)
            if m:
                findings.append((os.path.relpath(path, ROOT), i, line.strip(), m.group(0)))
    return findings


# ============================================================
# Orchestration
# ============================================================

def remove_module(module_raw_name, dry_run=False, skip_confirm=False):
    module_snake = format_snake_case(module_raw_name)
    class_prefix = format_class_name(module_snake)
    feature_dir = os.path.join(LIB_PATH, "features", module_snake)

    if not os.path.isdir(feature_dir):
        print(f"⚠️  No folder found at {os.path.relpath(feature_dir, ROOT)} — nothing to do.")
        return

    router_content = ""
    if os.path.exists(APP_ROUTER_PATH):
        with open(APP_ROUTER_PATH, "r", encoding="utf-8") as f:
            router_content = f.read()

    goroute_blocks = find_goroute_blocks(router_content, class_prefix) if router_content else []
    route_name_ids = set()
    for b in goroute_blocks:
        route_name_ids |= b["route_names"]
    # also cover the common case where the constant matches the folder name directly,
    # even if for some reason it wasn't picked up from inside a GoRoute block
    route_name_ids.add(module_snake)

    external_findings = scan_external_references(module_snake, class_prefix, route_name_ids)

    # ---- report what will be auto-removed ----
    print(f"\n📦 Module: '{module_snake}' ({class_prefix})")
    print(f"\nWill auto-remove:")
    print(f"  - {os.path.relpath(feature_dir, ROOT)}  (entire folder)")
    if goroute_blocks:
        for b in goroute_blocks:
            names = ", ".join(sorted(b["route_names"])) or "(no RouteNames.* found inside)"
            print(f"  - GoRoute block in app_router.dart referencing: {names}")
    else:
        print(f"  - ⚠️  no GoRoute block found referencing {class_prefix}Screen( in app_router.dart")
    print(f"  - route-name constant(s) in route_names.dart: {', '.join(sorted(route_name_ids))}")
    print(f"  - screen import line in app_router.dart")

    # ---- report external references (not auto-removed) ----
    if external_findings:
        print(f"\n🔗 Found {len(external_findings)} external reference(s) elsewhere in lib/ — NOT auto-removed, please review:\n")
        for relpath, line_no, line_text, term in external_findings:
            print(f"  {relpath}:{line_no}  [{term}]  {line_text}")
    else:
        print("\n✅ No external references to this feature found elsewhere in lib/.")

    if dry_run:
        print("\n🔎 Dry run mode — nothing will be changed. Re-run without --dry-run to apply.")
        return

    if not skip_confirm:
        confirm = input("\nProceed with removing the folder + route wiring listed above? Type 'y' to confirm: ").strip().lower()
        if confirm != "y":
            print("❌ Cancelled. Nothing was deleted.")
            return

    # ---- perform removal ----
    shutil.rmtree(feature_dir)
    print(f"\n🗑️  Deleted folder: {os.path.relpath(feature_dir, ROOT)}")

    if router_content:
        new_content = router_content
        if goroute_blocks:
            new_content = remove_goroute_blocks(new_content, goroute_blocks)
        new_content, import_removed = remove_screen_import(new_content, module_snake)
        if import_removed == 0:
            print(f"⚠️  No matching screen import found in app_router.dart")
        if new_content != router_content:
            with open(APP_ROUTER_PATH, "w", encoding="utf-8") as f:
                f.write(new_content)
            print(f"🧹 Updated: {os.path.relpath(APP_ROUTER_PATH, ROOT)}")

    if os.path.exists(ROUTE_NAMES_PATH):
        with open(ROUTE_NAMES_PATH, "r", encoding="utf-8") as f:
            rn_content = f.read()
        new_rn_content, removed_ids = remove_route_name_constants(rn_content, route_name_ids)
        if removed_ids:
            with open(ROUTE_NAMES_PATH, "w", encoding="utf-8") as f:
                f.write(new_rn_content)
            print(f"🧹 Updated: {os.path.relpath(ROUTE_NAMES_PATH, ROOT)} (removed: {', '.join(sorted(removed_ids))})")
        else:
            print(f"⚠️  No matching route-name constants found in route_names.dart")

    print(f"\n🎉 Module '{class_prefix}' removed!")
    if external_findings:
        print(f"⚠️  {len(external_findings)} external reference(s) still exist elsewhere — see the list above and fix those manually,")
        print("   otherwise the app will fail to build (e.g. undefined RouteNames.* or unresolved imports).")
    print("👉 Run `dart format .` and check the build after this.")


if __name__ == "__main__":
    dry_run_flag = "--dry-run" in sys.argv
    yes_flag = "--yes" in sys.argv or "-y" in sys.argv

    module_input = input("Enter Section/Feature Name to remove: ").strip()
    if not module_input:
        print("❌ Error: Module name cannot be empty.")
    else:
        remove_module(module_input, dry_run=dry_run_flag, skip_confirm=yes_flag)
import os
import re
import shutil

ROOT = os.getcwd()
LIB_PATH = os.path.join(ROOT, "lib")
PACKAGE_NAME = "template_test2"  # 👈 must match generate_module.py / pubspec.yaml name

def format_class_name(name):
    """Convert snake_case or clean string to PascalCase (e.g., product_list -> ProductList)"""
    words = name.replace("-", "_").split("_")
    return "".join([w.capitalize() for w in words])

def format_snake_case(name):
    """Convert PascalCase or space string to snake_case (e.g., productList -> product_list)"""
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()


def remove_feature_folder(module_snake, dry_run):
    """Delete lib/features/<module_snake> entirely."""
    feature_dir = os.path.join(LIB_PATH, "features", module_snake)
    if not os.path.isdir(feature_dir):
        print(f"⚠️  Skipped: no folder found at {os.path.relpath(feature_dir, ROOT)}")
        return False
    if dry_run:
        print(f"🔎 [dry-run] Would delete folder: {os.path.relpath(feature_dir, ROOT)}")
        return True
    shutil.rmtree(feature_dir)
    print(f"🗑️  Deleted folder: {os.path.relpath(feature_dir, ROOT)}")
    return True


def remove_route_name(file_path, module_snake, dry_run):
    """Remove the `static const String <module_snake> = '/...';` line from route_names.dart."""
    if not os.path.exists(file_path):
        print(f"⚠️  Skipped: {os.path.relpath(file_path, ROOT)} not found")
        return

    with open(file_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    pattern = re.compile(
        r"^\s*static\s+const\s+String\s+" + re.escape(module_snake) + r"\s*=.*;\s*$"
    )
    kept_lines = []
    removed = False
    for line in lines:
        if pattern.match(line):
            removed = True
            continue
        kept_lines.append(line)

    if not removed:
        print(f"⚠️  No route-name constant found for '{module_snake}' in {os.path.relpath(file_path, ROOT)}")
        return

    if dry_run:
        print(f"🔎 [dry-run] Would remove route-name constant '{module_snake}' from {os.path.relpath(file_path, ROOT)}")
        return

    with open(file_path, "w", encoding="utf-8") as f:
        f.writelines(kept_lines)
    print(f"🧹 Removed route-name constant '{module_snake}' from {os.path.relpath(file_path, ROOT)}")


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


def remove_go_route_and_import(file_path, module_snake, class_prefix, dry_run):
    """Remove the GoRoute(...) entry referencing RouteNames.<module_snake> and its screen import."""
    if not os.path.exists(file_path):
        print(f"⚠️  Skipped: {os.path.relpath(file_path, ROOT)} not found")
        return

    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    original_content = content

    # --- Remove the GoRoute(...) block ---
    marker = f"RouteNames.{module_snake}"
    marker_index = content.find(marker)
    if marker_index != -1:
        goroute_start = content.rfind("GoRoute(", 0, marker_index)
        if goroute_start != -1:
            open_paren_index = goroute_start + len("GoRoute") 
            block_end = _find_matching_paren_end(content, open_paren_index)
            if block_end != -1:
                # consume a trailing comma/whitespace/newline after the block
                tail = block_end
                while tail < len(content) and content[tail] in " \t":
                    tail += 1
                if tail < len(content) and content[tail] == ",":
                    tail += 1
                while tail < len(content) and content[tail] in " \t":
                    tail += 1
                if tail < len(content) and content[tail] == "\n":
                    tail += 1
                # also eat leading indentation/newline before the GoRoute for a clean removal
                head = goroute_start
                line_start = content.rfind("\n", 0, head) + 1
                content = content[:line_start] + content[tail:]
            else:
                print("⚠️  Could not find matching ')' for GoRoute block — skipping GoRoute removal, please check manually.")
        else:
            print(f"⚠️  Found '{marker}' but no preceding 'GoRoute(' — skipping GoRoute removal, please check manually.")
    else:
        print(f"⚠️  No GoRoute entry found referencing '{marker}' in {os.path.relpath(file_path, ROOT)}")

    # --- Remove the screen import line ---
    import_pattern = re.compile(
        r"^import\s+'package:"
        + re.escape(PACKAGE_NAME)
        + r"/features/"
        + re.escape(module_snake)
        + r"/presentation/screens/"
        + re.escape(module_snake)
        + r"_screen\.dart';\s*\n?",
        re.MULTILINE,
    )
    content, import_removed_count = import_pattern.subn("", content)
    if import_removed_count == 0:
        print(f"⚠️  No matching import found for '{module_snake}_screen.dart' in {os.path.relpath(file_path, ROOT)}")

    if content == original_content:
        return  # nothing changed

    if dry_run:
        print(f"🔎 [dry-run] Would remove GoRoute + import for '{module_snake}' from {os.path.relpath(file_path, ROOT)}")
        return

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"🧹 Removed GoRoute + import for '{module_snake}' from {os.path.relpath(file_path, ROOT)}")


def remove_module(module_raw_name, dry_run=False, skip_confirm=False):
    module_snake = format_snake_case(module_raw_name)
    class_prefix = format_class_name(module_snake)

    feature_dir = os.path.join(LIB_PATH, "features", module_snake)
    route_names_path = os.path.join(LIB_PATH, "routes", "route_names.dart")
    app_router_path = os.path.join(LIB_PATH, "routes", "app_router.dart")

    print(f"\nAbout to remove module '{module_snake}' ({class_prefix}):")
    print(f"  - {os.path.relpath(feature_dir, ROOT)}  (entire folder)")
    print(f"  - route-name constant '{module_snake}' in routes/route_names.dart")
    print(f"  - GoRoute entry + import in routes/app_router.dart")

    if dry_run:
        print("\n🔎 Dry run mode — previewing only, nothing will be deleted.")
    elif not skip_confirm:
        confirm = input(f"\nProceed with deletion? Type 'y' to confirm: ").strip().lower()
        if confirm != "y":
            print("❌ Cancelled. Nothing was deleted.")
            return

    remove_feature_folder(module_snake, dry_run)
    remove_route_name(route_names_path, module_snake, dry_run)
    remove_go_route_and_import(app_router_path, module_snake, class_prefix, dry_run)

    if dry_run:
        print(f"\n🔎 Dry run complete for '{class_prefix}'. No files were changed.")
        print("👉 Re-run without --dry-run to actually delete.")
    else:
        print(f"\n🎉 Module '{class_prefix}' removed successfully!")
        print("👉 Run `dart format .` and check imports/build after this.")


if __name__ == "__main__":
    import sys

    dry_run_flag = "--dry-run" in sys.argv
    yes_flag = "--yes" in sys.argv or "-y" in sys.argv

    module_input = input("Enter Section/Feature Name to remove: ").strip()
    if not module_input:
        print("❌ Error: Module name cannot be empty.")
    else:
        remove_module(module_input, dry_run=dry_run_flag, skip_confirm=yes_flag)
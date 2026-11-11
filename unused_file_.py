import os
import re
import sys

def find_unused_dart_files(project_root=None):
    if not project_root:
        project_root = os.path.dirname(os.path.abspath(__file__))

    lib_dir = os.path.join(project_root, 'lib')
    if not os.path.exists(lib_dir):
        print(f"Error: Could not find 'lib' directory at: {lib_dir}")
        sys.exit(1)

    print("🔍 Scanning project files...")

    # Collect all .dart files in lib/ and in whole project
    lib_files = []
    all_dart_files = []

    ignore_dirs = {'.dart_tool', 'build', '.git', '.idea', 'ios', 'android', 'web', 'windows', 'linux', 'macos'}

    for root, dirs, files in os.walk(project_root):
        # Filter out ignored directories
        dirs[:] = [d for d in dirs if d not in ignore_dirs]

        for f in files:
            if f.endswith('.dart'):
                full_path = os.path.join(root, f)
                all_dart_files.append(full_path)
                if full_path.startswith(lib_dir):
                    lib_files.append(full_path)

    # Cache content of all dart files
    file_contents = {}
    for p in all_dart_files:
        try:
            with open(p, 'r', encoding='utf-8', errors='ignore') as f:
                file_contents[p] = f.read()
        except Exception as e:
            print(f"Warning: Could not read file {p}: {e}")

    def get_top_level_declarations(content):
        symbols = set()

        # Match class, enum, mixin, typedef, extension
        matches = re.findall(
            r'^\s*(?:abstract\s+)?(?:class|enum|mixin|typedef|extension)\s+([A-Za-z0-9_]+)',
            content,
            re.MULTILINE
        )
        for m in matches:
            symbols.add(m)

        # Match top-level functions or variables (non-indented or start of line)
        top_matches = re.findall(
            r'^(?:final|const|var|void|[A-Za-z0-9_<>]+)\s+([a-zA-Z0-9_]+)\s*(?:=|\()',
            content,
            re.MULTILINE
        )
        ignore_keywords = {
            'class', 'enum', 'mixin', 'typedef', 'extension', 'import', 'export',
            'part', 'return', 'if', 'for', 'while', 'switch', 'super', 'this',
            'case', 'break', 'continue', 'default', 'try', 'catch', 'finally', 'do'
        }
        for tm in top_matches:
            if not tm.startswith('_') and tm not in ignore_keywords:
                symbols.add(tm)

        return symbols

    print(f"📊 Analyzing {len(lib_files)} Dart files in lib/...\n")

    unused_files = []
    total_lib_lines = 0

    for lib_f in lib_files:
        rel_path = os.path.relpath(lib_f, project_root).replace('\\', '/')
        filename = os.path.basename(lib_f)
        content = file_contents.get(lib_f, "")
        file_lines = len(content.splitlines())
        total_lib_lines += file_lines

        # Skip main.dart (entry point)
        if rel_path == 'lib/main.dart':
            continue

        is_used = False

        # Check 1: Is filename referenced in any other file?
        for p, c in file_contents.items():
            if p != lib_f and filename in c:
                is_used = True
                break

        # Check 2: Are top-level symbols referenced in any other file?
        if not is_used:
            symbols = get_top_level_declarations(content)
            for sym in symbols:
                pattern = re.compile(r'\b' + re.escape(sym) + r'\b')
                for p, c in file_contents.items():
                    if p != lib_f and pattern.search(c):
                        is_used = True
                        break
                if is_used:
                    break

        if not is_used:
            unused_files.append((rel_path, file_lines))

    # Output Results
    print("==================================================")
    print("           PROJECT SUMMARY & STATS                ")
    print("==================================================")
    print(f"📁 Total .dart files in lib/ : {len(lib_files)}")
    print(f"📝 Total lines of code in lib/: {total_lib_lines}")
    print(f"⚠️  Total unused files found  : {len(unused_files)}\n")

    if unused_files:
        print("==================================================")
        print("              UNUSED DART FILES                   ")
        print("==================================================")
        total_unused_lines = 0
        for uf, lc in sorted(unused_files):
            total_unused_lines += lc
            print(f"  • [{lc:>4} lines]  {uf}")
        print("--------------------------------------------------")
        print(f"Total unused lines of code: {total_unused_lines} lines")
        print("==================================================")
    else:
        print("🎉 No unused files found in lib/!")

if __name__ == '__main__':
    find_unused_dart_files()

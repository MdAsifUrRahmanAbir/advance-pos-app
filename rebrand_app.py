"""
rebrand_app.py
================
One script to change:
  1) App / Bundle package ID   (Android applicationId+namespace, iOS/macOS bundle id)
  2) App display name          (Android label, iOS/macOS name, web/windows/linux title)
  3) Launcher icon              (Android mipmaps, iOS/macOS AppIcon set, web icons, windows .ico)

...for whichever platform folders actually exist in the project (auto-detected).

NOTE: This does NOT rename the Dart/Flutter package in pubspec.yaml (the `name:` field).
Renaming that requires rewriting every import across lib/ and is a separate, much
riskier operation — intentionally out of scope here.

Requirements:
    pip install pillow

Usage:
    python rebrand_app.py
    python rebrand_app.py --dry-run
"""

import json
import os
import re
import sys

try:
    from PIL import Image
except ImportError:
    Image = None

ROOT = os.getcwd()
ALL_PLATFORMS = ["android", "ios", "web", "windows", "macos", "linux"]


# ============================================================
# Helpers
# ============================================================

def detect_platforms():
    return [p for p in ALL_PLATFORMS if os.path.isdir(os.path.join(ROOT, p))]


def read(path):
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def write(path, content, dry_run):
    if dry_run:
        print(f"   🔎 [dry-run] would write: {os.path.relpath(path, ROOT)}")
        return
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"   🧹 updated: {os.path.relpath(path, ROOT)}")


def regex_replace_in_file(path, pattern, replacement, dry_run, flags=0, label=None):
    if not os.path.exists(path):
        return False
    content = read(path)
    new_content, n = re.subn(pattern, replacement, content, flags=flags)
    if n == 0:
        print(f"   ⚠️  no match for {label or pattern} in {os.path.relpath(path, ROOT)}")
        return False
    write(path, new_content, dry_run)
    return True


def find_first(base_dir, filename):
    for dirpath, _dirs, files in os.walk(base_dir):
        if filename in files:
            return os.path.join(dirpath, filename)
    return None


# ============================================================
# ANDROID
# ============================================================

def update_android_package(new_package, dry_run):
    print("\n📦 Android — package id")
    app_dir = os.path.join(ROOT, "android", "app")
    gradle_path = os.path.join(app_dir, "build.gradle")
    if not os.path.exists(gradle_path):
        gradle_path = os.path.join(app_dir, "build.gradle.kts")
    if not os.path.exists(gradle_path):
        print("   ⚠️  no build.gradle(.kts) found, skipping")
        return

    content = read(gradle_path)
    m = re.search(r'applicationId\s*=?\s*"([^"]+)"', content)
    if not m:
        print("   ⚠️  could not find current applicationId, skipping")
        return
    old_package = m.group(1)
    if old_package == new_package:
        print("   ℹ️  already set to this package id")
        return

    new_content = re.sub(r'(applicationId\s*=?\s*)"[^"]+"', r'\1"%s"' % new_package, content)
    new_content = re.sub(r'(namespace\s*=?\s*)"[^"]+"', r'\1"%s"' % new_package, new_content)
    write(gradle_path, new_content, dry_run)

    # Move MainActivity.kt / MainActivity.java into the new package folder
    for lang, ext in (("kotlin", "kt"), ("java", "java")):
        src_root = os.path.join(app_dir, "src", "main", lang)
        if not os.path.isdir(src_root):
            continue
        main_activity = find_first(src_root, f"MainActivity.{ext}")
        if not main_activity:
            continue

        old_rel_dir = os.path.dirname(os.path.relpath(main_activity, src_root))
        new_rel_dir = new_package.replace(".", os.sep)
        new_dir = os.path.join(src_root, new_rel_dir)
        new_path = os.path.join(new_dir, f"MainActivity.{ext}")

        file_content = read(main_activity)
        file_content = re.sub(r"^package\s+[\w.]+", f"package {new_package}", file_content, flags=re.MULTILINE)

        if dry_run:
            print(f"   🔎 [dry-run] would move {os.path.relpath(main_activity, ROOT)} -> {os.path.relpath(new_path, ROOT)}")
            continue

        os.makedirs(new_dir, exist_ok=True)
        with open(new_path, "w", encoding="utf-8") as f:
            f.write(file_content)
        if os.path.abspath(new_path) != os.path.abspath(main_activity):
            os.remove(main_activity)
            # clean up now-empty old directories, up to src_root
            d = os.path.dirname(main_activity)
            while d != src_root and os.path.isdir(d) and not os.listdir(d):
                parent = os.path.dirname(d)
                os.rmdir(d)
                d = parent
        print(f"   📁 moved MainActivity.{ext} -> package {new_package}")


def update_android_app_name(new_name, dry_run):
    print("\n🏷️  Android — app label")
    for variant in ("main", "debug", "profile"):
        manifest = os.path.join(ROOT, "android", "app", "src", variant, "AndroidManifest.xml")
        if os.path.exists(manifest):
            regex_replace_in_file(
                manifest,
                r'android:label="[^"]*"',
                f'android:label="{new_name}"',
                dry_run,
                label="android:label",
            )


ANDROID_ICON_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}


def update_android_icon(source_icon, dry_run):
    print("\n🎨 Android — launcher icon")
    res_dir = os.path.join(ROOT, "android", "app", "src", "main", "res")
    if not os.path.isdir(res_dir):
        print("   ⚠️  no res/ folder found, skipping")
        return
    src = Image.open(source_icon).convert("RGBA")
    for folder, size in ANDROID_ICON_SIZES.items():
        target_dir = os.path.join(res_dir, folder)
        if not os.path.isdir(target_dir):
            continue
        for filename in ("ic_launcher.png", "ic_launcher_round.png", "ic_launcher_foreground.png"):
            target = os.path.join(target_dir, filename)
            if not os.path.exists(target):
                continue
            if dry_run:
                print(f"   🔎 [dry-run] would write {os.path.relpath(target, ROOT)} ({size}x{size})")
                continue
            resized = src.resize((size, size), Image.LANCZOS)
            resized.save(target)
            print(f"   🖼️  {os.path.relpath(target, ROOT)} -> {size}x{size}")


# ============================================================
# iOS / macOS (shared: pbxproj bundle id, AppIcon Contents.json)
# ============================================================

def update_apple_bundle_id(platform, new_package, dry_run):
    label = "iOS" if platform == "ios" else "macOS"
    print(f"\n📦 {label} — bundle identifier")
    pbxproj = os.path.join(ROOT, platform, "Runner.xcodeproj", "project.pbxproj")
    regex_replace_in_file(
        pbxproj,
        r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+;',
        f'PRODUCT_BUNDLE_IDENTIFIER = {new_package};',
        dry_run,
        label="PRODUCT_BUNDLE_IDENTIFIER",
    )


def update_ios_app_name(new_name, dry_run):
    print("\n🏷️  iOS — app name")
    plist = os.path.join(ROOT, "ios", "Runner", "Info.plist")
    if not os.path.exists(plist):
        print("   ⚠️  Info.plist not found, skipping")
        return
    content = read(plist)
    for key in ("CFBundleName", "CFBundleDisplayName"):
        content, n = re.subn(
            rf'(<key>{key}</key>\s*<string>)[^<]*(</string>)',
            rf'\g<1>{new_name}\g<2>',
            content,
        )
        if n == 0:
            print(f"   ⚠️  no match for {key}")
    write(plist, content, dry_run)


def update_macos_app_name(new_name, dry_run):
    print("\n🏷️  macOS — app name")
    xcconfig = os.path.join(ROOT, "macos", "Runner", "Configs", "AppInfo.xcconfig")
    regex_replace_in_file(
        xcconfig,
        r'PRODUCT_NAME = .*',
        f'PRODUCT_NAME = {new_name}',
        dry_run,
        label="PRODUCT_NAME",
    )


def update_apple_icon(platform, source_icon, dry_run):
    label = "iOS" if platform == "ios" else "macOS"
    print(f"\n🎨 {label} — launcher icon")
    appiconset = os.path.join(ROOT, platform, "Runner", "Assets.xcassets", "AppIcon.appiconset")
    contents_path = os.path.join(appiconset, "Contents.json")
    if not os.path.exists(contents_path):
        print("   ⚠️  AppIcon.appiconset/Contents.json not found, skipping")
        return
    with open(contents_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    src = Image.open(source_icon).convert("RGBA")
    for img in data.get("images", []):
        filename = img.get("filename")
        size_str = img.get("size")
        scale_str = img.get("scale", "1x")
        if not filename or not size_str:
            continue
        try:
            base = float(size_str.split("x")[0])
            scale = float(scale_str.replace("x", ""))
            px = max(1, int(round(base * scale)))
        except ValueError:
            continue
        target = os.path.join(appiconset, filename)
        if dry_run:
            print(f"   🔎 [dry-run] would write {os.path.relpath(target, ROOT)} ({px}x{px})")
            continue
        resized = src.resize((px, px), Image.LANCZOS)
        resized.save(target)
    if not dry_run:
        print(f"   🖼️  regenerated all sizes listed in Contents.json")


# ============================================================
# WEB
# ============================================================

def update_web_app_name(new_name, dry_run):
    print("\n🏷️  Web — app name")
    manifest = os.path.join(ROOT, "web", "manifest.json")
    if os.path.exists(manifest):
        with open(manifest, "r", encoding="utf-8") as f:
            data = json.load(f)
        data["name"] = new_name
        data["short_name"] = new_name
        if dry_run:
            print(f"   🔎 [dry-run] would update web/manifest.json name/short_name")
        else:
            with open(manifest, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2)
            print("   🧹 updated: web/manifest.json")

    index_html = os.path.join(ROOT, "web", "index.html")
    regex_replace_in_file(
        index_html,
        r"<title>[^<]*</title>",
        f"<title>{new_name}</title>",
        dry_run,
        label="<title>",
    )


WEB_ICON_SIZES = {
    "Icon-192.png": 192,
    "Icon-512.png": 512,
    "Icon-maskable-192.png": 192,
    "Icon-maskable-512.png": 512,
}


def update_web_icon(source_icon, dry_run):
    print("\n🎨 Web — icons")
    icons_dir = os.path.join(ROOT, "web", "icons")
    src = Image.open(source_icon).convert("RGBA")
    if os.path.isdir(icons_dir):
        for filename, size in WEB_ICON_SIZES.items():
            target = os.path.join(icons_dir, filename)
            if dry_run:
                print(f"   🔎 [dry-run] would write {os.path.relpath(target, ROOT)} ({size}x{size})")
                continue
            src.resize((size, size), Image.LANCZOS).save(target)
            print(f"   🖼️  {os.path.relpath(target, ROOT)} -> {size}x{size}")
    favicon = os.path.join(ROOT, "web", "favicon.png")
    if os.path.exists(favicon):
        if dry_run:
            print(f"   🔎 [dry-run] would write web/favicon.png (32x32)")
        else:
            src.resize((32, 32), Image.LANCZOS).save(favicon)
            print("   🖼️  web/favicon.png -> 32x32")


# ============================================================
# WINDOWS
# ============================================================

def update_windows_app_name(new_name, dry_run):
    print("\n🏷️  Windows — window title")
    main_cpp = os.path.join(ROOT, "windows", "runner", "main.cpp")
    regex_replace_in_file(
        main_cpp,
        r'(window\.CreateAndShow\(\s*L?")[^"]*(")',
        rf'\g<1>{new_name}\g<2>',
        dry_run,
        label="window title in main.cpp",
    )


def update_windows_icon(source_icon, dry_run):
    print("\n🎨 Windows — .ico")
    ico_path = os.path.join(ROOT, "windows", "runner", "resources", "app_icon.ico")
    if not os.path.exists(os.path.dirname(ico_path)):
        print("   ⚠️  windows/runner/resources not found, skipping")
        return
    if dry_run:
        print(f"   🔎 [dry-run] would write {os.path.relpath(ico_path, ROOT)}")
        return
    src = Image.open(source_icon).convert("RGBA")
    src.save(ico_path, sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
    print(f"   🖼️  {os.path.relpath(ico_path, ROOT)}")


# ============================================================
# LINUX
# ============================================================

def update_linux_app_name(new_name, dry_run):
    print("\n🏷️  Linux — window title")
    my_app = os.path.join(ROOT, "linux", "runner", "my_application.cc")
    regex_replace_in_file(
        my_app,
        r'(gtk_header_bar_set_title\s*\(\s*header_bar,\s*")[^"]*(")',
        rf'\g<1>{new_name}\g<2>',
        dry_run,
        label="gtk_header_bar_set_title",
    )
    regex_replace_in_file(
        my_app,
        r'(gtk_window_set_title\s*\(\s*window,\s*")[^"]*(")',
        rf'\g<1>{new_name}\g<2>',
        dry_run,
        label="gtk_window_set_title",
    )


def update_linux_binary_id(new_package, dry_run):
    print("\n📦 Linux — application id")
    cmake = os.path.join(ROOT, "linux", "CMakeLists.txt")
    regex_replace_in_file(
        cmake,
        r'(set\(APPLICATION_ID\s+")[^"]+(")',
        rf'\g<1>{new_package}\g<2>',
        dry_run,
        label="APPLICATION_ID",
    )


# ============================================================
# Orchestration
# ============================================================

def main():
    dry_run = "--dry-run" in sys.argv

    platforms = detect_platforms()
    if not platforms:
        print("❌ No platform folders (android/ios/web/windows/macos/linux) found here.")
        print(f"   Run this from your Flutter project root (current dir: {ROOT})")
        return
    print(f"📱 Detected platforms: {', '.join(platforms)}")

    chosen = input(
        "Apply to all of these? Press Enter for all, or type comma-separated subset: "
    ).strip()
    if chosen:
        chosen_set = {p.strip() for p in chosen.split(",")}
        platforms = [p for p in platforms if p in chosen_set]

    new_package = input("\nNew package / bundle id (e.g. com.mycompany.posspro), or Enter to skip: ").strip()
    new_name = input("New app display name, or Enter to skip: ").strip()
    icon_path = input("Path to source launcher icon (PNG, ideally 1024x1024), or Enter to skip: ").strip()

    if icon_path and Image is None:
        print("\n❌ Pillow is not installed. Run: pip install pillow")
        print("   Skipping icon step; package id / app name will still be applied.")
        icon_path = ""

    if icon_path and not os.path.exists(icon_path):
        print(f"\n❌ Icon file not found at '{icon_path}'. Skipping icon step.")
        icon_path = ""

    if not new_package and not new_name and not icon_path:
        print("\nNothing to do — no package id, app name, or icon provided.")
        return

    print(
        f"\nAbout to apply to [{', '.join(platforms)}]:"
        f"\n  package/bundle id : {new_package or '(unchanged)'}"
        f"\n  app name          : {new_name or '(unchanged)'}"
        f"\n  launcher icon     : {icon_path or '(unchanged)'}"
    )
    if not dry_run:
        confirm = input("\nProceed? Type 'y' to confirm: ").strip().lower()
        if confirm != "y":
            print("❌ Cancelled.")
            return
    else:
        print("\n🔎 Dry run mode — previewing only, nothing will be written.")

    if "android" in platforms:
        if new_package:
            update_android_package(new_package, dry_run)
        if new_name:
            update_android_app_name(new_name, dry_run)
        if icon_path:
            update_android_icon(icon_path, dry_run)

    if "ios" in platforms:
        if new_package:
            update_apple_bundle_id("ios", new_package, dry_run)
        if new_name:
            update_ios_app_name(new_name, dry_run)
        if icon_path:
            update_apple_icon("ios", icon_path, dry_run)

    if "macos" in platforms:
        if new_package:
            update_apple_bundle_id("macos", new_package, dry_run)
        if new_name:
            update_macos_app_name(new_name, dry_run)
        if icon_path:
            update_apple_icon("macos", icon_path, dry_run)

    if "web" in platforms:
        if new_name:
            update_web_app_name(new_name, dry_run)
        if icon_path:
            update_web_icon(icon_path, dry_run)

    if "windows" in platforms:
        if new_name:
            update_windows_app_name(new_name, dry_run)
        if icon_path:
            update_windows_icon(icon_path, dry_run)

    if "linux" in platforms:
        if new_package:
            update_linux_binary_id(new_package, dry_run)
        if new_name:
            update_linux_app_name(new_name, dry_run)

    if dry_run:
        print("\n🔎 Dry run complete. Re-run without --dry-run to actually apply changes.")
    else:
        print("\n🎉 Done! Recommended next steps:")
        print("   flutter clean && flutter pub get")
        print("   (Android) rebuild — Gradle will pick up the new applicationId/package folder")
        print("   (iOS/macOS) open Xcode once to confirm the bundle id + icons look right")


if __name__ == "__main__":
    main()

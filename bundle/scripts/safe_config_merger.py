#!/usr/bin/env python3
"""
safe_config_merger.py - Dusky Multi-Shell Safe Configuration Merger & Rollback Engine

Provides non-destructive merging, automatic pre-flight backups, syntax verification,
and atomic rollback capabilities for Dusky Linux Hyprland Lua and Matugen configurations.
"""

import os
import sys
import shutil
import datetime
import json
import subprocess
import tomllib

HOME = os.path.expanduser("~")
BACKUP_ROOT = os.path.join(HOME, ".config", "dusky_multishell_backups")
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
TEMPLATES_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, "..", "templates"))

# Target user configuration files
HYPR_DIR = os.path.join(HOME, ".config", "hypr")
HYPR_EDIT_KEYBINDS = os.path.join(HYPR_DIR, "edit_here", "source", "keybinds.lua")
HYPR_SRC_KEYBINDS = os.path.join(HYPR_DIR, "source", "keybinds.lua")
HYPR_EDIT_RULES = os.path.join(HYPR_DIR, "edit_here", "source", "window_rules.lua")
HYPR_SRC_RULES = os.path.join(HYPR_DIR, "source", "window_rules.lua")
MATUGEN_CONFIG = os.path.join(HOME, ".config", "matugen", "config.toml")
SERPANTINUM_SETTINGS = os.path.join(HOME, ".config", "serpantinum", "settings.json")
INIR_CONFIG = os.path.join(HOME, ".config", "inir", "config.json")


def log(msg, level="INFO"):
    colors = {
        "INFO": "\033[0;34m[INFO]\033[0m",
        "SUCCESS": "\033[0;32m[SUCCESS]\033[0m",
        "WARN": "\033[0;33m[WARN]\033[0m",
        "ERROR": "\033[0;31m[ERROR]\033[0m"
    }
    print(f"{colors.get(level, level)} {msg}")


def verify_lua(file_path):
    """Verifies syntax of a Lua file using luac -p."""
    if not os.path.exists(file_path):
        return True
    res = subprocess.run(["luac", "-p", file_path], capture_output=True, text=True)
    if res.returncode != 0:
        log(f"Lua syntax error in {file_path}:\n{res.stderr.strip()}", "ERROR")
        return False
    return True


def verify_toml(file_path):
    """Verifies syntax of a TOML file using tomllib."""
    if not os.path.exists(file_path):
        return True
    try:
        with open(file_path, "rb") as f:
            tomllib.load(f)
        return True
    except Exception as e:
        log(f"TOML syntax error in {file_path}: {e}", "ERROR")
        return False


def create_backup():
    """Creates a timestamped backup of all files about to be touched."""
    os.makedirs(BACKUP_ROOT, exist_ok=True)
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = os.path.join(BACKUP_ROOT, f"backup_{timestamp}")
    os.makedirs(backup_dir, exist_ok=True)

    manifest = {
        "timestamp": timestamp,
        "created_at": datetime.datetime.now().isoformat(),
        "files": {}
    }

    targets = [
        HYPR_EDIT_KEYBINDS,
        HYPR_SRC_KEYBINDS,
        HYPR_EDIT_RULES,
        HYPR_SRC_RULES,
        MATUGEN_CONFIG,
        SERPANTINUM_SETTINGS,
        INIR_CONFIG
    ]

    backed_up_count = 0
    for target in targets:
        if os.path.exists(target):
            rel_name = os.path.relpath(target, HOME).replace("/", "_")
            dest_path = os.path.join(backup_dir, rel_name)
            shutil.copy2(target, dest_path)
            manifest["files"][target] = dest_path
            backed_up_count += 1

    manifest_path = os.path.join(backup_dir, "manifest.json")
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)

    # Update 'latest' symlink
    latest_link = os.path.join(BACKUP_ROOT, "latest")
    if os.path.islink(latest_link) or os.path.exists(latest_link):
        try:
            os.unlink(latest_link)
        except OSError:
            pass
    try:
        os.symlink(backup_dir, latest_link)
    except OSError:
        pass

    log(f"Backup created successfully at: {backup_dir} ({backed_up_count} files preserved)", "SUCCESS")
    return backup_dir


def rollback(target_backup=None):
    """Rolls back files from backup directory."""
    if not target_backup:
        target_backup = os.path.join(BACKUP_ROOT, "latest")

    if not os.path.exists(target_backup):
        log(f"Backup directory not found: {target_backup}", "ERROR")
        return False

    manifest_path = os.path.join(target_backup, "manifest.json")
    if not os.path.exists(manifest_path):
        log(f"Manifest not found in backup: {manifest_path}", "ERROR")
        return False

    with open(manifest_path, "r", encoding="utf-8") as f:
        manifest = json.load(f)

    log(f"Rolling back to backup from {manifest.get('created_at', 'unknown time')}...", "INFO")
    restored = []
    for original, saved in manifest.get("files", {}).items():
        if os.path.exists(saved):
            os.makedirs(os.path.dirname(original), exist_ok=True)
            shutil.copy2(saved, original)
            restored.append(original)
            log(f"Restored: {original}", "INFO")

    # Verify restored files
    all_valid = True
    for file_path in restored:
        if file_path.endswith(".lua"):
            if not verify_lua(file_path):
                all_valid = False
        elif file_path.endswith(".toml"):
            if not verify_toml(file_path):
                all_valid = False

    if all_valid:
        log("Rollback completed. Reloading Hyprland...", "SUCCESS")
        subprocess.run(["hyprctl", "reload"], capture_output=True)
        return True
    else:
        log("Rollback completed with syntax warnings. Check restored files.", "WARN")
        return False


def merge_matugen():
    """Safely merges multi-shell templates into ~/.config/matugen/config.toml."""
    if not os.path.exists(MATUGEN_CONFIG):
        log(f"Matugen config not found at {MATUGEN_CONFIG}, skipping merge.", "WARN")
        return True

    with open(MATUGEN_CONFIG, "rb") as f:
        try:
            cfg = tomllib.load(f)
        except Exception as e:
            log(f"Failed to parse existing Matugen config.toml: {e}", "ERROR")
            return False

    templates = cfg.get("templates", {})
    required_keys = [
        "serpantinum_quickshell",
        "serpantinum_wallpaper",
        "shell_switcher",
        "inir_quickshell"
    ]

    missing = [k for k in required_keys if k not in templates]
    if not missing:
        log("Matugen config.toml already contains all multi-shell templates.", "INFO")
        return True

    log(f"Matugen config.toml is missing templates: {missing}. Merging safely...", "INFO")

    snippet_path = os.path.join(TEMPLATES_DIR, "matugen_config_snippet.toml")
    snippet_content = ""
    if os.path.exists(snippet_path):
        with open(snippet_path, "r", encoding="utf-8") as f:
            snippet_content = f.read()
    else:
        log(f"Snippet not found at {snippet_path}", "ERROR")
        return False

    with open(MATUGEN_CONFIG, "a", encoding="utf-8") as f:
        f.write("\n\n# =============================================================================\n")
        f.write("# DUSKY MULTI-SHELL INTEGRATION TEMPLATES (AUTOMATICALLY MERGED)\n")
        f.write("# =============================================================================\n")
        f.write(snippet_content)

    if verify_toml(MATUGEN_CONFIG):
        log("Matugen config merged and verified successfully.", "SUCCESS")
        return True
    else:
        log("Matugen config merge failed verification! Reverting...", "ERROR")
        return False


def merge_window_rules():
    """Safely merges multi-shell window and layer rules into window_rules.lua."""
    target_file = HYPR_EDIT_RULES if os.path.exists(HYPR_EDIT_RULES) else HYPR_SRC_RULES
    if not os.path.exists(target_file):
        log(f"Window rules file not found: {target_file}", "WARN")
        return True

    with open(target_file, "r", encoding="utf-8") as f:
        content = f.read()

    needed_rules = ["qs-master", "inir_panels_blur", "inir_background_no_blur"]
    missing = [r for r in needed_rules if r not in content]

    if not missing:
        log(f"Window rules in {target_file} already contain multi-shell rules.", "INFO")
        return True

    log(f"Window rules in {target_file} missing {missing}. Merging safely...", "INFO")

    rules_snippet_path = os.path.join(TEMPLATES_DIR, "hyprland_window_rules_snippet.lua")
    if os.path.exists(rules_snippet_path):
        with open(rules_snippet_path, "r", encoding="utf-8") as f:
            snippet = f.read()
    else:
        log(f"Snippet not found at {rules_snippet_path}", "ERROR")
        return False

    with open(target_file, "a", encoding="utf-8") as f:
        f.write("\n\n-- =============================================================================\n")
        f.write("-- DUSKY MULTI-SHELL LAYER RULES (AUTOMATICALLY MERGED)\n")
        f.write("-- =============================================================================\n")
        f.write(snippet)

    if verify_lua(target_file):
        log(f"Window rules merged and verified in {target_file}.", "SUCCESS")
        return True
    else:
        log(f"Window rules merge failed Lua syntax verification in {target_file}!", "ERROR")
        return False


def merge_keybinds():
    """Safely merges smart dispatchers into keybinds.lua."""
    target_file = HYPR_EDIT_KEYBINDS if os.path.exists(HYPR_EDIT_KEYBINDS) else HYPR_SRC_KEYBINDS
    if not os.path.exists(target_file):
        log(f"Keybinds file not found: {target_file}", "WARN")
        return True

    with open(target_file, "r", encoding="utf-8") as f:
        content = f.read()

    needed_dispatchers = [
        "smart_launcher.sh",
        "smart_control_center.sh",
        "smart_sidebar.sh",
        "smart_lock.sh",
        "smart_clipboard.sh",
        "dusky_shell_switcher.py"
    ]

    missing = [d for d in needed_dispatchers if d not in content]

    # Also check if they are in source/keybinds.lua if target is edit_here
    if target_file == HYPR_EDIT_KEYBINDS and os.path.exists(HYPR_SRC_KEYBINDS):
        with open(HYPR_SRC_KEYBINDS, "r", encoding="utf-8") as sf:
            src_content = sf.read()
        missing = [d for d in missing if d not in src_content]

    if not missing:
        log("All smart dispatchers are already bound in Hyprland keybinds.", "INFO")
        return True

    log(f"Merging missing smart dispatchers ({missing}) into {target_file}...", "INFO")

    keybinds_snippet_path = os.path.join(TEMPLATES_DIR, "hyprland_keybinds_snippet.lua")
    if os.path.exists(keybinds_snippet_path):
        with open(keybinds_snippet_path, "r", encoding="utf-8") as f:
            snippet = f.read()
    else:
        log(f"Snippet not found at {keybinds_snippet_path}", "ERROR")
        return False

    with open(target_file, "a", encoding="utf-8") as f:
        f.write("\n\n-- =============================================================================\n")
        f.write("-- DUSKY MULTI-SHELL SMART DISPATCHERS (AUTOMATICALLY MERGED)\n")
        f.write("-- =============================================================================\n")
        f.write(snippet)

    if verify_lua(target_file):
        log(f"Keybinds merged and verified in {target_file}.", "SUCCESS")
        return True
    else:
        log(f"Keybinds merge failed Lua syntax verification in {target_file}!", "ERROR")
        return False


def verify_all():
    """Verifies all user configuration files for syntax errors."""
    log("Verifying configuration syntax...", "INFO")
    all_ok = True
    for lf in [HYPR_EDIT_KEYBINDS, HYPR_SRC_KEYBINDS, HYPR_EDIT_RULES, HYPR_SRC_RULES]:
        if os.path.exists(lf):
            if verify_lua(lf):
                log(f"✓ {lf}: Valid Lua syntax", "SUCCESS")
            else:
                all_ok = False
    if os.path.exists(MATUGEN_CONFIG):
        if verify_toml(MATUGEN_CONFIG):
            log(f"✓ {MATUGEN_CONFIG}: Valid TOML syntax", "SUCCESS")
        else:
            all_ok = False
    return all_ok


def main():
    if len(sys.argv) < 2 or sys.argv[1] in ["-h", "--help"]:
        print("Usage: safe_config_merger.py [COMMAND]")
        print("Commands:")
        print("  --backup              Create a pre-flight timestamped backup of user configs")
        print("  --merge               Safely merge keybinds, rules, and Matugen templates")
        print("  --rollback [PATH]     Revert to latest backup (or specified path)")
        print("  --verify              Check syntax of all configurations")
        sys.exit(0)

    cmd = sys.argv[1]

    if cmd == "--backup":
        create_backup()
    elif cmd == "--rollback":
        target = sys.argv[2] if len(sys.argv) > 2 else None
        success = rollback(target)
        sys.exit(0 if success else 1)
    elif cmd == "--verify":
        success = verify_all()
        sys.exit(0 if success else 1)
    elif cmd == "--merge":
        log("Starting safe configuration merge...", "INFO")
        backup_path = create_backup()
        m_matugen = merge_matugen()
        m_rules = merge_window_rules()
        m_keys = merge_keybinds()

        if m_matugen and m_rules and m_keys:
            log("All configurations merged successfully without syntax errors!", "SUCCESS")
            sys.exit(0)
        else:
            log("Merge encountered errors! Automatically executing rollback...", "ERROR")
            rollback(backup_path)
            sys.exit(1)
    else:
        log(f"Unknown command: {cmd}", "ERROR")
        sys.exit(1)


if __name__ == "__main__":
    main()

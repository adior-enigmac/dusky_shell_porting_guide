# Dusky Shell Porting Core Bundle

This bundle contains all core scripts, integration engines, dispatchers, and configuration templates required to port any desktop shell into Dusky Linux.

---

## 1. Directory Structure

```
bundle/
├── README.md
├── scripts/
│   ├── dusky_shell_switcher.py       # GTK LayerShell Universal GUI Switcher
│   ├── dusky_shell_switch.sh         # Headless CLI shell switcher backend
│   ├── safe_config_merger.py         # Non-destructive config merger, backup & rollback engine
│   ├── smart_launcher.sh             # Shell-aware launcher (Alt+Space)
│   ├── smart_control_center.sh       # Shell-aware control center (Super+Space)
│   ├── smart_lock.sh                 # Shell-aware lock screen (Super+M)
│   ├── smart_sidebar.sh              # Shell-aware sidebar / fullscreen (Super+Esc)
│   ├── smart_clipboard.sh            # Shell-aware clipboard manager (Super+V)
│   └── sync_wallpaper.sh             # Bidirectional wallpaper & Matugen synchronizer
└── templates/
    ├── inir-colors.json              # Matugen template for Material 3 tokens
    ├── serpantinum_matugen_colors.json.template # Matugen template for Serpantinum
    ├── matugen_config_snippet.toml   # Matugen 2.4.0 target configurations (MERGE ONLY)
    ├── hyprland_window_rules_snippet.lua # Hyprland layer rules (MERGE ONLY)
    └── hyprland_keybinds_snippet.lua # Hyprland Lua keybindings (MERGE ONLY)
```

---

## 2. Deploying Scripts

To deploy these scripts on a fresh or updated Dusky installation:
```bash
cp -f bundle/scripts/* ~/user_scripts/hypr/
chmod +x ~/user_scripts/hypr/*.sh ~/user_scripts/hypr/*.py
```

---

## 3. Script Reference & Responsibilities

| Script | Shortcut | Target / Responsibility |
| :--- | :--- | :--- |
| `dusky_shell_switcher.py` | `Super+Ctrl+S` | Interactive animated GTK GUI for switching shells with mouse or number keys (`1-5`). |
| `dusky_shell_switch.sh` | CLI | Shuts down active shell daemons cleanly, applies configuration overrides, starts target shell, and announces status. |
| `safe_config_merger.py` | CLI / Tool | Creates pre-flight backups, safely merges snippets without overwriting user configs, validates syntax, and triggers rollback if needed. |
| `smart_launcher.sh` | `Alt+Space` | Routes to Dusky Rofi (`dusky-run rofi`), Serpantinum launcher (`qs-applauncher`), or iNiR overview (`quickshell:overview`). |
| `smart_control_center.sh` | `Super+Space` | Routes to Dusky GTK Control Center, Serpantinum syspanel (`qs-master`), iNiR Waffle Action Center (`wactionCenter`), or iNiR control panel (`controlPanel`). |
| `smart_lock.sh` | `Super+M` | Routes to Hyprlock, Serpantinum lock (`lock.sh`), or iNiR session lock (`inir lock activate`). |
| `smart_sidebar.sh` | `Super+Esc` | Leaves fullscreen in Dusky native (`fullscreen 0`), toggles Serpantinum Quickactions sidebar (`floating`), or toggles iNiR right sidebar (`sidebarRight`). |
| `smart_clipboard.sh` | `Super+V` | Routes to Dusky Terminal/Rofi clipboard, Serpantinum spotlight clipboard (`qs-clipboard`), or iNiR clipboard panel (`clipboard`). |
| `sync_wallpaper.sh` | Hook / CLI | Syncs wallpaper path and triggers Matugen dynamic palettes across Dusky, Serpantinum, and iNiR simultaneously. |

---

## 4. Safe Non-Destructive Merging & Rollback Engine

> [!IMPORTANT]
> **NEVER OVERWRITE USER CONFIGURATION FILES**: Users have custom keybinds, rules, and dozens of Matugen application templates. Overwriting their files destroys their system configuration.
> Always use `safe_config_merger.py` or append only missing blocks!

### 4.1 Automatic Pre-Flight Backup
Before touching any files, create a backup:
```bash
python3 bundle/scripts/safe_config_merger.py --backup
```
All affected files are safely archived to `~/.config/dusky_multishell_backups/backup_<TIMESTAMP>/` with a complete `manifest.json`.

### 4.2 Automated Non-Destructive Merge
To safely merge all required snippets without clobbering existing configuration:
```bash
python3 bundle/scripts/safe_config_merger.py --merge
```
This tool:
1. Backs up user files automatically.
2. Appends missing Matugen targets to `~/.config/matugen/config.toml` without modifying existing templates.
3. Appends missing layer rules to `~/.config/hypr/edit_here/source/window_rules.lua`.
4. Appends missing smart dispatchers to `~/.config/hypr/edit_here/source/keybinds.lua`.
5. Validates Lua syntax via `luac -p` and TOML syntax via `tomllib`. If any error occurs, it triggers an instant automatic rollback!

### 4.3 Safe Manual or Emergency Rollback
If anything ever breaks or the user wishes to undo all changes:
```bash
python3 bundle/scripts/safe_config_merger.py --rollback
```
This restores all files from the latest backup, validates syntax, and reloads Hyprland cleanly.

---

## 5. Matugen Configuration Snippet

Add the targets in `templates/matugen_config_snippet.toml` to `~/.config/matugen/config.toml`. This ensures that when wallpaper changes occur via `skwd-wall-v2` or shell settings, dynamic palettes are synchronously generated for all running shells.

---

## 6. Hyprland Layer Rules

Append `templates/hyprland_window_rules_snippet.lua` to `~/.config/hypr/edit_here/source/window_rules.lua`.
> [!CAUTION]
> Always enforce the `inir_background_no_blur` exclusion rule. Never match `^quickshell.*` with `blur = true`, as that will blur the desktop wallpaper and cause screen capture tools to freeze.

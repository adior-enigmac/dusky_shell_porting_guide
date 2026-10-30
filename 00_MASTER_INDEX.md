# Dusky Linux Universal Multi-Shell Engine & Porting Guide

> [!IMPORTANT]
> ### 🤖 AUTONOMOUS SETUP DIRECTIVE FOR AI AGENTS & USERS
> **If you are an AI assistant tasked with setting up this multi-shell environment on a fresh Dusky Linux installation:**
> **START HERE: [00_AI_AGENT_AUTONOMOUS_INSTALLER_GUIDE.md](00_AI_AGENT_AUTONOMOUS_INSTALLER_GUIDE.md)**
> This installer guide provides a turnkey, zero-assumption bootstrap workflow with upstream clone links, package lists, physical deployment steps, bug fixes, test matrix, and final reporting instructions for **Ubaid**.

Welcome to the **Dusky Linux Multi-Shell Knowledge Base**. This repository serves as the definitive architecture reference, porting manual, core script bundle, and execution playbook for hosting multiple full-featured desktop shells simultaneously on Dusky Linux (Arch Linux + Hyprland Lua).

```
                      ┌────────────────────────────────────────┐
                      │    Dusky Linux Hybrid Core (Hyprland)   │
                      └───────────────────┬────────────────────┘
                                          │
            ┌─────────────────────────────┼─────────────────────────────┐
            ▼                             ▼                             ▼
   ┌──────────────────┐          ┌──────────────────┐          ┌──────────────────┐
   │   Dusky Native   │          │   Serpantinum    │          │       iNiR       │
   ├──────────────────┤          ├──────────────────┤          ├──────────────────┤
   │ • Waybar         │          │ • Quickshell     │          │ • Quickshell     │
   │ • Mako OSD/Notifs│          │   (root config)  │          │   (inir sub-config)
   │ • Rofi Launcher  │          │ • Custom OSD     │          │ • 3 Subshells:   │
   │ • Hyprlock       │          │ • Custom Lock    │          │   iRiS Island,   │
   │ • GTK CC         │          │ • Settings/Bar   │          │   Material ii,   │
   │                  │          │                  │          │   Waffle (Win11) │
   └──────────────────┘          └──────────────────┘          └──────────────────┘
            │                             │                             │
            └─────────────────────────────┼─────────────────────────────┘
                                          │
               ┌──────────────────────────┴──────────────────────────┐
               │         Universal Smart Dispatchers & IPC           │
               ├─────────────────────────────────────────────────────┤
               │ • Alt + Space   ──► smart_launcher.sh               │
               │ • Super + M     ──► smart_lock.sh                   │
               │ • Super + Space ──► smart_control_center.sh         │
               │ • Super + Esc   ──► smart_sidebar.sh                │
               │ • Super + V     ──► smart_clipboard.sh              │
               │ • Super+Ctrl+S  ──► dusky_shell_switcher.py (GUI)   │
               └─────────────────────────────────────────────────────┘
```

---

## Remote Git Repositories

When bootstrapping on a fresh Dusky installation, clone these staging repositories:
* **Serpantinum**: `https://github.com/ilyamiro/serpantinum.git`
* **iNiR**: `https://github.com/snowarch/iNiR`

---

## Directory Structure

```
/home/ubaid/Public/dusky_shell_porting_guide/
├── 00_AI_AGENT_AUTONOMOUS_INSTALLER_GUIDE.md        # ⭐ ZERO-TO-HERO AI BOOTSTRAP WORKFLOW
├── 00_MASTER_INDEX.md                              # This master database document
├── README.md                                       # Overview document
├── 01_UNIVERSAL_SWITCHER_ENGINE.md                 # State machine, process isolation, switcher GUI
├── 02_SMART_DISPATCHERS_AND_DYNAMIC_KEYBINDS.md    # Universal keyboard shortcuts dispatch
├── 03_WALLPAPER_AND_THEME_RULES.md                 # skwd-wall-v2 single-ownership rules
├── 04_AI_AGENT_PORTING_PLAYBOOK.md                 # 8-Phase step-by-step automated porting playbook for AI
├── 05_CHANGELOG.md                                 # Full historical change record
├── bundle/                                         # Ready-to-deploy core bundle
│   ├── README.md                                   # Bundle deployment guide
│   ├── scripts/                                    # Ready-to-use production dispatchers & switcher
│   │   ├── dusky_shell_switcher.py
│   │   ├── dusky_shell_switch.sh
│   │   ├── safe_config_merger.py
│   │   ├── smart_launcher.sh
│   │   ├── smart_control_center.sh
│   │   ├── smart_lock.sh
│   │   ├── smart_sidebar.sh
│   │   ├── smart_clipboard.sh
│   │   └── sync_wallpaper.sh
│   └── templates/                                  # Drop-in configuration snippets
│       ├── inir-colors.json
│       ├── serpantinum_matugen_colors.json.template
│       ├── matugen_config_snippet.toml
│       ├── hyprland_window_rules_snippet.lua
│       └── hyprland_keybinds_snippet.lua
├── assets/screenshots/                             # Verified high-res desktop captures
│   ├── dusky_native_desktop.png
│   ├── serpantinum_desktop.png
│   ├── serpantinum_control_center.png
│   ├── serpantinum_sidebar.png
│   ├── serpantinum_clipboard.png
│   ├── serpantinum_settings.png
│   ├── inir_iris_desktop.png
│   ├── inir_iris_control_center.png
│   ├── inir_iris_island_open.png
│   ├── inir_iris_clipboard.png
│   ├── inir_ii_desktop.png
│   ├── inir_ii_control_center.png
│   ├── inir_waffle_desktop.png
│   └── inir_waffle_action_center.png
├── serpantinum/                                    # Serpantinum-specific porting suite
│   ├── 00_PREREQUISITES_AND_DEPENDENCIES.md
│   ├── 00_SERPANTINUM_PORTING_MASTER.md
│   ├── 01_BAR_SWITCHER_GUIDE.md
│   ├── 02_MATUGEN_THEMING.md
│   ├── 03_HYPRLAND_CONFIG.md
│   ├── 04_CONTROL_CENTER_AND_FOCUS.md
│   ├── 05_DESKTOP_WIDGETS_AND_REDACTOR.md
│   ├── 06_DESKTOP_RIGHT_CLICK_MENU.md
│   ├── 07_BLUR_AND_SOLID_MODE.md
│   └── 08_TASKS_AND_ARCHITECTURE.md
└── inir/                                           # iNiR-specific porting suite
    ├── 00_PREREQUISITES_AND_DEPENDENCIES.md
    ├── 00_INIR_PORTING_MASTER.md
    ├── 01_SUBSHELLS_ARCHITECTURE.md
    ├── 02_IPC_AND_COMMANDS_REFERENCE.md
    ├── 03_WALLPAPER_AND_THEMING_COORDINATION.md
    └── 04_HYPRLAND_COMPATIBILITY_ENGINE.md
```

---

## Supported Desktop Shells & Visual Gallery

| Shell / Component | ID | Primary Stack | Live Screenshot |
|---|---|---|---|
| **Dusky Native Desktop** | `dusky` | Waybar + Mako + GTK + Rofi | [View Desktop](assets/screenshots/dusky_native_desktop.png) |
| **Serpantinum Desktop** | `serpantinum` | Quickshell (Root) | [View Desktop](assets/screenshots/serpantinum_desktop.png) |
| **Serpantinum Control Center** | `serpantinum` | Quickshell (`syspanel`) | [View Control Center](assets/screenshots/serpantinum_control_center.png) |
| **Serpantinum Quick Sidebar** | `serpantinum` | Quickshell (`floating`) | [View Sidebar](assets/screenshots/serpantinum_sidebar.png) |
| **Serpantinum Rich Clipboard** | `serpantinum` | Quickshell (`clipboard`) | [View Clipboard](assets/screenshots/serpantinum_clipboard.png) |
| **Serpantinum Settings App** | `serpantinum` | Quickshell (`settings`) | [View Settings](assets/screenshots/serpantinum_settings.png) |
| **iNiR iRiS Desktop** | `inir-iris` | Quickshell (`inir`) | [View Desktop](assets/screenshots/inir_iris_desktop.png) |
| **iNiR iRiS Control Center** | `inir-iris` | Quickshell (`controlPanel`) | [View Control Center](assets/screenshots/inir_iris_control_center.png) |
| **iNiR iRiS Island Open** | `inir-iris` | Quickshell (`iris-chassis`) | [View Island](assets/screenshots/inir_iris_island_open.png) |
| **iNiR Rich Clipboard** | `inir-iris` | Quickshell (`clipboard`) | [View Clipboard](assets/screenshots/inir_iris_clipboard.png) |
| **iNiR Material ii Desktop** | `inir-ii` | Quickshell (`inir`) | [View Desktop](assets/screenshots/inir_ii_desktop.png) |
| **iNiR Material ii Control Center** | `inir-ii` | Quickshell (`controlPanel`) | [View Control Center](assets/screenshots/inir_ii_control_center.png) |
| **iNiR Waffle Desktop** | `inir-waffle`| Quickshell (`inir`) | [View Desktop](assets/screenshots/inir_waffle_desktop.png) |
| **iNiR Waffle Action Center** | `inir-waffle`| Quickshell (`wactionCenter`)| [View Action Center](assets/screenshots/inir_waffle_action_center.png) |

---

## The Golden Rules of Dusky Multi-Shell Architecture

1. **Zero Filesystem Collisions**: Every shell occupies an isolated directory. Serpantinum uses root `~/.config/quickshell/`; iNiR uses `~/.config/quickshell/inir/`.
2. **Clean Process Teardown**: Switching shells terminates foreign daemons cleanly before starting the target shell.
3. **Transparent Wallpaper Pass-Through**: Never unload background canvas modules (`modules.background: false`) if desktop right-click menus or widgets live inside them. Render the canvas transparently (`showInternalStaticWallpaper = false` or `externalWallpaper = true`), allowing `skwd-wall-v2` to render the wallpaper while the shell captures right-clicks.
4. **Precision Hyprland Layer Rules**: Never use catch-all wildcard rules (`match = { namespace = "^quickshell.*" }` with `blur = true`). Blurring fullscreen backgrounds blurs the wallpaper, and blurring screenshot selectors freezes screen captures. Always separate interactive panels (blurred) from fullscreen backgrounds (`blur = false`).
5. **Dusky App Theming Autonomy**: Neuter foreign color scripts (`apply-gtk-theme.sh`, `20-gtk-kde.sh`, etc.) to prevent external shells from corrupting GTK3/GTK4 themes or Papirus icons.
6. **Dynamic Keybindings**: Never force foreign shell keybindings onto the user. Route all primary shortcuts (`Alt+Space`, `Super+Space`, `Super+Esc`, `Super+M`, `Super+V`) through smart dispatchers.
7. **Bidirectional Wallpaper Sync**: Sync wallpaper path and Matugen dynamic palettes across Dusky, Serpantinum, and iNiR simultaneously via `sync_wallpaper.sh`.
8. **Pre-Flight Backup & Safe Rollback**: Always create an archived backup before modifying user files. If any error or crash occurs, execute an immediate rollback (`safe_config_merger.py --rollback`).
9. **Non-Destructive Merging**: Never replace user config files (`keybinds.lua`, `window_rules.lua`, `matugen/config.toml`). Safely merge snippets without clobbering existing user configurations.
10. **Consult Ubaid's Journey Docs When Stuck**: If an AI agent encounters unhandled behavior or crashes, it should not guess. It should consult the subshell archives in `serpantinum/` and `inir/`, which document Ubaid's real-world engineering journey, root-cause analyses, and solutions.

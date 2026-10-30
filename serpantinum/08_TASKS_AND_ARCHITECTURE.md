# Dusky Universal Shell Switcher & Serpantinum Integration Tasks

**Architecture & Implementation Tracker**  
*Maintained automatically for Dusky Linux / Hyprland*

---

## 1. Master Architecture Vision

Dusky Linux serves as the unified base system (Hyprland compositor, GPU configuration, Matugen color generation, default applications, power/zram optimizations, and keybinding foundation).

Shell environments (Waybar/Mako/Rofi vs. Serpantinum Quickshell vs. future ported shells) are managed as **isolated, hot-swappable profiles**:
- **Dusky Native Profile**: Waybar, Mako (DBus notifications), Rofi (launcher & menus), native OSD, hyprlock.
- **Serpantinum Profile**: Quickshell Bar, Quickshell Notifications (`org.freedesktop.Notifications`), Quickshell OSD, Spotlight Launcher, Lockscreen, Desktop Widgets, Bottom Dock.
- **Future Shell Profiles**: Clean slot architecture for future desktop environments/shells.

To prevent dependency cycles (e.g., Rofi being killed when switching to a shell that replaces Rofi), the **Universal Shell Switcher** is built as an independent, lightweight, hardware-accelerated **Python GTK3 + GtkLayerShell** component styled dynamically via Matugen CSS.

---

## 2. Tasks Breakdown & Execution Status

| Task ID | Component | Description | Status |
| :--- | :--- | :--- | :--- |
| **TASK-01** | **Tasks & Tracking** | Create roadmap, task checklist, and architectural documentation in `09_TASKS_AND_ARCHITECTURE.md`. | 🟢 Completed |
| **TASK-02** | **Desktop Backdrop (skwd)** | Move Quickshell backdrop window to `WlrLayer.Bottom` in `shell.qml` so right-click works over `skwd-paper` and `awww`. | 🟢 Completed |
| **TASK-03** | **Hyprland Layer Blur** | Add `hl.layer_rule` for Quickshell namespaces in `window_rules.lua` (`quickshell`, `qs-master`, `desktopmenu`, etc.). | 🟢 Completed |
| **TASK-04** | **Serpantinum IPC & Binds** | Fix `serpantinum launch widgetredactor`, path resolution in `serpantinum` CLI, and keybinds in `keybinds.lua`. | 🟢 Completed |
| **TASK-05** | **Switch Controller Engine** | Upgrade `dusky_bar_switch.sh` into `dusky_shell_switch.sh`: full profile manager handling Waybar, Mako, Quickshell, Rofi. | 🟢 Completed |
| **TASK-06** | **Standalone Switcher GUI** | Build `dusky_shell_switcher.py` using GTK3 + GtkLayerShell with keyboard/mouse navigation, Matugen theming, and zero Rofi dependency. | 🟢 Completed |
| **TASK-07** | **Matugen CSS Integration** | Add `shell-switcher.css` template in `~/.config/matugen/templates/` and register in `config.toml`. | 🟢 Completed |
| **TASK-08** | **In-Shell Switcher Buttons** | Add shell switcher launcher button in Serpantinum's System Panel quick actions (`󱂬`) and Desktop Menu so users don't need dedicated keybinds. | 🟢 Completed |
| **TASK-09** | **Full Verification & Testing** | Verify blur toggle (`SUPER + ALT + .`), right-click on `skwd-wall`, profile switching between Dusky and Serpantinum, and IPC. | 🟢 Completed |
| **TASK-10** | **Comprehensive Documentation** | Update all documentation in `/home/ubaid/Public/serpantinum_dusky_docs/` with future shell porting guides (`10_FUTURE_SHELL_PORTING_GUIDE.md`). | 🟢 Completed |

---

## 3. Detailed Progress Log

- **2026-10-28 21:26**: Initialized architecture roadmap and tracking ledger.
- **2026-10-28 21:27**: Fixed desktop backdrop layer level in `shell.qml` from `Background` (Level 0) to `Bottom` (Level 1), guaranteeing right-click context menu intercept over `skwd-paper` and `awww-daemon`.
- **2026-10-28 21:28**: Configured 7 comprehensive Hyprland layer rules in `~/.config/hypr/edit_here/source/window_rules.lua` covering all Quickshell namespaces (`quickshell`, `qs-master`, `qs-dock`, `desktopmenu`, `sidemusic`, `dockappmenu`, `traymenu`, `osd`, `qs-popups`, `qs-applauncher`, `qs-clipboard`).
- **2026-10-28 21:30**: Resolved `serpantinum launch widgetredactor` and IPC path lookups in `/home/ubaid/.local/bin/serpantinum` and `qs_manager.sh`. Mapped conflict-free keybinds in `keybinds.lua`.
- **2026-10-28 21:34**: Created `dusky_shell_switch.sh` atomic multi-profile manager with mutex locking at `/tmp/dusky_shell_switch.lock`.
- **2026-10-28 21:35**: Implemented `dusky_shell_switcher.py` centered floating GTK3 + GtkLayerShell GUI dialog with keyboard/mouse support and zero dependency on Rofi.
- **2026-10-28 21:36**: Added Matugen template `~/.config/matugen/templates/shell-switcher.css` and registered in `config.toml`. Successfully generated dynamic palette.
- **2026-10-28 21:38**: Added `shellSwitcherBtn` (`󱂬`) to Serpantinum's System Panel quick actions and "Switch Desktop Shell" to Desktop Right-Click Menu.
- **2026-10-28 21:42**: Authored master guide `10_FUTURE_SHELL_PORTING_GUIDE.md` and updated all index and operational documentation.

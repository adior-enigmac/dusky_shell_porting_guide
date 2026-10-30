# Wallpaper & Theme Coordination Rules

On Dusky Linux, wallpaper management and Material You color generation are centralized services. Ported shells must adhere to strict coordination rules to prevent visual corruption, wallpaper flashing, or excessive GPU memory utilization.

---

## 1. Single Wallpaper Ownership Rule

> [!IMPORTANT]
> **Rule 1**: Only **one** process is permitted to draw on the Wayland background layer (`zwlr_layer_shell_v1` on `ZWLR_LAYER_SHELL_V1_LAYER_BACKGROUND`).

On Dusky Linux:
- The background layer is exclusively managed by **`skwd-wall-v2`** (via `skwd-wall-still` / `awww`).
- Any ported shell that draws a background `PanelWindow` or canvas must have that feature explicitly turned off.

### Configuration Settings per Shell:
- **Serpantinum**: In `~/.config/serpantinum/settings.json`, set `"wallpaper": { "enabled": false }`.
- **iNiR**: In `~/.config/inir/config.json`, set `"modules": { "background": false }`.

---

## 2. Universal Wallpaper Picker Wiring

> [!TIP]
> **Rule 2**: When a user clicks "Change Wallpaper" in any shell (e.g. desktop right-click menu, settings panel, or status bar button), it must open Dusky's standard wallpaper tool: **`skwd-wall-v2`**.

### Implementation Pattern:
Replace internal wallpaper picker invocations with:
```qml
Quickshell.execDetached(["bash", "-c", "skwd-wall-v2 2>/dev/null || skwd-wall 2>/dev/null"]);
```

---

## 3. Matugen Dynamic Theming Integration

Dusky Linux generates colors dynamically from the applied wallpaper using Matugen:
- Generated CSS: `~/.config/matugen/generated/`
- Shell Switcher CSS: `~/.config/matugen/generated/shell-switcher.css`
- Colors JSON: `~/.local/state/dusky/colors.json`

Ported shells should read colors from Dusky's Matugen state or inherit the active GTK/Qt theme colors (`Appearance.colors` in Quickshell).

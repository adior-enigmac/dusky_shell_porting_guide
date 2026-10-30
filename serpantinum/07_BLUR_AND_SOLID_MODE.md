# Blur and Solid Opacity Toggle Integration

## Overview

Dusky Linux features a visual mode toggle triggered via:
```
SUPER + ALT + .
```
Managed by [`/home/ubaid/user_scripts/hypr/hypr_blur_opacity_shadow_toggle.sh`](file:///home/ubaid/user_scripts/hypr/hypr_blur_opacity_shadow_toggle.sh).

This script switches the desktop between:
1. **Translucent & Blurred Mode**: Opacity 0.85 with Hyprland dual-kawase blur and box-shadows.
2. **100% Solid & Opaque Mode**: Opacity 1.0, zero translucency, blur disabled compositor-wide.

---

## Quickshell Dynamic Sync Architecture

To ensure Quickshell elements (Bar, Dock, Popouts, Menus, Widgets) synchronize with this toggle, a reactive file watcher and Hyprland layer rules are implemented:

```
                  [SUPER + ALT + .]
                          │
                          ▼
        hypr_blur_opacity_shadow_toggle.sh
        - Rewrites ~/.config/dusky/settings/opacity_blur (True / False)
        - Executes hyprctl decoration updates
        - Calls: quickshell ipc call theme syncElementOpacity
                          │
                          ▼
            ThemeBackend.qml FileView Watcher
            - Detects file change in real-time
            - If False: elementOpacity = 1.0, blurBackground = false
            - If True:  elementOpacity = 0.85, blurBackground = true
                          │
                          ▼
        Hyprland Layer Rules (window_rules.lua)
        - Matches namespaces: quickshell, qs-master, qs-dock, etc.
        - Compositor applies / bypasses blur filter
```

---

## 1. Hyprland Layer Rules (`window_rules.lua`)

Without explicit layer rules, Hyprland will NOT render blur behind Wayland layer-shell surfaces. The rules are placed in [`~/.config/hypr/edit_here/source/window_rules.lua`](file:///home/ubaid/.config/hypr/edit_here/source/window_rules.lua):

```lua
hl.layer_rule({
    name = "quickshell_bar_blur",
    match = { namespace = "^quickshell$" },
    blur = true,
    blur_popups = true,
    ignore_alpha = 0.0
})
```

---

## 2. In-QML Opacity Controller (`ThemeBackend.qml`)

In `~/.config/quickshell/singletons/theme/ThemeBackend.qml`:
- A `FileView` monitors `~/.config/dusky/settings/opacity_blur`.
- When `opacity_blur` is `False`, `elementOpacity` becomes `1.0`. All popouts, the bar, and cards render as solid color.
- When `opacity_blur` is `True`, `elementOpacity` becomes `0.85`, rendering translucent surfaces that pick up compositor blur.

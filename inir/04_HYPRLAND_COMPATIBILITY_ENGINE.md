# iNiR Hyprland Compatibility Engine

Although iNiR stands for "illogical Niri", the codebase originated from `end-4/dots-hyprland` and includes full native support for Hyprland.

---

## 1. Automatic Compositor Detection

Inside [`services/CompositorService.qml`](file:///home/ubaid/.config/quickshell/inir/services/CompositorService.qml):
```qml
readonly property string hyprlandSignature: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")

function detectCompositor() {
    if (hyprlandSignature && hyprlandSignature.length > 0) {
        isHyprland = true
        isNiri = false
        console.info("CompositorService: Detected Hyprland")
        Hyprland.refreshToplevels()
        return
    }
}
```
Whenever Hyprland is active, `CompositorService.isHyprland` evaluates to `true`.

---

## 2. Window & Workspace Tracking via `HyprlandData.qml`

[`services/HyprlandData.qml`](file:///home/ubaid/.config/quickshell/inir/services/HyprlandData.qml) communicates with Hyprland using asynchronous socket queries:
- `hyprctl clients -j`: Feeds active windows, titles, and classes to the dock and taskview.
- `hyprctl workspaces -j`: Feeds active workspaces to the bar and island pills.
- `hyprctl monitors -j`: Resolves display scales, resolutions, and orientations.
- `Hyprland.onRawEvent`: Reacts instantly to workspace changes, window creations, and closes without polling lag.

---

## 3. Layer Rules & Visual Styling in Hyprland

All iNiR windows declare namespaces prefixed with `quickshell:` (e.g. `quickshell:bar`, `quickshell:dock`, `quickshell:controlPanel`).

### Critical Rule Design: Panels Blur vs. Fullscreen Non-Blur
> [!WARNING]
> Never use a catch-all rule like `namespace = "^quickshell:.*$"` with `blur = true`. That blurs fullscreen background layers (`quickshell:background`, `quickshell:iris-background`, `quickshell:wBackground`, `quickshell:iiBackdrop`) causing the desktop wallpaper to blur, and blurs screen capture surfaces (`quickshell:regionSelector`, `quickshell:annotationEditor`) causing screenshot snipping to freeze or swallow input.

Configure targeted rules in `~/.config/hypr/edit_here/source/window_rules.lua`:
```lua
-- 1. Blur only interactive UI surfaces (bars, popups, launchers, docks)
hl.layer_rule({
    name = "inir_panels_blur",
    match = { namespace = "^quickshell:(bar|dock|iris-chassis|iris-menu|iris-sidebar.*|iris-notifications|iris-osd|iris-orbit-corner|iris-osk|iris-session|iris-settings|iris-studio|controlPanel|dashboard|equalizer|overlay|notificationPopup|onScreenDisplay|osk|overview|orbit|popup|m3-popup|polkit|session|settingsOverlay|settingsFocus|wAction.*|waction.*|wAltSwitcher|wClipboard|wNotification.*|wOnScreenDisplay|wSession|wStart.*|wTask.*|wWidgets|wallpaperLauncher|wallpaperSelector|coverflowSelector|workspaceStrip|clipboardPanel|verticalBar|cheatsheet|altSwitcher|closeConfirm|toast-manager|shellUpdate)$" },
    blur = true,
    xray = true,
    ignore_alpha = 0.54
})

-- 2. Strictly disable blur on fullscreen backgrounds and screenshot overlays
hl.layer_rule({
    name = "inir_background_no_blur",
    match = { namespace = "^quickshell:(background|iris-background|wBackground|iiBackdrop|regionSelector|annotationEditor|.*Backdrop|.*catcher|.*Scrim|iris-reserve.*|iris-wave|charging-ripple)$" },
    blur = false
})
```

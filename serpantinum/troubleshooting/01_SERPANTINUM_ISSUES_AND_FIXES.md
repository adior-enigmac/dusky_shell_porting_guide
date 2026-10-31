# Serpantinum Troubleshooting & Diagnostics Guide

This document contains the dedicated technical archive, root cause analyses, code-level patches, and verification workflows for all issues specific to the **Serpantinum** shell environment on Dusky Linux.

---

> [!WARNING]
> ### ⚠️ CRITICAL RULE: QUICKSHELL NEVER LIVE-RELOADS MODIFIED QML
> Quickshell compiles and caches QML documents in memory at launch.
> If you edit `Clipboard.qml`, `Bar.qml`, `settings.json`, or any controller on disk, **YOUR CHANGES WILL REMAIN 100% INACTIVE IN THE RUNNING SHELL** until Quickshell is completely terminated and restarted!
>
> **Mandatory Command to Apply Any QML/Config Edits**:
> ```bash
> # Restart Serpantinum cleanly to load the new QML code:
> ~/user_scripts/hypr/dusky_shell_switch.sh serpantinum
>
> # Verify new process PID and launch timestamp:
> qs list --all
> ```
> Never test a fix or assume a patch failed without restarting Quickshell first!

---

## Issue Quick Navigation

* [S-01: Clipboard Image Preview Collapsed (52px) by Default](#s-01-clipboard-image-preview-collapsed-by-default)
* [S-02: `settings.json` Wallpaper Object Breaks Matugen Theming](#s-02-settingsjson-wallpaper-object-breaks-matugen-theming)
* [S-03: Upstream Entry Point Casing (`Shell.qml` vs `shell.qml`)](#s-03-upstream-entry-point-casing-shellqml-vs-shellqml)
* [S-04: Clipboard Window Escape Key Handling](#s-04-clipboard-window-escape-key-handling)
* [S-05: Null Screen Fallback in Overlay Controllers](#s-05-null-screen-fallback-in-overlay-controllers)
* [S-06: Serpantinum Daemon Watchdog & Sleep Recovery](#s-06-serpantinum-daemon-watchdog--sleep-recovery)

For an active status table of all Serpantinum defects, see [00_SERPANTINUM_ISSUE_TRACKER.md](00_SERPANTINUM_ISSUE_TRACKER.md).

---

## S-01: Clipboard Image Preview Collapsed by Default & Scroll Hijacking

* **Status:** `[FIXED]`
* **Severity:** Medium (UX / Visual Bug & Navigation Loop)
* **Affected Components:** `~/.config/quickshell/clipboard/Clipboard.qml`
* **Symptoms:**
  - Image thumbnails render in a tiny, collapsed 52px card by default instead of an expanded preview.
  - Text items must remain collapsed (52px), while images must open into full previews (~250px) by default.
  - When scrolling or navigating with Up/Down arrow keys, the list was getting caught in an infinite jump loop between 5-6 items.

### Deep Root Cause Analysis
1. In `Clipboard.qml`, `clipDelegateWrapper` declared `itemExpanded` as `false` by default, clamping images to `baseH` (`s(52)`).
2. Simply setting `itemExpanded = true` inside the delegate caused `onItemExpandedChanged` to execute:
   ```qml
   clipList.currentIndex = index;
   clipList.ensureVisible(index, true);
   ```
   Whenever `ListView` recycled delegates during scrolling, every newly mounted image delegate hijacked `clipList.currentIndex` and forced `ensureVisible(index)`, throwing the scroll position into a continuous feedback loop and breaking arrow key navigation.
3. In `getItemBounds(idx)`, off-screen uninstantiated items defaulted to `defaultH` (`s(52)`), causing `ensureVisible()` to calculate incorrect scroll boundaries for 250px image items.
4. `clipCardCropImg` had `opacity: 1.0 - (itemExpandProgress * 0.85)`, leaving a 15% opacity ghost of the cropped image visible behind wide letterboxed screenshots.

### Solution & Patch Implementation

1. **Declarative Image Expansion without Scroll Hijacking:**
   In [`~/.config/quickshell/clipboard/Clipboard.qml`](file:///home/ubaid/.config/quickshell/clipboard/Clipboard.qml), declare separate user toggle states so images default to open and text defaults to closed, while removing scroll hijacking from `onItemExpandedChanged`:
   ```qml
   readonly property bool isImage: (typeof model !== "undefined" && model && model.type === "image")
   property bool userCollapsedImage: false
   property bool userExpandedText: false

   readonly property bool itemExpanded: isImage ? !userCollapsedImage : userExpandedText
   property real itemExpandProgress: itemExpanded ? 1.0 : 0.0
   Behavior on itemExpandProgress {
       enabled: !clipCardMa.draggingV
       NumberAnimation { duration: 250; easing.type: Easing.OutQuart }
   }

   onClipIdStringChanged: {
       userCollapsedImage = false;
       userExpandedText = false;
       dragX = 0;
   }

   function toggleExpand() {
       if (!clipDelegateCard.canExpand) return;
       clipList.currentIndex = index;
       if (isImage) {
           userCollapsedImage = !userCollapsedImage;
       } else {
           if (!userExpandedText && clipboardWindow.expandedClipId !== clipIdString) {
               clipboardWindow.fetchFullText(clipDelegateWrapper.clipIdString);
           }
           userExpandedText = !userExpandedText;
       }
       clipList.ensureVisible(index, true);
   }

   onItemExpandedChanged: {
       if (itemExpanded && !isImage && clipboardWindow.expandedClipId !== clipIdString) {
           clipboardWindow.fetchFullText(clipIdString);
       }
   }
   ```

2. **Accurate Bounds in `getItemBounds(idx)` for Arrow Navigation:**
   In `getItemBounds(idx)`, allocate `s(250)` for uninstantiated image entries so keyboard arrow navigation scrolls accurately:
   ```javascript
   let h = defaultH;
   let obj = itemAtIndex(i);
   if (obj) {
       h = obj.height;
   } else if (m.type === "image") {
       h = clipboardWindow.s(250);
   }
   ```

3. **Dynamic Layer-Shell Container Height in `targetLauncherHeight`:**
   ```javascript
   totalItemsHeight += (item.type === "image") ? s(250) : s(56);
   ```

4. **Zero Ghosting Opacity Crossfade:**
   ```qml
   opacity: Math.max(0.0, 1.0 - clipDelegateWrapper.itemExpandProgress)
   ```
           if (item) {
               if (item.pinned) hasPinned = true;
               else hasUnpinned = true;
               totalItemsHeight += (item.type === "image") ? s(250) : s(56);
           }
       }
       let sectionCount = (hasPinned ? 1 : 0) + (hasUnpinned ? 1 : 0);
       let sectionH = sectionCount === 2 ? s(48) : (sectionCount === 1 ? s(22) : 0);
       let calculated = s(70) + sectionH + totalItemsHeight;
       let maxAvailable = (clipboardWindow.screen ? clipboardWindow.screen.height : 800) * 0.85;
       return Math.min(calculated, maxAvailable);
   }
   ```

### Testing & Verification
```bash
# 1. Take a full-screen screenshot and push directly to clipboard
grim /tmp/test_clip.png && wl-copy -t image/png < /tmp/test_clip.png

# 2. Trigger Serpantinum smart clipboard
~/user_scripts/hypr/smart_clipboard.sh

# 3. Verification criteria:
# - The top entry displays the image in an expanded high-resolution card (~250px tall).
# - The aspect ratio is preserved without squishing or clipping.
# - The arrow button points upward (expanded state) and collapses smoothly when clicked.
# - The parent window adapts height dynamically without inner scrollbars clipping content.
```

---

## S-02: `settings.json` Wallpaper Object Breaks Matugen Theming

* **Status:** `[FIXED]`
* **Severity:** High (Theming Engine Regression)
* **Affected Components:** `~/.config/serpantinum/settings.json`, `~/.config/quickshell/singletons/theme/ThemeBackend.qml`, `~/user_scripts/hypr/dusky_shell_switch.sh`
* **Symptoms:**
  - Dynamic Matugen color palettes fail to apply to Serpantinum widgets.
  - Quickshell stdout logs a fatal uncaught JavaScript exception:
    `TypeError: Property 'trim' of object [object Object] is not a function` at `ThemeBackend.qml:271`.
  - Switching wallpapers updates Dusky and Hyprland, but Serpantinum stays locked to a fallback gray/violet color scheme.

### Deep Root Cause Analysis
Upstream Serpantinum expects the top-level `"wallpaper"` property in `settings.json` to be a plain string containing the path of the current wallpaper:
```javascript
let wp = themeConfig.wallpaper || Config.getSetting("wallpaper", "");
wp.trim();
```
Early porting documentation suggested setting `"wallpaper": { "enabled": false }` to disable Serpantinum's internal wallpaper canvas. When `ThemeBackend.qml` evaluated `Config.getSetting("wallpaper")`, it received a JavaScript `Object` instead of a `String`. Calling `.trim()` on an `Object` threw a fatal TypeError, aborting the entire theme reload routine. Furthermore, the `jq` filter in `dusky_shell_switch.sh` executed:
```bash
.wallpaper.enabled = false
```
When `.wallpaper` was already a string, `jq` halted with an error, failing to apply subsequent configuration modifications.

### Solution & Patch Implementation

1. **Store Wallpaper as a File Path String:**
   In `~/.config/serpantinum/settings.json`, point `"wallpaper"` to the current wallpaper path:
   ```json
   "wallpaper": "/home/ubaid/Pictures/Wallpapers/1016.jpg"
   ```
   *(Serpantinum's internal wallpaper rendering engine only mounts if `wallpaper.enabled === true`. Supplying a string path satisfies `ThemeBackend.qml` without launching the internal wallpaper layer!)*

2. **Sanitize `jq` Filter in Switcher Script:**
   In `~/user_scripts/hypr/dusky_shell_switch.sh`, guard the filter so strings are preserved:
   ```bash
   if (.wallpaper | type) == "object" then .wallpaper = "" else . end
   ```

### Testing & Verification
```bash
# 1. Inspect ~/.config/serpantinum/settings.json
jq '.wallpaper' ~/.config/serpantinum/settings.json
# Expected output: "/home/ubaid/Pictures/Wallpapers/..." (String, NOT Object)

# 2. Trigger wallpaper sync & Matugen regeneration
~/user_scripts/hypr/sync_wallpaper.sh

# 3. Check Quickshell log for clean theme dispatch
journalctl --user-unit quickshell -n 50 --no-pager | grep -i "ThemeBackend" || true
# Ensure NO 'Property trim of object is not a function' errors occur.
```

---

## S-03: Upstream Entry Point Casing (`Shell.qml` vs `shell.qml`)

* **Status:** `[FIXED]`
* **Severity:** Medium (Process Management / Teardown Bug)
* **Affected Components:** Upstream commits `a62f825+`, `dusky_shell_switch.sh`, `serpantinumd`
* **Symptoms:**
  - Cloning the latest Serpantinum upstream repository clones the main entry point to `src/quickshell/Shell.qml` (capitalized `S`).
  - Switching away from Serpantinum fails to terminate the running shell, leaving two shell instances running concurrently and fighting over layer-shell exclusive zones.

### Deep Root Cause Analysis
Process teardown scripts matched processes using `quickshell.*shell.qml` (lowercase). Because Linux process regexes are case-sensitive by default, running instances of `quickshell -p ~/.config/quickshell/quickshell/Shell.qml` were missed by `pkill`, resulting in lingering zombie processes.

### Solution & Patch Implementation
Update all kill commands and process matchers across all scripts to use case-insensitive character classes `[sS]hell\.qml`:
```bash
pkill -9 -f "quickshell.*[sS]hell\.qml" 2>/dev/null || true
pkill -9 -f "qs.*[sS]hell\.qml" 2>/dev/null || true
```

### Testing & Verification
```bash
# Verify process pattern matches live Serpantinum
pgrep -f "quickshell.*[sS]hell\.qml"
# Returns active PID cleanly.
```

---

## S-04: Clipboard Window Escape Key Handling

* **Status:** `[FIXED]`
* **Severity:** Low (UX Bug)
* **Affected Components:** `~/.config/quickshell/clipboard/Clipboard.qml`
* **Symptoms:**
  - Opening the clipboard via `SUPER+V` steals keyboard focus.
  - If the user clicks into an item row and then presses `Escape`, the clipboard panel fails to dismiss because focus left the search text field.

### Deep Root Cause Analysis
Escape key dismissal was bound only to `onAccepted` / `Keys.onEscapePressed` inside the inner search `TextInput`. Clicking an item or empty list space transferred focus to the ListView delegate, leaving no parent handler for the Escape event.

### Solution & Patch Implementation
In `Clipboard.qml`, attach a root window-level key handler to the top-level `PanelWindow`:
```qml
Keys.onEscapePressed: function(event) {
    closeClipboard();
    event.accepted = true;
}
```

### Testing & Verification
```bash
~/user_scripts/hypr/smart_clipboard.sh
# Click any item in the list, then press Escape. The panel dismisses immediately.
```

---

## S-05: Null Screen Fallback in Overlay Controllers

* **Status:** `[FIXED]`
* **Severity:** Medium (Crash Prevention)
* **Affected Components:** `ClipboardController.qml`, `LauncherController.qml`
* **Symptoms:**
  - Quickshell crashes or prints `WlLayerShell: surface has no output assigned` when toggling clipboard or application launcher immediately after waking up or when no window has focus.

### Deep Root Cause Analysis
Controllers assigned `controller.screen = getFocusedScreen();` without checking for `null`. Under Wayland, if focus is temporarily lost during display reconfiguration, `getFocusedScreen()` returns `null`. Assigning `null` to a LayerShell window drops the surface.

### Solution & Patch Implementation
Add robust fallback chaining:
```javascript
let target = getScreen(scr);
if (target) {
    controller.screen = target;
} else {
    let focused = getFocusedScreen();
    if (focused) {
        controller.screen = focused;
    } else if (typeof Quickshell !== "undefined" && Quickshell.screens && Quickshell.screens.length > 0) {
        controller.screen = Quickshell.screens[0];
    }
}
```

---

## S-06: Serpantinum Daemon Watchdog & Sleep Recovery

* **Status:** `[FIXED]`
* **Severity:** High (Session Stability)
* **Affected Components:** `~/.local/bin/serpantinumd`, `~/user_scripts/hypr/dusky_shell_switch.sh`
* **Symptoms:**
  - Closing the laptop lid or suspending the machine causes Serpantinum Quickshell to terminate and never return upon wakeup.

### Deep Root Cause Analysis
When the laptop display powers down via DPMS during sleep, Wayland output handles may temporarily invalidate. If Quickshell exits on output unbind, the original wrapper script exited, leaving the desktop shell-less after resume.

### Solution & Patch Implementation
In `~/.local/bin/serpantinumd`, wrap the shell execution inside an intelligent supervision loop:
```bash
while [ "$CLEANUP_DONE" = false ]; do
    quickshell -p "$QUICKSHELL_DIR/quickshell/Shell.qml" &
    QS_PID=$!
    wait $QS_PID || true
    
    # If terminated externally via SIGTERM or switched away, break loop
    if [ "$CLEANUP_DONE" = true ]; then
        break
    fi
    # If the process terminated unexpectedly while active, wait and respawn
    sleep 0.5
done
```
Combined with `dusky_shell_switch.sh --ensure-running` attached to the Hyprland lid open event, Serpantinum recovers instantaneously upon display wake.

---

## S-07: Upstream Updater Overwrite Trap & Permanent Neutralization

* **Status:** `[FIXED]`
* **Severity:** Critical (Configuration & Fix Destruction)
* **Affected Components:** `~/.config/quickshell/singletons/system/Updater.qml`, `~/.config/quickshell/scripts/updater.py`, `~/.config/quickshell/guide/AboutTab.qml`
* **Symptoms:**
  - Desktop update notification appears: *"Update available v2.3.1 - Serpantinum update available. Click to open guide."*
  - Opening the Guide -> About tab shows an enticing green **"Update"** button.
  - Clicking "Update" executes:
    ```bash
    kitty --hold bash -c 'eval "$(curl -fsSL https://raw.githubusercontent.com/ilyamiro/serpantinum/master/install/install.sh)"'
    ```
  - Running upstream `install.sh` overwrites `~/.config/quickshell/` and `~/.local/bin/serpantinumd`, completely obliterating:
    1. S-01 (Clipboard image preview and scroll navigation fixes)
    2. S-02 (Matugen string format and theming integration)
    3. S-06 (Sleep watchdog and supervision loop)
    4. Hyprland configuration files and custom Dusky keybindings.

### Deep Root Cause Analysis
Upstream Serpantinum has a background check timer (`periodicTimer` every 60 minutes) that runs `updater.py` to compare local version with GitHub master `version.txt`. If a higher version exists, `Updater.qml` dispatches a desktop notification with `notify-send`. The About tab renders an update panel whose `FillButton` invokes the raw online upstream installer. In a ported multi-shell environment, upstream installers MUST NEVER be run directly because they assume Serpantinum is the sole standalone desktop manager and wipe local customization patches.

### Solution & Patch Implementation
To permanently safeguard the installation:
1. **Neutralize Update Loop (`Updater.qml`):**
   - Force `root.updateAvailable = false`.
   - Make `reevaluateUpdate()`, `checkUpdate()`, `scheduleInitialCheck()`, and `sendNotification()` immediate no-ops.
   - Disable `startupTimer`, `initialDelayTimer`, and `periodicTimer` by setting `running: false`.
2. **Neutralize Python Probe (`updater.py`):**
   - Strip outbound HTTP requests to GitHub.
   - Return `{"local": local_ver, "remote": local_ver, "has_update": false, "last_notified": local_ver}`.
3. **Neutralize UI Trigger (`AboutTab.qml`):**
   - Force `property real updateTransitionProgress: 0.0`.
   - Hide `updatePanel` (`visible: false`).
   - Replace the dangerous `FillButton` with a disabled `ClickButton` badge:
     ```qml
     ClickButton {
         Layout.fillWidth: true
         Layout.preferredHeight: rootObj.s(38)
         horizontalPadding: rootObj.s(14)
         cornerRadius: ThemeBackend.borderRadius
         buttonText: "Managed by Dusky Multi-Shell"
         textFontSize: rootObj.s(12)
         buttonIcon: "󰌚"
         iconFontSize: rootObj.s(16)
         accentColor: ThemeBackend.surface0
         textColor: ThemeBackend.subtext0
         enabled: false
     }
     ```
4. **Update Version Identifiers:**
   - Update `version.txt` and `~/.local/state/serpantinum/version` to match current synchronized release (`2.3.1`).

### Testing & Verification
```bash
# Verify updater returns no updates available without network calls:
python3 ~/.config/quickshell/scripts/updater.py
# Expected output: {"local": "2.3.1", "remote": "2.3.1", "has_update": false, "last_notified": "2.3.1"}

# Verify AboutTab in Guide:
# Open Guide -> About tab: Update panel is hidden, no update notification sent.
```

---

## S-08: Upstream 2.3.1 Safe Improvements Cherry-Pick & Synchronization

* **Status:** `[FIXED]`
* **Severity:** Medium (Visual Polish & Binding Optimization)
* **Affected Components:** `GlassFill.qml`, `BarModule.qml`, `Floating.qml`, `NetworkPopup.qml`, `node_beams_clipped.frag`, `SideMusicPopout.qml`, `caching.sh`
* **Symptoms:**
  - Upstream released Serpantinum 2.3.1 containing bug fixes, visual improvements, and binding loop cleanups.
  - Naive upgrading would destroy port patches; manual surgical merging is required.

### Upstream Analysis & Cherry-Pick Strategy
1. **Binding Loop Cleanup (`GlassFill.qml`):**
   Added `property bool completed: false`. In `onParentChanged`, guarded with `if (completed) resolve();`, setting `completed = true` in `Component.onCompleted`. Eliminates initialization binding loops.
2. **Deferred Bar Backdrop Binding (`BarModule.qml`):**
   Converted `glassBackdropItem` from a static property to a deferred `Qt.binding(...)` evaluated in `Component.onCompleted`. Prevents premature evaluation warnings.
3. **Edge Handoff Timer (`Floating.qml`):**
   Added `handleEdgeHandoff()` with a 400ms timer to ensure smooth sidebar hide transitions without jitter.
4. **Multi-Bluetooth Lightning Beams Cap Raised to 16 (`NetworkPopup.qml` & Shader):**
   Upstream raised beam count from 8 to 16 (`beam8` through `beam15`). Merged QML properties and compiled `assets/shaders/vfx/node_beams_clipped.frag` into `node_beams_clipped.frag.qsb` via `/usr/lib/qt6/bin/qsb`.
5. **Side Music Popout Corner Radius Cleanliness (`SideMusicPopout.qml`):**
   Replaced 8 hardcoded `Rectangle` corner overlaps with dynamic `GlassFillets` and directional corner radii (`flatCorners`).
6. **Installer Dependency Skipped:**
   Upstream attempted to bundle `ski` file manager into launcher and screenshot scripts. Rejected for Dusky; kept authoritative `xdg-open` and desktop-standard file managers.
7. **Version Markers:**
   Synchronized `version.txt` and `~/.local/state/serpantinum/version` to `2.3.1`.

### Testing & Verification
```bash
# Verify shader compilation:
/usr/lib/qt6/bin/qsb --glsl "100 es,120,150" --hlsl 50 --msl 12 -o /tmp/test.qsb ~/.config/quickshell/assets/shaders/vfx/node_beams_clipped.frag
# Expected: exit code 0.

# Verify Quickshell running cleanly with single instance:
qs list --all
```

---

## Diagnostic Guide for AI Agents

When working with Serpantinum:
1. **Always read this document and [00_SERPANTINUM_ISSUE_TRACKER.md](00_SERPANTINUM_ISSUE_TRACKER.md) first before altering any Serpantinum QML files.**
2. When testing QML changes, run Quickshell directly in a test harness:
   ```bash
   quickshell -p ~/.config/quickshell/quickshell/Shell.qml
   ```
3. Whenever an issue is discovered or patched:
   - Append the full root cause, fix, and verification steps to this document.
   - Add the issue entry to `00_SERPANTINUM_ISSUE_TRACKER.md` with status `[FIXED]`.
   - Update the master tracker in `../../troubleshoot/00_MASTER_ISSUE_TRACKER.md`.
   - Commit changes cleanly so other developers and AI agents can sync via `git pull`.

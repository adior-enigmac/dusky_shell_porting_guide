# iNiR Troubleshooting & Diagnostics Guide

This document contains the dedicated technical archive, root cause analyses, code-level patches, and verification workflows for all issues specific to the **iNiR** multi-subshell environment (iRiS, Material ii, and Waffle) on Dusky Linux.

---

> [!WARNING]
> ### ⚠️ CRITICAL RULE: QUICKSHELL NEVER LIVE-RELOADS MODIFIED QML
> Quickshell compiles and caches QML documents in memory at launch.
> If you edit any QML file or script in `~/.config/quickshell/inir/`, **YOUR CHANGES WILL REMAIN 100% INACTIVE IN THE RUNNING SHELL** until Quickshell is completely terminated and restarted!
>
> **Mandatory Command to Apply Any iNiR Edits**:
> ```bash
> # Restart current iNiR subshell cleanly (e.g. iris):
> ~/user_scripts/hypr/dusky_shell_switch.sh iris
>
> # Verify new process PID and launch timestamp:
> qs list --all
> ```
> Never test a fix or assume a patch failed without restarting Quickshell first!

---

## Issue Quick Navigation

* [I-01: iNiR CLI Launcher Exits Silently with Code 1 on Hyprland](#i-01-inir-cli-launcher-exits-silently-with-code-1-on-hyprland)
* [I-02: Missing Material Symbols Fonts Render Icons as Raw Text](#i-02-missing-material-symbols-fonts-render-icons-as-raw-text)
* [I-03: Toplevel Lifecycle Segfault 11 on Window Close](#i-03-toplevel-lifecycle-segfault-11-on-window-close)
* [I-04: Island Popup Lock Button Inoperative](#i-04-island-popup-lock-button-inoperative)
* [I-05: Theme Script Lockdown (Preventing GTK/KDE Overwrites)](#i-05-theme-script-lockdown-preventing-gtk-kde-overwrites)

For an active status table of all iNiR defects, see [00_INIR_ISSUE_TRACKER.md](00_INIR_ISSUE_TRACKER.md).

---

## I-01: iNiR CLI Launcher Exits Silently with Code 1 on Hyprland

* **Status:** `[FIXED]`
* **Severity:** Critical (Blocks Execution)
* **Affected Components:** `~/.config/quickshell/inir/scripts/inir`
* **Symptoms:**
  - Running `inir run` or invoking `dusky_shell_switch.sh iris` fails silently.
  - The script terminates immediately with exit code 1; no Quickshell process is launched.

### Deep Root Cause Analysis
At the start of `~/.config/quickshell/inir/scripts/inir`, the script declares `set -euo pipefail`.
Inside the function `apply_niri_app_environment()`:
```bash
apply_niri_app_environment() {
    ...
    [[ -n "$value" ]] && export "$key=$value"
}
```
When running on **Hyprland** (or any compositor other than Niri), `$value` is empty. Under bash's `set -e`, a conditional `[[ -n "" ]]` evaluates to non-zero (false) as the final statement of a function, triggering an immediate fatal script abort.

### Solution & Patch Implementation
In [`~/.config/quickshell/inir/scripts/inir`](file:///home/ubaid/.config/quickshell/inir/scripts/inir), ensure `apply_niri_app_environment` always exits with code 0:
```bash
apply_niri_app_environment() {
    ...
    [[ -n "$value" ]] && export "$key=$value"
    return 0
}
```

### Testing & Verification
```bash
# Run the inir launcher directly to test exit code
~/.config/quickshell/inir/scripts/inir env
echo "Exit code: $?"
# Expected output: Exit code: 0
```

---

## I-02: Missing Material Symbols Fonts Render Icons as Raw Text

* **Status:** `[FIXED]`
* **Severity:** Medium (Visual / UI Bug)
* **Affected Components:** `~/.local/share/fonts/MaterialSymbols/`, iRiS Island, Material ii, Waffle
* **Symptoms:**
  - Buttons and status indicators in iNiR display plain English text names like `brightness_5`, `volume_up`, `network_wifi`, or `power_settings_new` instead of graphical icons.
  - UI layouts appear stretched or misaligned due to long text strings.

### Deep Root Cause Analysis
Upstream iNiR relies heavily on Google's **Material Symbols Rounded** and **Material Symbols Outlined** variable fonts. Standard Linux font packages (`ttf-nerd-fonts-symbols`, `noto-fonts`) do not provide the ligature mapping for Material Symbols icon names.

### Solution & Patch Implementation
Deploy the official Material Symbols TrueType font files to the user's font directory (requires **no root privileges**):
```bash
mkdir -p ~/.local/share/fonts/MaterialSymbols/
cp /path/to/bundle/assets/MaterialSymbolsRounded.ttf ~/.local/share/fonts/MaterialSymbols/
cp /path/to/bundle/assets/MaterialSymbolsOutlined.ttf ~/.local/share/fonts/MaterialSymbols/
fc-cache -f ~/.local/share/fonts
```

### Testing & Verification
```bash
fc-list : family | grep "Material Symbols"
# Output must list:
# Material Symbols Rounded
# Material Symbols Outlined
```

---

## I-03: Toplevel Lifecycle Segfault 11 on Window Close

* **Status:** `[FIXED]`
* **Severity:** High (Crash Bug)
* **Affected Components:** `~/.config/quickshell/inir/services/CompositorService.qml`, `TaskbarApps.qml`, `AppSearch.qml`
* **Symptoms:**
  - When closing an application window (`SUPER+Q`), Quickshell crashes with:
    `Segmentation fault (core dumped)` in `QQmlMetaType::propertyCache`.

### Deep Root Cause Analysis
In `CompositorService.qml`, window list updates mapping `ordered.map(x => x.wayland)` accessed references to toplevel Wayland surfaces that were already destroyed by Hyprland during the same event loop tick. Attempting to evaluate properties on dangling C++ pointers caused Qt/QML meta-type property resolution to segfault.

### Solution & Patch Implementation
1. In `CompositorService.qml`, filter `ordered.map(x => x.wayland)` against the live set from `ToplevelManager`:
   ```javascript
   let liveWayland = ordered
       .map(x => x.wayland)
       .filter(w => w !== null && typeof w !== "undefined" && ToplevelManager.toplevels.includes(w));
   ```
2. Wrap window identity lookups in `try / catch` blocks in `AppSearch.resolveWindowIdentity` and `TaskbarApps.qml`.

### Testing & Verification
```bash
# Launch multiple terminal windows and close them rapidly
for i in {1..5}; do foot & done
sleep 1
killall foot
# Quickshell process must stay alive and maintain island / taskbar rendering without crashing.
```

---

## I-04: Island Popup Lock Button Inoperative

* **Status:** `[FIXED]`
* **Severity:** Medium (Functionality Bug)
* **Affected Components:** `Session.qml`, `smart_lock.sh`
* **Symptoms:**
  - Clicking the lock icon in the iRiS Dynamic Island popup does not activate the screen lock.

### Deep Root Cause Analysis
Upstream `Session.lock()` dispatches `inir lock activate`. On Hyprland, the Niri session lock backend is absent, causing the action to drop silently without notifying the user or invoking a screen locker.

### Solution & Patch Implementation
Direct `inir lock activate` or `Session.lock()` to trigger Dusky's unified lock script:
```bash
ln -sf ~/user_scripts/hypr/smart_lock.sh ~/.local/bin/inir-lock
```
Or ensure `~/.local/bin/inir` intercepts `lock activate` and routes directly to `loginctl lock-session` / `smart_lock.sh`.

---

## I-05: Theme Script Lockdown (Preventing GTK/KDE Overwrites)

* **Status:** `[FIXED]`
* **Severity:** Medium (Theme Regression Prevention)
* **Affected Components:** `~/.config/quickshell/inir/scripts/colors/apply-gtk-theme.sh`, `scripts/colors/modules/20-gtk-kde.sh`
* **Symptoms:**
  - Switching to an iNiR subshell rewrites GTK and KDE color schemes with static colors, breaking Dusky's global dynamic Matugen palette.

### Deep Root Cause Analysis
Upstream iNiR packages autonomous GTK/KDE theming scripts that execute automatically on shell startup. On Dusky Linux, `matugen` and `skwd-wall-v2` are the single source of truth for theming.

### Solution & Patch Implementation
Neutralize external theming scripts by prepending `exit 0`:
```bash
sed -i '1s/^/exit 0\n/' ~/.config/quickshell/inir/scripts/colors/apply-gtk-theme.sh
sed -i '1s/^/exit 0\n/' ~/.config/quickshell/inir/scripts/colors/modules/20-gtk-kde.sh
```

---

## Diagnostic Guide for AI Agents

When working with iNiR:
1. **Always read this document and [00_INIR_ISSUE_TRACKER.md](00_INIR_ISSUE_TRACKER.md) first before modifying iNiR files.**
2. When testing subshells:
   ```bash
   # Test iRiS
   ~/user_scripts/hypr/dusky_shell_switch.sh iris
   # Test Material ii
   ~/user_scripts/hypr/dusky_shell_switch.sh material
   # Test Waffle
   ~/user_scripts/hypr/dusky_shell_switch.sh waffle
   ```
3. Whenever an issue is discovered or patched:
   - Append the full root cause, fix, and verification steps to this document.
   - Add the issue entry to `00_INIR_ISSUE_TRACKER.md` with status `[FIXED]`.
   - Update the master tracker in `../../troubleshoot/00_MASTER_ISSUE_TRACKER.md`.
   - Commit cleanly for team synchronization via Git.

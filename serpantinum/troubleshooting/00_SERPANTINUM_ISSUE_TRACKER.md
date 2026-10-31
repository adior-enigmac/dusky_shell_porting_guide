# Serpantinum Shell Issue Tracker

This document maintains an active record of all tracked bugs, quirks, and regressions specific to **Serpantinum** within the Dusky Linux multi-shell ecosystem.

---

## Status Legend
* `[FIXED]`: Fully root-caused, patched in the codebase/scripts, and verified live.
* `[WORKAROUND]`: Documented temporary workaround while waiting for upstream resolution.
* `[INVESTIGATING]`: Actively under diagnosis.

---

## Issue Registry

| Issue ID | Severity | Component | Symptom | Status | Resolution | Detailed Diagnostic |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **S-01** | Medium | `Clipboard.qml` | Image previews collapsed to 52px; window too small | `[FIXED]` | Defaulted `itemExpanded` to `true` for images; dynamic `s(250)` row height | [Diagnostic S-01](01_SERPANTINUM_ISSUES_AND_FIXES.md#s-01-clipboard-image-preview-collapsed-by-default) |
| **S-02** | High | `settings.json` / Theme | `TypeError: Property 'trim' ...` breaks Matugen | `[FIXED]` | Keep wallpaper as string path; fixed `jq` filter in switcher | [Diagnostic S-02](01_SERPANTINUM_ISSUES_AND_FIXES.md#s-02-settingsjson-wallpaper-object-breaks-matugen-theming) |
| **S-03** | Medium | Process Management | Upstream `Shell.qml` casing fails process teardown | `[FIXED]` | Applied case-insensitive regex `[sS]hell\.qml` across all scripts | [Diagnostic S-03](01_SERPANTINUM_ISSUES_AND_FIXES.md#s-03-upstream-entry-point-casing-shellqml-vs-shellqml) |
| **S-04** | Low | `Clipboard.qml` | Escape key ignored when list item is focused | `[FIXED]` | Added window-level `Keys.onEscapePressed` to root `PanelWindow` | [Diagnostic S-04](01_SERPANTINUM_ISSUES_AND_FIXES.md#s-04-clipboard-window-escape-key-handling) |
| **S-05** | Medium | `Controllers/*.qml` | LayerShell crash when focused screen is null | `[FIXED]` | Added fallback chain to `Quickshell.screens[0]` | [Diagnostic S-05](01_SERPANTINUM_ISSUES_AND_FIXES.md#s-05-null-screen-fallback-in-overlay-controllers) |
| **S-06** | High | `serpantinumd` | Shell quits on lid close / display sleep | `[FIXED]` | Wrapped Quickshell in supervision loop + `--ensure-running` watchdog | [Diagnostic S-06](01_SERPANTINUM_ISSUES_AND_FIXES.md#s-06-serpantinum-daemon-watchdog--sleep-recovery) |

---

## Regression Testing Matrix

Run these commands to verify that none of the fixed issues have regressed:

```bash
# 1. Test S-01: Clipboard image preview height
grim /tmp/test_clip.png && wl-copy -t image/png < /tmp/test_clip.png
~/user_scripts/hypr/smart_clipboard.sh
# Expected: Image renders fully expanded with aspect ratio preserved.

# 2. Test S-02: Matugen wallpaper path validation
jq -e '.wallpaper | type == "string"' ~/.config/serpantinum/settings.json
# Expected: Returns exit code 0.

# 3. Test S-03: Process matching pattern
pgrep -f "quickshell.*[sS]hell\.qml"
# Expected: Finds running process regardless of casing.

# 4. Test S-06: Supervision daemon status
pgrep -f "serpantinumd"
# Expected: Returns active supervisor PID.
```

---

## Guidelines for AI Agents
- When finding any new bug in Serpantinum, assign the next available ID (`S-07`, `S-08`, etc.).
- Add the detailed technical writeup in [01_SERPANTINUM_ISSUES_AND_FIXES.md](01_SERPANTINUM_ISSUES_AND_FIXES.md).
- Add the issue entry to the table above.
- Also mirror the issue entry in the master tracker at `../troubleshoot/00_MASTER_ISSUE_TRACKER.md`.

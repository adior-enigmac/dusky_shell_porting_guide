# iNiR Shell Issue Tracker

This document maintains an active record of all tracked bugs, quirks, and regressions specific to **iNiR** (iRiS, Material ii, and Waffle) within the Dusky Linux multi-shell ecosystem.

---

## Status Legend
* `[FIXED]`: Fully root-caused, patched in the codebase/scripts, and verified live.
* `[WORKAROUND]`: Documented temporary workaround while waiting for upstream resolution.
* `[INVESTIGATING]`: Actively under diagnosis.

---

## Issue Registry

| Issue ID | Severity | Component | Symptom | Status | Resolution | Detailed Diagnostic |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **I-01** | Critical | `scripts/inir` | Launcher exits with code 1 on Hyprland | `[FIXED]` | Added `return 0` to `apply_niri_app_environment()` | [Diagnostic I-01](01_INIR_ISSUES_AND_FIXES.md#i-01-inir-cli-launcher-exits-silently-with-code-1-on-hyprland) |
| **I-02** | Medium | Font Rendering | Icon names displayed as raw text strings | `[FIXED]` | Deployed Material Symbols Rounded & Outlined to `~/.local/share/fonts/` | [Diagnostic I-02](01_INIR_ISSUES_AND_FIXES.md#i-02-missing-material-symbols-fonts-render-icons-as-raw-text) |
| **I-03** | High | `CompositorService` | Crash with Segfault 11 on window close | `[FIXED]` | Live-toplevel filter against `ToplevelManager` + try/catch guards | [Diagnostic I-03](01_INIR_ISSUES_AND_FIXES.md#i-03-toplevel-lifecycle-segfault-11-on-window-close) |
| **I-04** | Medium | `Session.qml` | Island popup lock button does not lock screen | `[FIXED]` | Routed `inir lock activate` to `smart_lock.sh` / `loginctl lock-session` | [Diagnostic I-04](01_INIR_ISSUES_AND_FIXES.md#i-04-island-popup-lock-button-inoperative) |
| **I-05** | Medium | Theming Scripts | External scripts overwrite Dusky GTK/KDE themes | `[FIXED]` | Prepend `exit 0` to `apply-gtk-theme.sh` & `20-gtk-kde.sh` | [Diagnostic I-05](01_INIR_ISSUES_AND_FIXES.md#i-05-theme-script-lockdown-preventing-gtk-kde-overwrites) |

---

## Regression Testing Matrix

Run these commands to verify that none of the fixed issues have regressed:

```bash
# 1. Test I-01: CLI Launcher exit status
~/.config/quickshell/inir/scripts/inir env
# Expected: Exit code 0

# 2. Test I-02: Material Symbols font registration
fc-list : family | grep "Material Symbols"
# Expected: Matches 'Material Symbols Rounded' and 'Material Symbols Outlined'

# 3. Test I-05: GTK script lockdown
head -n 2 ~/.config/quickshell/inir/scripts/colors/apply-gtk-theme.sh
# Expected: Shows 'exit 0'
```

---

## Guidelines for AI Agents
- When finding any new bug in iNiR, assign the next available ID (`I-06`, `I-07`, etc.).
- Add the detailed technical writeup in [01_INIR_ISSUES_AND_FIXES.md](01_INIR_ISSUES_AND_FIXES.md).
- Add the issue entry to the table above.
- Also mirror the issue entry in the master tracker at `../../troubleshoot/00_MASTER_ISSUE_TRACKER.md`.

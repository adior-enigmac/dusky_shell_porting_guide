# iNiR Troubleshooting Knowledge Base

Welcome to the dedicated troubleshooting archive for the **iNiR** multi-subshell environment (iRiS Dynamic Island, Material ii, and Waffle Win11) on Dusky Linux.

This directory contains in-depth root cause investigations, surgical code patches, CLI workarounds, font configurations, and verification procedures for all issues identified in iNiR.

---

## Directory Inventory

1. [00_INIR_ISSUE_TRACKER.md](00_INIR_ISSUE_TRACKER.md):
   Active status registry of all iNiR defects (`I-01` to `I-05`), regression test commands, and severity ratings.
2. [01_INIR_ISSUES_AND_FIXES.md](01_INIR_ISSUES_AND_FIXES.md):
   Exhaustive diagnostic breakdowns, root causes, bash and QML patches, font fixes, and live verification commands.

---

## Tracked Issues Summary

| Issue ID | Severity | Component | Summary | Status |
| :--- | :--- | :--- | :--- | :--- |
| **I-01** | Critical | `scripts/inir` | CLI Launcher exits with code 1 on Hyprland (`apply_niri_app_environment`) | `[FIXED]` |
| **I-02** | Medium | Font Rendering | Icon names displayed as raw text (missing Material Symbols TTF) | `[FIXED]` |
| **I-03** | High | `CompositorService` | Crash with Segfault 11 (`propertyCache`) on window close | `[FIXED]` |
| **I-04** | Medium | `Session.qml` | Island popup lock button does not lock screen | `[FIXED]` |
| **I-05** | Medium | Theming Scripts | External scripts overwrite Dusky GTK/KDE themes | `[FIXED]` |

---

## AI Agent Directives
- **MANDATORY RESTART RULE**: Quickshell does NOT live-reload QML files when changed on disk! After applying ANY fix or editing any QML file, you MUST restart the current iNiR subshell cleanly:
  ```bash
  ~/user_scripts/hypr/dusky_shell_switch.sh iris
  ```
- Always check [00_INIR_ISSUE_TRACKER.md](00_INIR_ISSUE_TRACKER.md) before attempting modifications to iNiR files.
- When fixing any new issue in iNiR:
  1. Append the detailed diagnostic and patch to [01_INIR_ISSUES_AND_FIXES.md](01_INIR_ISSUES_AND_FIXES.md).
  2. Register the issue in [00_INIR_ISSUE_TRACKER.md](00_INIR_ISSUE_TRACKER.md) with status `[FIXED]`.
  3. Mirror the issue in the global tracker at `../../troubleshoot/00_MASTER_ISSUE_TRACKER.md`.

# Serpantinum Troubleshooting Knowledge Base

Welcome to the dedicated troubleshooting archive for the **Serpantinum** shell environment on Dusky Linux.

This directory contains in-depth root cause investigations, surgical code patches, QML workarounds, and verification procedures for all issues identified in Serpantinum.

---

## Directory Inventory

1. [00_SERPANTINUM_ISSUE_TRACKER.md](00_SERPANTINUM_ISSUE_TRACKER.md):
   Active status registry of all Serpantinum defects (`S-01` to `S-06`), regression test commands, and severity ratings.
2. [01_SERPANTINUM_ISSUES_AND_FIXES.md](01_SERPANTINUM_ISSUES_AND_FIXES.md):
   Exhaustive diagnostic breakdowns, root causes, QML patches, and live verification commands.

---

## Tracked Issues Summary

| Issue ID | Severity | Component | Summary | Status |
| :--- | :--- | :--- | :--- | :--- |
| **S-01** | Medium | `Clipboard.qml` | Image previews collapsed (52px); dynamic height missing | `[FIXED]` |
| **S-02** | High | `settings.json` / Theme | Wallpaper JSON object breaks Matugen `.trim()` | `[FIXED]` |
| **S-03** | Medium | Process Management | Upstream `Shell.qml` casing prevents clean teardown | `[FIXED]` |
| **S-04** | Low | `Clipboard.qml` | Escape key ignored when clicking outside search bar | `[FIXED]` |
| **S-05** | Medium | Overlay Controllers | Null screen pointer causes LayerShell crash | `[FIXED]` |
| **S-06** | High | `serpantinumd` | Shell quits on lid close / display sleep | `[FIXED]` |

---

## AI Agent Directives
- **MANDATORY RESTART RULE**: Quickshell does NOT live-reload QML files when changed on disk! After applying ANY fix or editing any QML file, you MUST restart Serpantinum cleanly:
  ```bash
  ~/user_scripts/hypr/dusky_shell_switch.sh serpantinum
  ```
- Always check [00_SERPANTINUM_ISSUE_TRACKER.md](00_SERPANTINUM_ISSUE_TRACKER.md) before attempting manual modifications to Serpantinum QML files.
- When fixing any new issue in Serpantinum:
  1. Append the detailed diagnostic and patch to [01_SERPANTINUM_ISSUES_AND_FIXES.md](01_SERPANTINUM_ISSUES_AND_FIXES.md).
  2. Register the issue in [00_SERPANTINUM_ISSUE_TRACKER.md](00_SERPANTINUM_ISSUE_TRACKER.md) with status `[FIXED]`.
  3. Mirror the issue in the global tracker at `../../troubleshoot/00_MASTER_ISSUE_TRACKER.md`.

# Dusky Multi-Shell Troubleshooting Knowledge Base & Master Issue Tracker

This directory is the authoritative diagnostic database and resolution log for the Dusky Multi-Shell Ecosystem. It records every discovered quirk, crash, protocol conflict, and edge case across all supported shells, along with battle-tested fixes and test commands.

---

## 🤖 Strict Directive for AI Assistants & Engineers

> [!IMPORTANT]
> **COLLABORATIVE KNOWLEDGE BASE PROTOCOL**:
> This repository is designed to be shared across users and AI agents via Git (`git push` / `git pull`).
> You are NOT just a consumer of this documentation; you are an active maintainer.
>
> Whenever you encounter ANY bug, warning, crash, or unexpected behavior on any machine:
> 1. **Search First**:
>    - For Global / System / Compositor issues: Read [`01_GLOBAL_AND_SYSTEM_ISSUES.md`](01_GLOBAL_AND_SYSTEM_ISSUES.md).
>    - For Serpantinum issues: Read [`../serpantinum/troubleshooting/01_SERPANTINUM_ISSUES_AND_FIXES.md`](../serpantinum/troubleshooting/01_SERPANTINUM_ISSUES_AND_FIXES.md) and [`../serpantinum/troubleshooting/00_SERPANTINUM_ISSUE_TRACKER.md`](../serpantinum/troubleshooting/00_SERPANTINUM_ISSUE_TRACKER.md).
>    - For iNiR issues (iRiS, Material ii, Waffle): Read [`../inir/troubleshooting/01_INIR_ISSUES_AND_FIXES.md`](../inir/troubleshooting/01_INIR_ISSUES_AND_FIXES.md) and [`../inir/troubleshooting/00_INIR_ISSUE_TRACKER.md`](../inir/troubleshooting/00_INIR_ISSUE_TRACKER.md).
>    - To check overall status: Inspect [`00_MASTER_ISSUE_TRACKER.md`](00_MASTER_ISSUE_TRACKER.md).
> 2. **Apply the Verified Solution**: Follow the exact steps, patches, and commands documented in this database.
> 3. **If You Discover a New Issue or Edge Case**:
>    - **Root-Cause It**: Identify the exact file, line number, Wayland protocol, or bash pipe causing the failure.
>    - **Fix & Test It**: Apply a minimal surgical fix and verify it live using the test matrix.
>    - **Document in Respected Folders**:
>      - If the issue is **Global/System-wide**, document it in `troubleshoot/01_GLOBAL_AND_SYSTEM_ISSUES.md`.
>      - If the issue is **Shell-specific**, document it inside that shell's `troubleshooting/` folder (`serpantinum/troubleshooting/01_SERPANTINUM_ISSUES_AND_FIXES.md` or `inir/troubleshooting/01_INIR_ISSUES_AND_FIXES.md`), and update that shell's `00_..._ISSUE_TRACKER.md`.
>      - Always register the new issue in `troubleshoot/00_MASTER_ISSUE_TRACKER.md` with status `[FIXED]`.
>    - **Clean Up**: Never leave one-off raw report files in the repository root. Integrate all findings directly into this structured knowledge base.

---

## Troubleshooting Knowledge Base Architecture

```
dusky_shell_porting_guide/
├── troubleshoot/                                  # GLOBAL TROUBLESHOOTING & MASTER INDEX
│   ├── README.md                                  # This protocol guide & architecture overview
│   ├── 00_MASTER_ISSUE_TRACKER.md                 # Complete cross-shell status table (G-xx, S-xx, I-xx)
│   └── 01_GLOBAL_AND_SYSTEM_ISSUES.md             # Cross-shell, Hyprland, systemd, power & sleep issues
│
├── serpantinum/                                   # SERPANTINUM SHELL DIRECTORY
│   ├── troubleshooting/                           # Dedicated Serpantinum Troubleshooting Folder
│   │   ├── README.md                              # Troubleshooting overview
│   │   ├── 00_SERPANTINUM_ISSUE_TRACKER.md        # Serpantinum status tracker (S-01 through S-06)
│   │   └── 01_SERPANTINUM_ISSUES_AND_FIXES.md     # In-depth QML fixes & clipboard patches
│   └── ...                                        # Architecture guides, playbooks & configs
│
└── inir/                                          # INIR SHELL DIRECTORY (iRiS, Material ii, Waffle)
    ├── troubleshooting/                           # Dedicated iNiR Troubleshooting Folder
    │   ├── README.md                              # Troubleshooting overview
    │   ├── 00_INIR_ISSUE_TRACKER.md               # iNiR status tracker (I-01 through I-05)
    │   └── 01_INIR_ISSUES_AND_FIXES.md            # In-depth CLI traps, font fixes & patches
    └── ...                                        # Architecture guides, playbooks & configs
```

---

## Quick Navigation

| Scope | Description | Primary Document |
| :--- | :--- | :--- |
| **Global & System** | Laptop lid sleep, Wayland lock collisions, autostart, Matugen templates, wallpaper sync | [01_GLOBAL_AND_SYSTEM_ISSUES.md](01_GLOBAL_AND_SYSTEM_ISSUES.md) |
| **Serpantinum** | Clipboard image sizing, wallpaper string types, `Shell.qml` naming, escape dismiss | [serpantinum/troubleshooting/](file:///home/ubaid/Public/dusky_shell_porting_guide/serpantinum/troubleshooting/README.md) |
| **iNiR** | Silent launcher exit on Hyprland, Material Symbols font glyphs, toplevel segfault | [inir/troubleshooting/](file:///home/ubaid/Public/dusky_shell_porting_guide/inir/troubleshooting/README.md) |
| **Master Log** | Global filterable status table with IDs, status tags, and one-line solutions | [00_MASTER_ISSUE_TRACKER.md](00_MASTER_ISSUE_TRACKER.md) |

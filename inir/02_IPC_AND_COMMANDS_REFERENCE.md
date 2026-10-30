# iNiR IPC & CLI Command Reference

iNiR provides 73 IPC targets exposed through Quickshell's built-in IPC layer. The `inir` CLI wrapper automatically resolves the running instance and dispatches calls.

---

## 1. Primary IPC Targets & Usage

### 1.1 Shell & Multi-Family Controls
```bash
# Switch panel family live
inir panelFamily set iris      # Dynamic Island
inir panelFamily set ii        # Material Design 2
inir panelFamily set waffle    # Windows 11 Fluent

# Cycle to next family
inir panelFamily cycle
```

### 1.2 Launcher & Overview
```bash
# Toggle application overview / launcher
inir overview toggle
inir overview open
inir overview close
```

### 1.3 Lock Screen & Session
```bash
# Lock the screen (ext-session-lock + PAM)
inir lock lock

# Unlock screen
inir lock unlock

# Toggle power session menu (Logout, Reboot, Suspend, Poweroff)
inir session toggle
```

### 1.4 Control Center & Quick Settings
```bash
# Toggle Quick Settings drawer across any family
inir controlPanel toggle

# Open full settings GUI window
inir settings
```

### 1.5 Sidebars (Left / Right)
```bash
# Toggle Right Sidebar (Quick Toggles, Mixer, Calendar)
inir sidebarRight toggle

# Toggle Left Sidebar (AI Chat, Music)
inir sidebarLeft toggle
```

### 1.6 Wallpaper & Appearance
```bash
# Open Wallpaper Selector (wired to skwd-wall-v2 on Dusky)
inir wallpaperSelector toggle

# Dark / Light Mode Switch
inir colorMode set dark
inir colorMode set light
```

---

## 2. Low-Level IPC Mechanism
Behind the scenes, `inir <target> <function> [args...]` translates directly into:
```bash
quickshell -p ~/.config/quickshell/inir ipc call <target> <function> [args...]
```
If Quickshell is not running, the `inir` CLI detects this and offers to start it automatically.

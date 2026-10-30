# iNiR Subshells Architecture: iRiS, Material ii, and Waffle

iNiR features a panel architecture that hosts three desktop visual paradigms within a single Quickshell codebase. Switching between them is handled live via IPC and state bindings without needing to restart the Quickshell process.

---

## 1. Subshell Comparison Matrix

| Feature | **iRiS** (Default) | **Material ii** | **Waffle** |
|---|---|---|---|
| **Form Factor** | Dynamic Island Pill | Top Bar + Bottom Dock | Windows 11 Taskbar |
| **Bar Placement** | Any Edge (Top/Bottom/Pill) | Fixed Top Screen Edge | Bottom Screen Edge |
| **Launcher** | IrisPalette / Spotlight | Full-screen Overview Grid | Start Menu Drawer |
| **Control Center** | Island Popout Center | Right Sidebar Drawer | Action Center Popout |
| **Multitasking** | Island Workspaces & Orbit | Stash & App Dock | Waffle Task View |
| **Key Design Language** | Pill Geometry & Island Glass | Material Design 3 (M3) | Windows 11 Fluent Glass |

---

## 2. Dynamic Panel Family Switching Engine

### Runtime Transition Mechanism
Switching the active panel family does not restart Quickshell or re-initialize singleton services. Instead:
1. `inir panelFamily set <family>` sends an IPC call to the `panelFamily` target.
2. `GlobalStates.qml` updates `GlobalStates.panelFamily` and triggers `FamilyTransitionOverlay.qml`.
3. `FamilyTransitionOverlay.qml` renders a brief, smooth opacity transition scrim (default 250ms).
4. Asynchronous `Loader` components in `shell.qml` unmount the old family's panel hierarchy and instantiate the target family:
   - `ShellIrisPanels.qml` -> Loads `IrisIsland`, `IrisControlCenter`, `IrisPalette`.
   - `ShellIiPanels.qml` -> Loads `Bar`, `Dock`, `SidebarLeft`, `SidebarRight`, `Overview`.
   - `ShellWafflePanels.qml` -> Loads `WaffleBar`, `WaffleStartMenu`, `WaffleActionCenter`.
5. Configuration is persisted to `~/.config/inir/config.json` under `.panelFamily`.

---

## 3. Detailed Component Breakdown

### 3.1 iRiS (`panelFamily = "iris"`)
- **Bar**: Centered Dynamic Island that morphs dynamically based on context (media playback, timer, workspace changes, battery charging).
- **Control Center**: Compact popup attached to the island displaying network, bluetooth, audio, night light, and brightness sliders.
- **Launcher**: `IrisPalette` provides an aesthetic keyboard-centric runner.

### 3.2 Material ii (`panelFamily = "ii"`)
- **Top Bar**: Fixed bar featuring workspace pills, focused window title, system tray, and status pill.
- **Application Dock**: Auto-hiding, magnifiable bottom dock tracking active tasks and pinned desktop apps.
- **Dual Sidebars**:
  - **Left**: Gemini / LLM AI Chat interface and YouTube Music / InnerTune integration.
  - **Right**: System Quick Toggles, Audio Volume Mixer, Notepad, and Calendar.

### 3.3 Waffle (`panelFamily = "waffle"`)
- **Bottom Taskbar**: Centered or left-aligned app icons with running indicators, system tray clock, and action center button.
- **Start Menu**: Pinned apps grid, search bar, and user session shortcuts.
- **Action Center**: Quick settings drawer with WiFi, Bluetooth, Night Light, and Volume sliders.

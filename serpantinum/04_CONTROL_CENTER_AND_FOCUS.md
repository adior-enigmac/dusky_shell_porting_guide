# Control Center, Sidebar & Rich Clipboard Integration

The Control Center provides unified access to hardware toggles, volume/brightness sliders, system statistics, and power controls.

---

## 1. Opening the Control Center

- **Universal Hotkey**: **`SUPER + SPACE`** (via `~/user_scripts/hypr/smart_control_center.sh`).
- **CLI**: `bash ~/.config/quickshell/scripts/qs_manager.sh toggle syspanel`
- **Visual Capture**: [serpantinum_control_center.png](../assets/screenshots/serpantinum_control_center.png)

---

## 2. Quick Action Tiles

The Quick Actions row in the Control Center has been configured with 8 interactive tiles:

| Tile | Icon | Left Click | Right Click |
| :--- | :---: | :--- | :--- |
| **Night Light** | `󰖔` | Toggle blue light / warm display mode | Open Display settings |
| **Caffeine** | `󰅶` | Inhibit sleep (toggle on/off) | Open duration menu / increase inhibit timer |
| **Wi-Fi** | `󰤨` | Toggle Wi-Fi radio on/off | Open Wi-Fi network selector popup |
| **Bluetooth** | `󰂯` | Toggle Bluetooth adapter | Open Bluetooth paired devices popup |
| **Airplane Mode** | `󰀝` | Disable/restore all wireless radios | — |
| **Focus Mode** | `󰄉` | **Toggle `focus_daemon.py` on/off** | **Open Digital Wellbeing settings tab** |
| **Clipboard** | `󰅍` | **Open Rich Spotlight Clipboard** | — |
| **Shell Switcher**| `󱂬` | **Open Universal Shell Switcher GUI** | **Quick Toggle next shell** |

---

## 3. Focus Mode / Screen Time Daemon Behavior

1. **Disabled by Default**: `focus_daemon.py` does **NOT** run automatically on boot (`focusDaemonEnabled: false` in `settings.json`).
2. **On-Demand Activation**:
   - Clicking the **Focus Mode (`󰄉`)** tile in the Control Center immediately launches `focus_daemon.py` in the background and turns the button sapphire blue.
   - Clicking it again terminates `focus_daemon.py` (`pkill -TERM`) and updates the state.
3. **Live State Polling**: When the Control Center is open, it automatically checks `pgrep -f focus_daemon.py` every 3 seconds to guarantee the tile's active color always reflects true process state.

---

## 4. Rich Clipboard Manager Integration

- **Universal Hotkey**: **`SUPER + V`** (via `~/user_scripts/hypr/smart_clipboard.sh`).
- **TopBar Access**: Clickable clipboard icon (`󰅍`) in `bar/faces/left/LeftFace.qml`.
- **Control Center Access**: Quick Action tile (`󰅍`) in `syspanel/SystemPanelQuickActions.qml`.
- **Visual Capture**: [serpantinum_clipboard.png](../assets/screenshots/serpantinum_clipboard.png)
- **Features**:
  - Full history preview powered by `cliphist` and `clip_fetcher.py`.
  - Pinned clips management and fuzzy search.
  - Quick copy on Enter, delete on Delete key.
  - Universal dismissal via `Escape` key from any focused element or outside click.

---

## 5. Quickactions Floating Sidebar (`SUPER + ESC`)

- **Universal Hotkey**: **`SUPER + ESC`** (via `~/user_scripts/hypr/smart_sidebar.sh`).
- **IPC Command**: `quickshell -p ~/.config/quickshell/shell.qml ipc call floating toggle`
- **Visual Capture**: [serpantinum_sidebar.png](../assets/screenshots/serpantinum_sidebar.png)
- **Components Included**:
  1. **DrawAction** (`actions/DrawAction.qml`): Interactive canvas sketching and annotation.
  2. **SystemUsage** (`actions/SystemUsage.qml`): Real-time CPU, RAM, GPU, temperature dials.
  3. **Timer** (`actions/Timer.qml`): Countdown timer and stopwatch.
  4. **Notes** (`actions/Notes.qml`): Scratchpad notes.
  5. **Calculator** (`actions/Calculator.qml`): Full scientific expression calculator.

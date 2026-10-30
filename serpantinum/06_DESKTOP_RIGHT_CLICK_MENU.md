# Desktop Right-Click Context Menu Integration

## Overview

Serpantinum provides a rich desktop context menu with quick access to:
- Wallpaper selector (`dusky-papers` / `skwd-wall-v2` / `wallpaper_selector.py`)
- Terminal launcher (`foot` / `kitty` wrapped via `dusky-run`)
- Widget Redactor
- Theme configuration
- **Universal Shell Switcher** (`dusky_shell_switcher.py`)
- Lock screen & display power controls

---

## The Wallpaper Interception Architecture

In standard Wayland compositors, right-clicking on the root desktop wallpaper does nothing unless an active layer surface is listening for input events.

To achieve native-feeling desktop right-clicks:
1. In `~/.config/quickshell/shell.qml`, a full-screen transparent `PanelWindow` delegate is created on every active screen.
2. It listens exclusively for `Qt.RightButton` via a transparent `MouseArea`:
   ```qml
   MouseArea {
       anchors.fill: parent
       acceptedButtons: Qt.RightButton
       onClicked: (mouse) => {
           DesktopMenuController.toggle(backdropWin.screen, mouse.x, mouse.y, "desktop");
       }
   }
   ```
3. Left-clicks, double-clicks, and window drags pass straight through to underlying or overlying surfaces.

---

## Compatibility Fix for `skwd-wall` & `skwd-paper`

### The Issue
When using Dusky's wallpaper changer (`skwd-wall`, `skwd-wall-v2`, or `skwd paper`), the wallpaper daemon runs as a Wayland layer on `WlrLayer.Background` (Level 0).
When the desktop backdrop was initially placed on `WlrLayer.Background`, subsequent invocations of `skwd paper` created new background surfaces *above* the backdrop, blocking mouse events from reaching Quickshell.

### The Resolution
In `~/.config/quickshell/shell.qml`:
- Changed `WlrLayershell.layer` from `WlrLayer.Background` to `WlrLayer.Bottom` (Level 1).
- In `~/.config/quickshell/popouts/DesktopMenu.qml`:
- Changed `WlrLayershell.layer` to `WlrLayer.Top` (Level 2).

### Layer Hierarchy
```
Level 3: WlrLayer.Overlay    -> Lock screens, Screen Dimmer, Switcher Menu
Level 2: WlrLayer.Top        -> Status Bars, Dock, Desktop Menu Popout
Level 1: WlrLayer.Bottom     -> Desktop Backdrop, Desktop Widgets
Level 0: WlrLayer.Background -> Wallpaper Daemons (skwd-paper, awww-daemon)
```
Because the backdrop sits permanently on Level 1, it is **always above any wallpaper manager** (`skwd-paper`, `awww`, `swww`, `hyprpaper`), ensuring right-clicks always open the menu without interference!

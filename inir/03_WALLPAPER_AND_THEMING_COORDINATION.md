# iNiR Wallpaper & Theming Coordination on Dusky Linux

This document outlines how iNiR coordinates with Dusky Linux's wallpaper stack (`skwd-wall-v2`) and system-wide theme manager (Dusky Matugen + GTK/Qt/Papirus-Dark), avoiding duplicate rendering, protecting app theming, and preserving full desktop interactivity (right-click menus and widgets).

---

## 1. Single Wallpaper Ownership Principle

On Dusky Linux, wallpaper rendering is handled exclusively by:
- **`skwd-wall-v2`**: Front-end selector and manager.
- **`skwd-wall-still` / `awww`**: Low-level Wayland layer-shell background renderers.

### The Conflict Problem & The Trap of `modules.background: false`
- **Initial Trap**: Disabling the background module via `"modules.background": false` in `config.json` prevents iNiR from drawing over the wallpaper. However, iNiR's desktop context menu (`desktopContextMenu` and `irisDesktopMenu`) as well as the desktop widget canvas live inside `Background.qml`'s root `MouseArea`. Setting `"modules.background": false` completely destroys desktop right-click menus and all widget functionality across all subshells!
- **The Correct Solution (Transparent Pass-Through Layer)**:
  1. Keep `"modules.background": true` in `~/.config/inir/config.json`.
  2. Set `showInternalStaticWallpaper: false` in `modules/background/Background.qml` and `modules/waffle/background/WaffleBackground.qml`.
  3. Set `externalWallpaper: true` in `modules/iris/background/IrisBackground.qml`.
  
  This renders `Background.qml` as a 100% transparent overlay directly above `skwd-wall-v2`. `skwd-wall-v2` renders the wallpaper, while iNiR captures desktop right-clicks, opens context menus, and displays widgets seamlessly.

---

## 2. Redirecting All Wallpaper Triggers to `skwd-wall-v2`

Across all 3 subshells (`iris`, `ii`, `waffle`), every UI element that opens a wallpaper picker is routed to `/usr/bin/skwd-wall-v2`:

1. **CLI & IPC Interceptor (`scripts/inir`)**:
   In `run_ipc_target_command()`:
   ```bash
   if [[ "$target" == "wallpaperSelector" || "$target" == "wallpaper" || "$target" == "coverflowSelector" ]]; then
       exec /usr/bin/skwd-wall-v2
   fi
   ```
2. **Context Menu (`modules/background/Background.qml`)**:
   ```qml
   { text: Translation.tr("Change wallpaper"), iconName: "image", monochromeIcon: true,
       action: () => { Quickshell.execDetached(["/usr/bin/skwd-wall-v2"]) } }
   ```
3. **iRiS Hero Action (`modules/iris/background/IrisDesktopActions.qml`)**:
   ```qml
   action: () => {
       Quickshell.execDetached(["/usr/bin/skwd-wall-v2"])
   }
   ```
4. **Control Panel (`modules/controlPanel/WallpaperSection.qml`)**:
   ```qml
   onClicked: Quickshell.execDetached(["/usr/bin/skwd-wall-v2"])
   ```
5. **Material ii Top Bar Buttons (`modules/barM3/UtilButtons.qml`)**:
   ```qml
   onClicked: Quickshell.execDetached(["/usr/bin/skwd-wall-v2"])
   ```
6. **iRiS Island Desktop Page (`modules/iris/bar/island/IslandDesktopPage.qml`)**:
   ```qml
   onClicked: {
       Quickshell.execDetached(["/usr/bin/skwd-wall-v2"])
   }
   ```
7. **iRiS Settings Card (`modules/iris/settings/IrisWallpaperCard.qml`)**:
   ```qml
   function openGallery(): void {
       GlobalStates.settingsOverlayOpen = false
       Quickshell.execDetached(["/usr/bin/skwd-wall-v2"])
   }
   ```

---

## 3. Strict Application Theming Autonomy (Protecting Dusky)

Dusky Linux enforces unified, high-fidelity dynamic theming across all applications:
- **Engine**: Dusky Matugen (`dusky-matugen-a` / `dusky-matugen-b`).
- **Icon Theme**: `Papirus-Dark`.
- **Cursor Theme**: `Bibata-Modern-Classic`.
- **Target Configurations**: GTK3 (`~/.config/gtk-3.0/settings.ini`), GTK4 (`~/.config/gtk-4.0/settings.ini`), Qt5 (`qt5ct.conf`), Qt6 (`qt6ct.conf`), `xsettingsd.conf`, and `gsettings`.

### The Threat
iNiR contains an internal theming engine with aggressive color modules (`scripts/colors/apply-gtk-theme.sh`, `modules/20-gtk-kde.sh`, `modules/10-terminals.sh`, etc.) that rewrite `settings.ini`, `xsettingsd.conf`, and `gsettings` on shell startup to uninstalled themes (like `WhiteSur-dark` and `Fluent-teal-dark`), breaking icons in Thunar, docks, and apps across the desktop.

### The Lockdown
To prevent iNiR from corrupting system and app themes:
1. **Neutered Color Scripts**: Replaced all scripts in `~/.config/quickshell/inir/scripts/colors/` with safe no-ops (`exit 0`):
   - `apply-gtk-theme.sh`
   - `modules/20-gtk-kde.sh`
   - `modules/10-terminals.sh`
   - `modules/30-editors.sh`, `31-zed.sh`, `40-chrome.sh`, `45-firefox.sh`, `50-spicetify.sh`, `60-sddm.sh`, `70-steam.sh`, `80-pear-desktop.sh`, `85-limusic.sh`, `90-cava.sh`, `95-claude-code.sh`
2. **Safe Icon Theme Detection**:
   - `icon-theme-polarity.sh`: returns `Papirus-Dark`
   - `icon-theme-for-mode.sh`: returns `Papirus-Dark`
3. **Disabled Theming Flags in `~/.config/inir/config.json`**:
   ```json
   {
     "wallpaperTheming": {
       "enableAppsAndShell": false
     },
     "theming": {
       "enableQtApps": false,
       "enableTerminal": false,
       "enableVesktop": false,
       "enableZed": false
     }
   }
   ```
4. **Theme Restoration**:
   If themes were altered, Dusky publishers restore them:
   ```bash
   gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
   gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Classic"
   gsettings set org.gnome.desktop.interface gtk-theme "dusky-matugen-b"
   python3 ~/user_scripts/matugen/gtk_colors.py 3
   python3 ~/user_scripts/matugen/gtk_colors.py 4
   python3 ~/user_scripts/matugen/qt_colors.py qt5ct
   python3 ~/user_scripts/matugen/qt_colors.py qt6ct
   killall -HUP xsettingsd 2>/dev/null || true
   ```

---

## 4. Two-Way Dynamic Wallpaper Synchronization

Dusky provides unified, bidirectional wallpaper synchronization between all three shells:
- **Central Dispatcher**: `~/user_scripts/hypr/sync_wallpaper.sh`
- **When Wallpaper changes from `skwd-wall-v2` or Dusky native**:
  1. `skwd-wall-still` updates the monitor background.
  2. Dusky writes `~/.config/dusky/settings/dusky_theme/dark_wal` and `current_image`.
  3. Matugen template hook `[templates.serpantinum_wallpaper]` in `~/.config/matugen/config.toml` automatically writes the wallpaper path to:
     - Serpantinum: `~/.local/state/serpantinum/current_wallpaper` & `~/.config/serpantinum/settings.json`
     - iNiR: `~/.config/inir/config.json` (`background.wallpaperPath`) & `~/.local/state/quickshell/user/generated/wallpaper/path.txt`
  4. Matugen generates dynamic Material 3 colors into `~/.local/state/quickshell/user/generated/colors.json`.
- **When Wallpaper changes from inside iNiR settings or Coverflow**:
  1. `switchwall.sh` intercepts the call and dispatches to `~/user_scripts/hypr/sync_wallpaper.sh "$imgpath"`.
  2. `sync_wallpaper.sh` sets the wallpaper on `skwd-wall-still`, updates `skwd-wall-v2` config, Dusky state, Serpantinum config, and runs Matugen with `--source-color-index=0 --mode=dark`.
  3. Every component across Dusky, Serpantinum, and iNiR remains in complete synchronization.

---

## 5. Dynamic Material 3 Matugen Pipeline for iNiR

iNiR's `MaterialThemeLoader.qml` watches `Directories.generatedMaterialThemePath` (`~/.local/state/quickshell/user/generated/colors.json`).

1. **Template**: `~/.config/matugen/templates/inir-colors.json`
   Provides exact Material 3 tokens: `darkmode: {{is_dark_mode}}`, `background`, `primary`, `surface`, `on_primary`, `secondary`, `tertiary`, containers, and outlines.
2. **Matugen Rule**:
   In `~/.config/matugen/config.toml`:
   ```toml
   [templates.inir_quickshell]
   input_path  = '~/.config/matugen/templates/inir-colors.json'
   output_path = '~/.local/state/quickshell/user/generated/colors.json'
   post_hook   = '''
     mkdir -p "$HOME/.local/state/quickshell/user/generated"
     if pgrep -f "quickshell.*inir" >/dev/null 2>&1; then
       touch "$HOME/.local/state/quickshell/user/generated/colors.json" 2>/dev/null || :
     fi
   '''
   ```
3. Whenever Matugen runs, `colors.json` updates and `MaterialThemeLoader.qml` instantly shifts the theme colors across all iNiR subshells (Iris island, Material II panels, Waffle menus, and settings overlays) to match the current wallpaper.

---

## 6. Hyprland Layer Rules: Preventing Blurred Wallpapers & Screenshot Freezes

Hyprland compositor layer rules must be constructed with precision:
- **Danger**: A catch-all rule such as `match = { namespace = "^quickshell.*" }` matches fullscreen background windows (`quickshell:background`, `quickshell:iris-background`, `quickshell:wBackground`, `quickshell:iiBackdrop`) and screen capture surfaces (`quickshell:regionSelector`, `quickshell:annotationEditor`). This forces Hyprland to blur the entire monitor above the wallpaper, turning the desktop blurry and causing screenshot snips to freeze and swallow inputs.
- **Rule Architecture**:
  1. Blur ONLY interactive panels and drawers:
     ```lua
     hl.layer_rule({
         name = "inir_panels_blur",
         match = { namespace = "^quickshell:(bar|dock|iris-chassis|iris-menu|iris-sidebar.*|iris-notifications|iris-osd|iris-orbit-corner|iris-osk|iris-session|iris-settings|iris-studio|controlPanel|dashboard|equalizer|overlay|notificationPopup|onScreenDisplay|osk|overview|orbit|popup|m3-popup|polkit|session|settingsOverlay|settingsFocus|wAction.*|waction.*|wAltSwitcher|wClipboard|wNotification.*|wOnScreenDisplay|wSession|wStart.*|wTask.*|wWidgets|wallpaperLauncher|wallpaperSelector|coverflowSelector|workspaceStrip|clipboardPanel|verticalBar|cheatsheet|altSwitcher|closeConfirm|toast-manager|shellUpdate)$" },
         blur = true,
         xray = true,
         ignore_alpha = 0.54
     })
     ```
  2. Explicitly disable blur on fullscreen backgrounds, backdrops, and snipping overlays:
     ```lua
     hl.layer_rule({
         name = "inir_background_no_blur",
         match = { namespace = "^quickshell:(background|iris-background|wBackground|iiBackdrop|regionSelector|annotationEditor|.*Backdrop|.*catcher|.*Scrim|iris-reserve.*|iris-wave|charging-ripple)$" },
         blur = false
     })
     ```
  3. In `~/.config/inir/config.json`, disable internal dimming/blur:
     `"background.backdrop.enable": false`, `"background.effects.enableBlur": false`, `"effects.dim": 0`, `"effects.dynamicDim": 0`.

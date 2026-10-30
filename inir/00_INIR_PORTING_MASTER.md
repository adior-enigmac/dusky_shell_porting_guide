# iNiR Desktop Shell Porting Playbook for Dusky Linux

This document is an exhaustive, production-grade guide designed for any developer or AI agent to port **iNiR** onto Dusky Linux (Arch Linux + Hyprland Lua) with native integration, 3 switchable subshells, and zero conflicts.

---

## 1. System Architecture & Coexistence

- **Host Environment**: Arch Linux, Hyprland Lua (`~/.config/hypr/source/` and `~/.config/hypr/edit_here/source/`).
- **Target Runtime Directory**: `~/.config/quickshell/inir/` (Isolated named Quickshell configuration).
- **User Config Directory**: `~/.config/inir/config.json` (with legacy compatibility symlink `~/.config/illogical-impulse -> ~/.config/inir`).
- **CLI Executable**: `~/.local/bin/inir` (points to `~/.config/quickshell/inir/scripts/inir`).
- **Subshell Architecture (3 Panel Families)**:
  1. **iRiS (Default)**: Modern Dynamic Island bar placed on any edge, pill modules, IrisPalette launcher, and IrisControlCenter.
  2. **Material ii**: Classic Material Design top bar, animated application dock, Left Drawer (AI Chat & YT Music), Right Drawer (Quick Settings & Calendar), and Overview launcher.
  3. **Waffle**: Windows 11 style bottom taskbar, centered Start Menu, Task View, and Action Center.

---

## 2. Dependencies Checklist

Ensure the following packages are installed on Arch Linux:
```bash
# Core Quickshell, System, and Fonts
sudo pacman -S --needed quickshell playerctl brightnessctl jq python pipewire wireplumber wl-clipboard socat \
    qt6-imageformats syntax-highlighting ttf-material-symbols-variable wlsunset

# Fonts from AUR (required by iRiS / Material typography)
yay -S --needed ttf-roboto-flex
```

---

## 3. Installation Step-by-Step

### Step 3.1: Deploy Runtime Payload (Zero Symlinks)
Deploy the payload from the source checkout to `~/.config/quickshell/inir/`:
```bash
mkdir -p ~/.config/quickshell/inir
python3 /path/to/iNiR/sdata/lib/runtime-payload.py copy --root /path/to/iNiR --target ~/.config/quickshell/inir
cp /path/to/iNiR/qmldir ~/.config/quickshell/inir/qmldir
chmod +x ~/.config/quickshell/inir/setup ~/.config/quickshell/inir/scripts/inir
find ~/.config/quickshell/inir/scripts -type f \( -name '*.sh' -o -name '*.fish' -o -name '*.py' \) -exec chmod +x {} +
```

### Step 3.2: Critical Runtime Patches

#### Patch 1: `IrisGate.official` Bypass
iNiR contains a safety check in `modules/iris/style/IrisGate.qml` that disables the Island if `Quickshell.shellPath("shell.qml")` differs from standard defaults.
In `~/.config/quickshell/inir/modules/iris/style/IrisGate.qml`, replace:
```qml
readonly property bool official: ...
```
with:
```qml
readonly property bool official: true
```

#### Patch 2: `enabledPanels` Multi-Family Initialization
By default, iNiR's loaders only load panels that exist in `Config.options.enabledPanels`. When starting in `iris` mode, if `irisBar`, `irisBackground`, etc. are absent, no bar appears.
1. In `shell.qml`, ensure `root._ensureFamilyPanels(family)` runs at startup and whenever swapping families:
```qml
function _ensureFamilyPanels(family: string): void {
    const basePanels = root.panelFamilies[family] ?? []
    const currentPanels = Config.options?.enabledPanels ?? []
    if (basePanels.length === 0) return
    const merged = [...currentPanels]
    for (const id of basePanels) {
        if (!merged.includes(id)) merged.push(id)
    }
    Config.setNestedValue("enabledPanels", merged)
}
```
2. Populate `enabledPanels` in `~/.config/inir/config.json` with all panels for `iris`, `ii`, and `waffle`.

#### Patch 3: Transparent Desktop Layer for Right-Click & Widgets
Do **not** set `"modules.background": false`, as that unloads `Background.qml` and destroys right-click menus and widgets.
Instead:
- Set `"modules.background": true` in `config.json`.
- In `modules/background/Background.qml` line 1480: `readonly property bool showInternalStaticWallpaper: false`.
- In `modules/waffle/background/WaffleBackground.qml` line 89: `readonly property bool showInternalStaticWallpaper: false`.
- In `modules/iris/background/IrisBackground.qml` line 34: `readonly property bool externalWallpaper: true`.

#### Patch 4: Neuter Aggressive Color Modules
iNiR's theming engine will overwrite system GTK and Qt configurations with uninstalled icon themes. Neutralize all color scripts:
```bash
for script in ~/.config/quickshell/inir/scripts/colors/*.sh ~/.config/quickshell/inir/scripts/colors/modules/*.sh; do
    printf '#!/usr/bin/env bash\nexit 0\n' > "$script"
done
chmod +x ~/.config/quickshell/inir/scripts/colors/*.sh ~/.config/quickshell/inir/scripts/colors/modules/*.sh
```
In `~/.config/inir/config.json`, set:
```json
{
  "wallpaperTheming": { "enableAppsAndShell": false },
  "theming": {
    "enableQtApps": false,
    "enableTerminal": false,
    "enableVesktop": false,
    "enableZed": false
  }
}
```

### Step 3.3: Global CLI Wrapper
Create `~/.local/bin/inir` so the user and all automation scripts can invoke `inir` globally:
```bash
cat << 'EOF' > ~/.local/bin/inir
#!/usr/bin/env bash
export INIR_RUNTIME_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/inir"
exec "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/inir/scripts/inir" "$@"
EOF
chmod +x ~/.local/bin/inir
```

---

## 4. Wallpaper Coordination (`skwd-wall-v2`)

All wallpaper triggers across all 3 subshells are wired to `/usr/bin/skwd-wall-v2`:
- In `scripts/inir`: intercept `wallpaperSelector`, `wallpaper`, and `coverflowSelector` to execute `/usr/bin/skwd-wall-v2`.
- In `Background.qml` and `IrisDesktopActions.qml`: execute `skwd-wall-v2` on "Change Wallpaper".
- In `WallpaperSection.qml`, `UtilButtons.qml`, `IslandDesktopPage.qml`, `IrisWallpaperCard.qml`: execute `skwd-wall-v2` directly.

---

## 5. Universal Smart Keybinds Integration

All keybindings route dynamically through smart dispatchers in `~/user_scripts/hypr/`:

| Shortcut | Dusky Native | Serpantinum | iNiR (iRiS, Material ii, Waffle) |
|---|---|---|---|
| **Alt + Space** | Rofi App Launcher | Serpantinum Launcher | `inir overview toggle` |
| **Super + M** | Dusky Hyprlock | Serpantinum Lock Screen | `inir lock lock` |
| **Super + Space** | GTK Control Center | Serpantinum Settings | `inir controlPanel toggle` |
| **Super + Escape**| Leave Fullscreen | Serpantinum System Sidebar (`qs_manager.sh toggle system`) | `inir sidebarRight toggle` |

---

## 6. Hyprland Layer Rules & Blur

Add to `~/.config/hypr/edit_here/source/window_rules.lua`:
```lua
hl.layer_rule({
    name = "inir_surfaces_blur",
    match = { namespace = "^quickshell:.*$" },
    blur = true,
    xray = true,
    ignore_alpha = 0.54,
    order = 2,
})
```

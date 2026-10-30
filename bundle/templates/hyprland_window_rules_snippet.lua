-- ==============================================================================
-- Hyprland Layer Rules Snippet for Quickshell & Shell Ports (MERGE SNIPPET)
-- Location: ~/.config/hypr/edit_here/source/window_rules.lua or ~/.config/hypr/source/window_rules.lua
-- ==============================================================================
-- CAUTION FOR AI AGENTS & USERS:
-- DO NOT OVERWRITE existing window_rules.lua! The user has custom application rules.
-- SAFELY MERGE this snippet into the user's config using `safe_config_merger.py --merge`
-- or append only missing layer rules at the end of the file.
-- ==============================================================================

-- 1. Serpantinum Desktop Shell Panels
hl.layer_rule({
    name = "quickshell_bar_blur",
    match = { namespace = "quickshell" },
    blur = true,
    blur_popups = true,
    xray = true,
    ignore_alpha = 0.54
})

hl.layer_rule({
    name = "quickshell_master_blur",
    match = { namespace = "qs-master" },
    blur = true,
    blur_popups = true,
    xray = true,
    ignore_alpha = 0.54
})

hl.layer_rule({
    name = "quickshell_dock_blur",
    match = { namespace = "qs-dock" },
    blur = true,
    xray = true,
    ignore_alpha = 0.54
})

hl.layer_rule({
    name = "quickshell_desktopmenu_blur",
    match = { namespace = "desktopmenu" },
    blur = true,
    xray = true,
    ignore_alpha = 0.54
})

hl.layer_rule({
    name = "quickshell_menus_blur",
    match = { namespace = "dockappmenu" },
    blur = true,
    xray = true,
    ignore_alpha = 0.54
})

hl.layer_rule({
    name = "quickshell_tray_blur",
    match = { namespace = "traymenu" },
    blur = true,
    xray = true,
    ignore_alpha = 0.54
})

hl.layer_rule({
    name = "quickshell_sidemusic_blur",
    match = { namespace = "sidemusic" },
    blur = true,
    xray = true,
    ignore_alpha = 0.54
})

hl.layer_rule({
    name = "quickshell_launcher_blur",
    match = { namespace = "qs-applauncher" },
    blur = true,
    dim_around = true,
    ignore_alpha = 0.54
})

hl.layer_rule({
    name = "quickshell_clip_blur",
    match = { namespace = "qs-clipboard" },
    blur = true,
    dim_around = true,
    ignore_alpha = 0.54
})

hl.layer_rule({
    name = "quickshell_notifs_blur",
    match = { namespace = "qs-popups" },
    blur = true,
    ignore_alpha = 0.54
})

hl.layer_rule({
    name = "quickshell_osd_blur",
    match = { namespace = "osd" },
    blur = true,
    ignore_alpha = 0.54
})

hl.layer_rule({
    name = "universal_switcher_blur",
    match = { namespace = "dusky-shell-switcher" },
    blur = true,
    dim_around = true,
    ignore_alpha = 0.54
})

hl.layer_rule({
    name = "quickshell_widgets_blur",
    match = { namespace = "^qs-widget-.*$" },
    blur = true,
    xray = true,
    ignore_alpha = 0.54
})

-- 2. iNiR Desktop Shell Interactive Panels & Popups (Blur Allowed)
hl.layer_rule({
    name = "inir_panels_blur",
    match = { namespace = "^quickshell:(bar|dock|iris-chassis|iris-menu|iris-sidebar.*|iris-notifications|iris-osd|iris-orbit-corner|iris-osk|iris-session|iris-settings|iris-studio|controlPanel|dashboard|equalizer|overlay|notificationPopup|onScreenDisplay|osk|overview|orbit|popup|m3-popup|polkit|session|settingsOverlay|settingsFocus|wAction.*|waction.*|wAltSwitcher|wClipboard|wNotification.*|wOnScreenDisplay|wSession|wStart.*|wTask.*|wWidgets|wallpaperLauncher|wallpaperSelector|coverflowSelector|workspaceStrip|clipboardPanel|verticalBar|cheatsheet|altSwitcher|closeConfirm|toast-manager|shellUpdate)$" },
    blur = true,
    xray = true,
    ignore_alpha = 0.54
})

-- 3. iNiR Fullscreen / Background Surfaces (STRICTLY NO BLUR)
-- CRITICAL: Catch-all rules like `^quickshell:.*$` will blur the entire screen above the wallpaper
-- and break screenshot snipping. Never omit this exclusion rule!
hl.layer_rule({
    name = "inir_background_no_blur",
    match = { namespace = "^quickshell:(background|iris-background|wBackground|iiBackdrop|regionSelector|annotationEditor|.*Backdrop|.*catcher|.*Scrim|iris-reserve.*|iris-wave|charging-ripple)$" },
    blur = false
})

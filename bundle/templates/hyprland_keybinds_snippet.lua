-- ==============================================================================
-- Hyprland Lua Keybindings for Shell-Aware Dispatchers (MERGE SNIPPET)
-- Location: ~/.config/hypr/edit_here/source/keybinds.lua or ~/.config/hypr/source/keybinds.lua
-- ==============================================================================
-- CAUTION FOR AI AGENTS & USERS:
-- DO NOT OVERWRITE existing keybinds.lua! The user has their own custom bindings.
-- SAFELY MERGE this snippet into the user's config using `safe_config_merger.py --merge`
-- or append only the missing bindings at the end of the file.
-- ==============================================================================

local dusky_scripts = os.getenv("HOME") .. "/user_scripts/"

-- 1. Universal Shell Switcher GUI (SUPER + ESC)
hl.bind(
    "SUPER, ESCAPE",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_sidebar.sh"),
    {
        description = "Toggle Sidebar / Leave Fullscreen",
        dont_inhibit = true,
        allow_input_capture = true,
        submap_universal = true,
    }
)

-- 2. Application Launcher (ALT + SPACE)
hl.bind(
    "ALT, SPACE",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_launcher.sh"),
    { description = "Launch Menu for Apps" }
)

-- 3. Control Center / Quick Settings (SUPER + SPACE)
hl.bind(
    "SUPER, SPACE",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_control_center.sh"),
    { description = "System Menu" }
)

-- 4. Screen Lock (SUPER + M)
hl.bind(
    "SUPER, M",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_lock.sh"),
    { description = "Lock Screen" }
)

-- 5. Smart Clipboard Manager (SUPER + V)
hl.bind(
    "SUPER, V",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_clipboard.sh"),
    { description = "Smart Clipboard History (Shell Aware)" }
)

-- 6. Quick Shell Switcher GUI (SUPER + CTRL + S)
hl.bind(
    "SUPER + CTRL, S",
    hl.dsp.exec_cmd("python3 " .. dusky_scripts .. "hypr/dusky_shell_switcher.py"),
    { description = "Universal Shell Switcher" }
)

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

-- 1. Universal Sidebar / Fullscreen Toggle (SUPER + ESC)
pcall(hl.unbind, "SUPER + ESCAPE")
pcall(hl.unbind, "SUPER, ESCAPE")
hl.bind(
    "SUPER + ESCAPE",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_sidebar.sh"),
    {
        description = "Toggle Sidebar / Leave Fullscreen",
        dont_inhibit = true,
        allow_input_capture = true,
        submap_universal = true,
    }
)

-- 2. Application Launcher (ALT + SPACE)
pcall(hl.unbind, "ALT + SPACE")
pcall(hl.unbind, "ALT, SPACE")
hl.bind(
    "ALT + SPACE",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_launcher.sh"),
    { description = "Launch Menu for Apps", submap_universal = true }
)

-- 3. Control Center / Quick Settings (SUPER + SPACE)
pcall(hl.unbind, "SUPER + SPACE")
pcall(hl.unbind, "SUPER, SPACE")
hl.bind(
    "SUPER + SPACE",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_control_center.sh"),
    { description = "System Menu", submap_universal = true }
)

-- 4. Screen Lock (SUPER + M)
pcall(hl.unbind, "SUPER + M")
pcall(hl.unbind, "SUPER, M")
hl.bind(
    "SUPER + M",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_lock.sh"),
    { description = "Lock Screen", submap_universal = true }
)

-- 5. Smart Clipboard Manager (SUPER + V)
pcall(hl.unbind, "SUPER + V")
pcall(hl.unbind, "SUPER, V")
hl.bind(
    "SUPER + V",
    hl.dsp.exec_cmd(dusky_scripts .. "hypr/smart_clipboard.sh"),
    { description = "Smart Clipboard History (Shell Aware)", submap_universal = true }
)

-- 6. Quick Shell Switcher GUI (SUPER + CTRL + S)
pcall(hl.unbind, "SUPER + CTRL + S")
pcall(hl.unbind, "SUPER + CTRL, S")
hl.bind(
    "SUPER + CTRL + S",
    hl.dsp.exec_cmd("python3 " .. dusky_scripts .. "hypr/dusky_shell_switcher.py"),
    { description = "Universal Shell Switcher", submap_universal = true }
)

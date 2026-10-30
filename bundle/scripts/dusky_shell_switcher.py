#!/usr/bin/env python3
import os
import sys
import subprocess
import fcntl
import json
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
gi.require_version("Gdk", "3.0")
from gi.repository import Gtk, GtkLayerShell, Gdk

LOCK_FILE = "/tmp/dusky_shell_switcher_gui.lock"
STATE_FILE = os.path.expanduser("~/.local/state/dusky/active_shell")
SUBSHELL_FILE = os.path.expanduser("~/.local/state/dusky/active_subshell")
CSS_FILE = os.path.expanduser("~/.config/matugen/generated/shell-switcher.css")
SWITCH_SCRIPT = os.path.expanduser("~/user_scripts/hypr/dusky_shell_switch.sh")

SHELLS = [
    {
        "id": "dusky",
        "key": "1",
        "name": "Dusky Native",
        "icon": "󰣇",
        "tag": "Waybar"
    },
    {
        "id": "serpantinum",
        "key": "2",
        "name": "Serpantinum",
        "icon": "󱄅",
        "tag": "Quickshell"
    },
    {
        "id": "inir-iris",
        "key": "3",
        "name": "iNiR (iRiS Island)",
        "icon": "󱓞",
        "tag": "Dynamic Island"
    },
    {
        "id": "inir-ii",
        "key": "4",
        "name": "iNiR (Material ii)",
        "icon": "󰕮",
        "tag": "Dock & Bar"
    },
    {
        "id": "inir-waffle",
        "key": "5",
        "name": "iNiR (Waffle)",
        "icon": "",
        "tag": "Windows 11"
    }
]

def get_active_shell():
    if os.path.exists(SUBSHELL_FILE):
        try:
            with open(SUBSHELL_FILE, "r") as f:
                val = f.read().strip()
                if val:
                    return val
        except Exception:
            pass
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                val = f.read().strip()
                if val == "inir":
                    return "inir-iris"
                return val
        except Exception:
            pass
    return "dusky"

class MinimalShellSwitcher(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)
        self.set_title("Desktop Shell")
        self.set_resizable(False)
        self.set_default_size(340, -1)

        # LayerShell Config
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_namespace(self, "dusky-shell-switcher")
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.EXCLUSIVE)

        # Center on screen
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, False)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, False)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, False)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, False)

        self.get_style_context().add_class("switcher-window")

        self.active_shell_id = get_active_shell()
        self.initial_workspace = self._get_current_workspace()
        self.selected_index = 0
        for idx, item in enumerate(SHELLS):
            if item["id"] == self.active_shell_id:
                self.selected_index = idx
                break

        self.cards = []
        self._build_ui()
        self._load_css()
        self._update_selection()

        self.connect("key-press-event", self._on_key_press)
        self.connect("button-press-event", self._on_window_button_press)

    def _build_ui(self):
        root_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        root_box.get_style_context().add_class("main-box")
        self.add(root_box)

        # Subtle Header
        header_row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        title_label = Gtk.Label(label="DESKTOP SHELL")
        title_label.set_xalign(0.0)
        title_label.get_style_context().add_class("header-title")
        header_row.pack_start(title_label, True, True, 0)
        root_box.pack_start(header_row, False, False, 0)

        # Shell List
        list_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        list_box.get_style_context().add_class("shell-list")

        for idx, item in enumerate(SHELLS):
            ev = Gtk.EventBox()
            row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            row.get_style_context().add_class("shell-item")

            # Icon
            icon = Gtk.Label(label=item["icon"])
            icon.get_style_context().add_class("item-icon")
            row.pack_start(icon, False, False, 0)

            # Name
            name = Gtk.Label(label=item["name"])
            name.set_xalign(0.0)
            name.get_style_context().add_class("item-name")
            row.pack_start(name, True, True, 0)

            # Tag / Badge
            tag = Gtk.Label(label=item["tag"])
            tag.get_style_context().add_class("item-tag")
            row.pack_start(tag, False, False, 0)

            # Active dot or Key Hint
            if item["id"] == self.active_shell_id:
                badge = Gtk.Label(label="● Active")
                badge.get_style_context().add_class("active-pill")
                row.pack_start(badge, False, False, 0)
            else:
                key = Gtk.Label(label=f"[{item['key']}]")
                key.get_style_context().add_class("key-hint")
                row.pack_start(key, False, False, 0)

            ev.add(row)
            ev.connect("enter-notify-event", lambda w, e, i=idx: self._on_item_hover(i))
            ev.connect("button-press-event", lambda w, e, i=idx: self._on_item_clicked(i))
            self.cards.append(row)
            list_box.pack_start(ev, False, False, 0)

        root_box.pack_start(list_box, True, True, 0)

        # Minimal Footer
        footer = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        footer.get_style_context().add_class("footer-box")
        hint = Gtk.Label(label="1..5 Select  •  Enter Apply  •  Esc Close")
        hint.set_xalign(0.5)
        hint.get_style_context().add_class("footer-hint")
        footer.pack_start(hint, True, True, 0)
        root_box.pack_start(footer, False, False, 0)

    def _load_css(self):
        css_provider = Gtk.CssProvider()
        loaded = False
        if os.path.exists(CSS_FILE):
            try:
                css_provider.load_from_path(CSS_FILE)
                loaded = True
            except Exception:
                pass

        if not loaded:
            fallback = b"""
            window.switcher-window {
                background-color: #140c0b;
                border: 1px solid rgba(255, 255, 255, 0.12);
                border-radius: 12px;
            }
            .main-box { padding: 12px 14px; }
            .header-title {
                font-size: 10px;
                font-weight: 700;
                letter-spacing: 1.2px;
                color: #8c7f7e;
                margin-bottom: 4px;
            }
            .shell-item {
                padding: 8px 12px;
                border-radius: 8px;
                background-color: transparent;
                transition: background-color 120ms ease;
            }
            .shell-item.selected {
                background-color: rgba(255, 255, 255, 0.08);
            }
            .item-icon { font-size: 16px; color: #ffb4a9; }
            .item-name { font-size: 13px; font-weight: 600; color: #f1dedc; }
            .item-tag {
                font-size: 10px;
                color: #8c7f7e;
                background-color: rgba(255, 255, 255, 0.04);
                padding: 2px 6px;
                border-radius: 4px;
            }
            .active-pill {
                font-size: 10px;
                font-weight: 700;
                color: #73d13d;
            }
            .key-hint {
                font-size: 10px;
                color: #5c4e4d;
                font-family: monospace;
            }
            .footer-box {
                margin-top: 4px;
                padding-top: 6px;
                border-top: 1px solid rgba(255, 255, 255, 0.06);
            }
            .footer-hint { font-size: 10px; color: #6e6160; }
            """
            css_provider.load_from_data(fallback)

        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    def _update_selection(self):
        for idx, card in enumerate(self.cards):
            ctx = card.get_style_context()
            if idx == self.selected_index:
                ctx.add_class("selected")
            else:
                ctx.remove_class("selected")

    def _on_item_hover(self, index):
        self.selected_index = index
        self._update_selection()

    def _on_item_clicked(self, index):
        self.selected_index = index
        self._update_selection()
        self._apply()

    def _get_current_workspace(self):
        try:
            res = subprocess.run(
                ["hyprctl", "activeworkspace", "-j"],
                capture_output=True,
                text=True,
                timeout=1
            )
            if res.returncode == 0:
                data = json.loads(res.stdout)
                ws_id = data.get("id")
                if ws_id is not None:
                    return str(ws_id)
        except Exception:
            pass
        return ""

    def _apply(self):
        target = SHELLS[self.selected_index]["id"]
        ws = self.initial_workspace
        self.destroy()
        cmd = [SWITCH_SCRIPT, f"--{target}"]
        if ws:
            cmd.append(ws)
        subprocess.Popen(cmd, start_new_session=True)
        Gtk.main_quit()

    def _on_window_button_press(self, widget, event):
        allocation = self.get_allocation()
        if not (0 <= event.x <= allocation.width and 0 <= event.y <= allocation.height):
            self.destroy()
            Gtk.main_quit()

    def _on_key_press(self, widget, event):
        keyval = event.keyval

        if keyval in (Gdk.KEY_Escape, Gdk.KEY_q, Gdk.KEY_Q):
            self.destroy()
            Gtk.main_quit()
            return True

        elif keyval in (Gdk.KEY_Up, Gdk.KEY_k, Gdk.KEY_K):
            self.selected_index = (self.selected_index - 1) % len(SHELLS)
            self._update_selection()
            return True

        elif keyval in (Gdk.KEY_Down, Gdk.KEY_j, Gdk.KEY_J):
            self.selected_index = (self.selected_index + 1) % len(SHELLS)
            self._update_selection()
            return True

        elif keyval in (Gdk.KEY_Return, Gdk.KEY_KP_Enter, Gdk.KEY_space):
            self._apply()
            return True

        elif keyval in (Gdk.KEY_1, Gdk.KEY_d, Gdk.KEY_D):
            self.selected_index = 0
            self._apply()
            return True

        elif keyval in (Gdk.KEY_2, Gdk.KEY_s, Gdk.KEY_S):
            self.selected_index = 1
            self._apply()
            return True

        elif keyval in (Gdk.KEY_3, Gdk.KEY_i, Gdk.KEY_I):
            self.selected_index = 2
            self._apply()
            return True

        elif keyval in (Gdk.KEY_4, Gdk.KEY_m, Gdk.KEY_M):
            self.selected_index = 3
            self._apply()
            return True

        elif keyval in (Gdk.KEY_5, Gdk.KEY_w, Gdk.KEY_W):
            self.selected_index = 4
            self._apply()
            return True

        return False

def main():
    lock_fd = open(LOCK_FILE, "w")
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        sys.exit(0)

    win = MinimalShellSwitcher()
    win.show_all()
    Gtk.main()

if __name__ == "__main__":
    main()

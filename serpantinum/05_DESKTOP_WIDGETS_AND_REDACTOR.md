# Desktop Canvas Widgets & Visual Redactor

Serpantinum includes a rich library of desktop widgets that render on `Layer.Bottom` directly on your wallpaper behind normal application windows.

---

## 1. Opening the Visual Redactor

- **Hotkey**: **`SUPER + ALT + W`**
- **CLI**: `serpantinum launch widgetredactor`
- **Mouse**: Right-click empty wallpaper and click **"Widget Redactor"**.

### What You Can Do in the Redactor
- **Add Widgets**: Click the `+` button in the redactor overlay to pick from the widget catalog.
- **Drag & Position**: Click and drag any widget across your desktop. Grid lines appear automatically to help alignment.
- **Resize**: Drag the corner and side handles to resize dials, cards, or spectrums.
- **Customize Properties**: Click on any widget to adjust opacity, face style, font size, or colors in the property sidebar.
- **Delete**: Click the trash icon or select a widget and press `Delete`.
- **Save**: Changes are saved automatically to `~/.local/state/serpantinum/widgets/<monitor>/layout.json`.

---

## 2. Available Widget Catalog

### 2.1 Clocks
- **Analog Clock**: Minimalist analog dial with moving hands.
- **Digital Clock**: Clean hour/minute display with date.
- **Material Lumen Clock**: Modern Android 14 / Material You clock with arc seconds.
- **Minimal Clock**: Thin typography clock for sleek wallpapers.

### 2.2 System Monitors
- **CPU Dial**: Real-time circular percentage and frequency.
- **RAM Dial**: Used vs total memory ring.
- **Disk Usage Dial**: Root/Home partition utilization.
- **Thermals**: Real-time CPU/GPU temperature sensors.

### 2.3 Audio & Media
- **Music Card with Synced Lyrics**: Displays album art, track title, artist, playback buttons, and live scrolling lyrics fetched automatically.
- **Cava Audio Spectrum**: Real-time audio spectrum visualizer embedded directly on the wallpaper behind windows.

### 2.4 Productivity & Social
- **Sticky Notes**: Interactive post-it note on your desktop where you can type notes directly.
- **Weather Forecast Card**: Compact and full multi-day weather cards with icons and forecasts.
- **GitHub Contributions**: Displays your GitHub commit heat map and current streak.
- **User Profile Badge**: Shows your avatar, username, host, and system uptime.

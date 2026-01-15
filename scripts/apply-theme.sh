#!/bin/bash
# Apply wallpaper-based theme to all applications

set -e

WALLPAPER="${1:-$HOME/.config/wallpapers/one.jpg}"

if [[ ! -f "$WALLPAPER" ]]; then
    echo "Error: Wallpaper not found: $WALLPAPER"
    exit 1
fi

echo "Extracting colors from: $WALLPAPER"

# Extract colors and generate configs
wallust run "$WALLPAPER"

# Reload applications
echo "Reloading applications..."

# Kitty - send SIGUSR1 to reload config
if pgrep -x kitty > /dev/null; then
    kill -SIGUSR1 $(pgrep -x kitty) 2>/dev/null || true
    echo "  Kitty: reloaded"
fi

# Hyprland - reload config
if command -v hyprctl &> /dev/null; then
    hyprctl reload > /dev/null 2>&1 || true
    echo "  Hyprland: reloaded"
fi

# Waybar - restart
if pgrep -x waybar > /dev/null; then
    pkill -x waybar
    sleep 0.5
    waybar &> /dev/null &
    disown
    echo "  Waybar: restarted"
fi

echo "Theme applied successfully!"

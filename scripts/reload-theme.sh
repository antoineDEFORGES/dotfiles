#!/bin/bash
# Reload theme colors in all applications

echo "Reloading theme..."

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

# Tmux - source new colors
if command -v tmux &> /dev/null && tmux list-sessions &> /dev/null; then
    tmux source-file ~/.config/tmux/colors.conf 2>/dev/null || true
    echo "  Tmux: reloaded"
fi

# Neovim - reload colors in all running instances
if command -v nvim &> /dev/null; then
    nvim_reloaded=0
    for sock in /run/user/$(id -u)/nvim.*.0 /tmp/nvim.*/0; do
        if [[ -S "$sock" ]]; then
            nvim --server "$sock" --remote-send ':source ~/.config/nvim/colors.lua<CR>' 2>/dev/null && ((nvim_reloaded++))
        fi
    done
    # Also try XDG_RUNTIME_DIR sockets
    if [[ -n "$XDG_RUNTIME_DIR" ]]; then
        for sock in "$XDG_RUNTIME_DIR"/nvim.*.0; do
            if [[ -S "$sock" ]]; then
                nvim --server "$sock" --remote-send ':source ~/.config/nvim/colors.lua<CR>' 2>/dev/null && ((nvim_reloaded++))
            fi
        done
    fi
    if [[ $nvim_reloaded -gt 0 ]]; then
        echo "  Neovim: reloaded ($nvim_reloaded instances)"
    fi
fi

# Fish - reload colors in running kitty terminals
if pgrep -x kitty > /dev/null && command -v kitty &> /dev/null; then
    kitty @ send-text --match 'cmdline:fish' 'source ~/.config/fish/conf.d/colors.fish\n' 2>/dev/null && echo "  Fish: reloaded"
fi

# Rofi - no daemon, reloads automatically on launch

echo "Done!"

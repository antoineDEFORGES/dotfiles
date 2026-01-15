# Arch Linux + Hyprland Dotfiles

A minimal, portable dotfiles setup for Arch Linux with Hyprland. Designed for developers working with Python, Go, C, JavaScript/TypeScript, React, and DevOps tools.

## Features

- **Portable** - Works on any machine without hardcoded paths
- **Modular** - Profile-based package installation (desktop, laptop, work)
- **Simple** - Minimal configs, no bloat
- **Developer-focused** - Git shortcuts, language paths, container tools

## Quick Start

```bash
# Clone the repo
git clone https://github.com/yourusername/dotfiles ~/personal/dotfiles
cd ~/personal/dotfiles

# Run the installer
./install.sh                      # Interactive
./install.sh --profile laptop     # Laptop with power management
./install.sh --profile desktop    # Desktop with gaming
./install.sh --nvidia             # Include NVIDIA drivers
./install.sh -y                   # Non-interactive (accept all)
```

After installation:
```bash
# Create machine-specific config
cp ~/.config/hypr/local.conf.example ~/.config/hypr/local.conf
nvim ~/.config/hypr/local.conf    # Edit for your monitor/GPU

# Start Hyprland
Hyprland
```

## Directory Structure

```
dotfiles/
├── hypr/                    # Hyprland window manager
│   ├── hyprland.conf        # Main config (portable)
│   ├── hyprlock.conf        # Lock screen
│   ├── hyprpaper.conf       # Wallpaper
│   └── local.conf.example   # Template for machine-specific settings
├── kitty/
│   └── kitty.conf           # Terminal config
├── fish/
│   ├── config.fish          # Shell config with dev shortcuts
│   ├── fish_plugins         # Fisher plugin list
│   ├── functions/           # Custom functions
│   ├── completions/         # Tab completions
│   └── conf.d/              # Auto-sourced configs
├── tmux/
│   └── tmux.conf            # Multiplexer config
├── waybar/
│   ├── config.jsonc         # Status bar modules
│   └── style.css            # Status bar styling
├── wallpapers/
│   └── one.jpg              # Default wallpaper
├── packages/                # Package lists
│   ├── core.txt             # Always installed
│   ├── aur.txt              # AUR packages
│   ├── nvidia.txt           # NVIDIA drivers
│   ├── laptop.txt           # Laptop profile
│   ├── desktop.txt          # Desktop profile
│   ├── work.txt             # Work profile
│   └── optional.txt         # Prompted packages
└── install.sh               # Bootstrap script
```

The install script creates symlinks from `~/.config/*` to this repo, so edits sync automatically.

## Key Bindings

| Key | Action |
|-----|--------|
| `Super + Return` | Open terminal (kitty) |
| `Super + D` | App launcher (rofi) |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle floating |
| `Super + S` | Screenshot region |
| `Super + Shift + L` | Lock screen |
| `Super + Shift + R` | Reload config |
| `Super + 1-5` | Switch workspace |
| `Super + Shift + 1-5` | Move window to workspace |
| `Super + H/J/K/L` | Move focus (vim-style) |
| `Super + Mouse` | Move/resize windows |

## Packages

### Core (Always Installed)

#### Hyprland & Wayland
| Package | Description |
|---------|-------------|
| `hyprland` | Tiling Wayland compositor with animations |
| `hyprpaper` | Fast wallpaper utility |
| `hyprlock` | GPU-accelerated lock screen |
| `hypridle` | Idle daemon (triggers lock/suspend) |
| `xdg-desktop-portal-hyprland` | Screen sharing and file dialogs |
| `sddm` | Display manager |
| `qt5-wayland` / `qt6-wayland` | Qt Wayland support |
| `polkit-kde-agent` | Authentication popups |

#### Terminal & Shell
| Package | Description |
|---------|-------------|
| `kitty` | GPU-accelerated terminal with image support |
| `zsh` | Shell with better autocompletion |
| `starship` | Fast, customizable prompt |

#### Editor
| Package | Description |
|---------|-------------|
| `neovim` | Modern Vim with Lua and LSP support |

#### Development Tools
| Package | Description |
|---------|-------------|
| `base-devel` | Build essentials (gcc, make) |
| `git` | Version control |
| `gcc` / `clang` | C/C++ compilers |
| `cmake` / `make` | Build systems |
| `ripgrep` | Fast text search (better grep) |
| `fd` | Fast file finder (better find) |
| `fzf` | Fuzzy finder |
| `jq` | JSON processor |

#### UI Components
| Package | Description |
|---------|-------------|
| `waybar` | Customizable status bar |
| `dunst` | Notification daemon |
| `thunar` | File manager |

#### Audio (PipeWire)
| Package | Description |
|---------|-------------|
| `pipewire` | Modern audio server |
| `pipewire-pulse` | PulseAudio compatibility |
| `wireplumber` | Session manager |
| `pavucontrol` | Volume control GUI |

#### Screenshots & Clipboard
| Package | Description |
|---------|-------------|
| `grim` / `slurp` | Screenshot tools |
| `hyprshot` | Hyprland screenshot utility |
| `wl-clipboard` | Clipboard utilities |
| `cliphist` | Clipboard history |

#### Fonts
| Package | Description |
|---------|-------------|
| `ttf-jetbrains-mono-nerd` | Terminal font with icons |
| `ttf-font-awesome` | Icon font for waybar |
| `noto-fonts` / `noto-fonts-emoji` | Unicode coverage |

#### Theming
| Package | Description |
|---------|-------------|
| `nwg-look` | GTK theme switcher |
| `kvantum` | Qt theme engine |

#### System Utilities
| Package | Description |
|---------|-------------|
| `stow` | Dotfiles symlink manager |
| `brightnessctl` | Brightness control |
| `playerctl` | Media player control |
| `udiskie` | Auto-mount USB drives |
| `btop` | System monitor |

---

### AUR Packages

| Package | Description |
|---------|-------------|
| `yay-bin` | AUR helper |
| `google-chrome` | Web browser |
| `visual-studio-code-bin` | Code editor |
| `rofi-wayland` | App launcher |
| `wlogout` | Logout menu |
| `catppuccin-gtk-theme-mocha` | Dark GTK theme |
| `papirus-icon-theme` | Icon theme |
| `bibata-cursor-theme` | Cursor theme |

---

### Profile: Laptop (`--profile laptop`)

Power management and battery optimization.

| Package | Description |
|---------|-------------|
| `tlp` | Automatic power optimization |
| `powertop` | Power consumption analyzer |
| `acpi` | Battery status CLI |
| `light` | Backlight control |
| `auto-cpufreq` | CPU frequency optimizer |

---

### Profile: Desktop (`--profile desktop`)

Gaming and virtualization.

| Package | Description |
|---------|-------------|
| `steam` | Game store |
| `gamemode` | Gaming performance optimizer |
| `mangohud` | FPS/stats overlay |
| `wine` | Windows compatibility |
| `qemu-full` / `virt-manager` | Virtual machines |

---

### Profile: Work (`--profile work`)

Enterprise tools and cloud CLI.

| Package | Description |
|---------|-------------|
| `slack-desktop` | Team chat |
| `zoom` | Video conferencing |
| `libreoffice-fresh` | Office suite |
| `obsidian` | Note-taking |
| `aws-cli-v2` | AWS CLI |
| `google-cloud-cli` | GCP CLI |
| `kubectl` / `helm` / `k9s` | Kubernetes tools |
| `dbeaver` | Database GUI |

---

### NVIDIA (`--nvidia`)

| Package | Description |
|---------|-------------|
| `nvidia-open` | Open-source kernel modules |
| `nvidia-utils` | Utilities (nvidia-smi) |
| `nvidia-settings` | Settings GUI |
| `libva-nvidia-driver` | Video acceleration |
| `egl-wayland` | Wayland support |

---

### Optional (Prompted)

Development languages and media tools.

| Package | Description |
|---------|-------------|
| `lazygit` | Terminal git UI |
| `docker` / `docker-compose` | Containers |
| `nodejs` / `npm` | JavaScript runtime |
| `python` / `python-pip` | Python |
| `go` | Go language |
| `rust` | Rust language |
| `obs-studio` | Screen recording |
| `discord` | Chat |

## Configuration

### Fish Shell

Development shortcuts in `~/.config/fish/config.fish`:

```fish
# Git
abbr -a g git
abbr -a gs 'git status'
abbr -a gc 'git commit'
abbr -a gp 'git push'
abbr -a gl 'git pull'
abbr -a gd 'git diff'
abbr -a glog 'git log --oneline --graph -10'

# Docker
abbr -a d docker
abbr -a dc 'docker compose'

# Kubernetes
abbr -a k kubectl
abbr -a kgp 'kubectl get pods'

# Dev
abbr -a nv nvim
abbr -a lg lazygit
```

PATH includes: `~/.local/bin`, `~/go/bin`, `~/.cargo/bin`, `~/.npm-global/bin`

### Tmux

- Prefix: `Ctrl+S`
- Split: `|` (horizontal), `-` (vertical)
- Navigate panes: `Alt+H/J/K/L`
- Navigate windows: `Alt+1-9`
- True color support enabled
- 50k line history for build logs

### Kitty

- Font: JetBrains Mono 16pt
- 10k scrollback lines
- Shell integration enabled
- Remote control for IDE integrations

### Machine-Specific Config

Create `~/.config/hypr/local.conf` for your hardware:

```ini
# Monitor (find name with: hyprctl monitors)
monitor = DP-1, 1920x1080@240, 0x0, 1

# NVIDIA (uncomment if needed)
# env = LIBVA_DRIVER_NAME,nvidia
# env = __GLX_VENDOR_LIBRARY_NAME,nvidia
# env = NVD_BACKEND,direct
```

## Customization

### Adding packages

Edit the appropriate file in `packages/`:
```bash
nvim packages/core.txt      # Always installed
nvim packages/optional.txt  # Prompted during install
```

### Adding configs

Create a new stow package:
```bash
mkdir -p newapp/.config/newapp
cp ~/.config/newapp/config newapp/.config/newapp/
cd ~/personal/dotfiles && stow newapp
```

### Updating configs

Edit files in the dotfiles repo, changes apply immediately (symlinks).

## Troubleshooting

### Hyprland won't start
1. Check `~/.config/hypr/local.conf` exists
2. Verify monitor name: `hyprctl monitors`
3. Check logs: `journalctl --user -xe`

### No sound
```bash
systemctl --user restart pipewire wireplumber
pavucontrol  # Check output device
```

### Screen sharing doesn't work
```bash
# Ensure portal is running
systemctl --user status xdg-desktop-portal-hyprland
```

## License

MIT

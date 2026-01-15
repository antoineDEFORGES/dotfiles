#!/bin/bash

#==============================================================================
#  Arch Linux + Hyprland Bootstrap Script
#
#  Reads packages from packages/*.txt files
#
#  Usage:
#    ./install.sh                      # Interactive install
#    ./install.sh --profile laptop     # Use laptop-specific packages
#    ./install.sh --profile desktop    # Use desktop-specific packages
#    ./install.sh --nvidia             # Include NVIDIA drivers
#    ./install.sh --list               # List available package files
#    ./install.sh --help               # Show help
#==============================================================================

set -e

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$DOTFILES_DIR/packages"
LOG_FILE="$HOME/.local/share/dotfiles-install.log"
AUR_HELPER="yay"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Flags
INSTALL_NVIDIA=false
INTERACTIVE=true
PROFILE=""
SKIP_AUR=false
SKIP_LINK=false

#------------------------------------------------------------------------------
# Helper Functions
#------------------------------------------------------------------------------

log() { echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"; }
success() { echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"; }
warning() { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"; }

header() {
  echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${PURPLE}  $1${NC}"
  echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

confirm() {
  [[ "$INTERACTIVE" = false ]] && return 0
  read -p "$(echo -e ${CYAN}"$1 [y/N]: "${NC})" -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]]
}

command_exists() { command -v "$1" &>/dev/null; }

package_installed() {
  pacman -Qi "$1" &>/dev/null 2>&1 ||
    ($AUR_HELPER -Qi "$1" &>/dev/null 2>&1 2>/dev/null)
}

#------------------------------------------------------------------------------
# Package File Functions
#------------------------------------------------------------------------------

# Read packages from file (ignores comments # and empty lines)
read_package_file() {
  local file="$1"
  [[ ! -f "$file" ]] && return 1
  grep -v '^\s*#' "$file" | grep -v '^\s*$' | sed 's/\s*#.*//' | xargs
}

# Count packages in a file
count_packages() {
  local file="$1"
  [[ ! -f "$file" ]] && echo "0" && return
  read_package_file "$file" | wc -w
}

# List all available package files
list_package_files() {
  header "Available Package Files"

  if [[ ! -d "$PACKAGES_DIR" ]]; then
    error "Packages directory not found: $PACKAGES_DIR"
    return 1
  fi

  echo -e "${CYAN}Location:${NC} $PACKAGES_DIR\n"

  for file in "$PACKAGES_DIR"/*.txt; do
    [[ ! -f "$file" ]] && continue
    local name=$(basename "$file" .txt)
    local count=$(count_packages "$file")
    local marker=""

    # Mark special files
    case "$name" in
    core) marker="${GREEN}(always installed)${NC}" ;;
    aur) marker="${YELLOW}(AUR)${NC}" ;;
    nvidia) marker="${YELLOW}(optional)${NC}" ;;
    optional) marker="${YELLOW}(optional)${NC}" ;;
    esac

    printf "  ${CYAN}%-12s${NC} %3s packages %s\n" "$name" "$count" "$marker"
  done
  echo
}

#------------------------------------------------------------------------------
# Installation Functions
#------------------------------------------------------------------------------

check_arch() {
  [[ ! -f /etc/arch-release ]] && error "This script is for Arch Linux only!" && exit 1
}

check_internet() {
  log "Checking internet connection..."
  if ! ping -c 1 archlinux.org &>/dev/null; then
    error "No internet connection!"
    exit 1
  fi
  success "Internet OK"
}

check_packages_dir() {
  if [[ ! -d "$PACKAGES_DIR" ]]; then
    error "Packages directory not found: $PACKAGES_DIR"
    exit 1
  fi

  if [[ ! -f "$PACKAGES_DIR/core.txt" ]]; then
    error "core.txt not found! Create $PACKAGES_DIR/core.txt"
    exit 1
  fi

  success "Package files found"
}

create_directories() {
  header "Creating Directories"

  local dirs=(
    "$HOME/.config"
    "$HOME/.local/bin"
    "$HOME/.local/share"
    "$HOME/.local/share/wallpapers"
    "$HOME/.cache"
    "$(dirname "$LOG_FILE")"
  )

  for dir in "${dirs[@]}"; do
    mkdir -p "$dir"
  done

  success "Directories created"
}

update_system() {
  header "Updating System"
  sudo pacman -Syu --noconfirm
  success "System updated"
}

install_aur_helper() {
  header "Installing AUR Helper"

  if command_exists "$AUR_HELPER"; then
    success "$AUR_HELPER already installed"
    return 0
  fi

  log "Installing $AUR_HELPER..."
  local tmp_dir=$(mktemp -d)
  git clone "https://aur.archlinux.org/${AUR_HELPER}.git" "$tmp_dir/$AUR_HELPER"
  cd "$tmp_dir/$AUR_HELPER"
  makepkg -si --noconfirm
  cd "$HOME"
  rm -rf "$tmp_dir"

  success "$AUR_HELPER installed"
}

# Install packages from a specific file
install_from_file() {
  local file="$1"
  local use_aur="${2:-false}"
  local name=$(basename "$file" .txt)

  if [[ ! -f "$file" ]]; then
    warning "File not found: $file"
    return 0
  fi

  header "Installing: $name"

  local packages=($(read_package_file "$file"))

  if [[ ${#packages[@]} -eq 0 ]]; then
    warning "No packages in $file"
    return 0
  fi

  log "Found ${#packages[@]} packages"

  # Filter already installed
  local to_install=()
  for pkg in "${packages[@]}"; do
    if ! package_installed "$pkg"; then
      to_install+=("$pkg")
    else
      log "Already installed: $pkg"
    fi
  done

  if [[ ${#to_install[@]} -eq 0 ]]; then
    success "All packages already installed"
    return 0
  fi

  log "Installing ${#to_install[@]} new packages..."
  echo -e "${CYAN}${to_install[*]}${NC}"

  if [[ "$use_aur" = true ]]; then
    $AUR_HELPER -S --noconfirm --needed "${to_install[@]}" ||
      warning "Some AUR packages failed"
  else
    sudo pacman -S --noconfirm --needed "${to_install[@]}" ||
      warning "Some packages failed"
  fi

  success "$name complete"
}

detect_nvidia() {
  if lspci | grep -i nvidia &>/dev/null; then
    success "NVIDIA GPU detected"
    if [[ "$INTERACTIVE" = true ]]; then
      confirm "Install NVIDIA drivers?" && INSTALL_NVIDIA=true
    else
      INSTALL_NVIDIA=true
    fi
  else
    log "No NVIDIA GPU detected"
  fi
}

install_nvidia() {
  [[ "$INSTALL_NVIDIA" = false ]] && return 0

  install_from_file "$PACKAGES_DIR/nvidia.txt" false

  header "Configuring NVIDIA for Wayland"

  # Kernel parameters hint
  warning "Add to your bootloader: nvidia_drm.modeset=1 nvidia_drm.fbdev=1"

  # Update mkinitcpio
  if [[ -f /etc/mkinitcpio.conf ]]; then
    if ! grep -q "nvidia nvidia_modeset" /etc/mkinitcpio.conf; then
      log "Adding NVIDIA modules to mkinitcpio..."
      sudo sed -i 's/MODULES=(\(.*\))/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm \1)/' /etc/mkinitcpio.conf
      sudo mkinitcpio -P
    fi
  fi

  # Hyprland NVIDIA config
  mkdir -p "$HOME/.config/hypr"
  cat >"$HOME/.config/hypr/nvidia.conf" <<'EOF'
# NVIDIA Wayland config (source this in hyprland.conf)
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct
env = WLR_NO_HARDWARE_CURSORS,1
EOF

  success "NVIDIA configured (reboot required!)"
}

setup_shell() {
  header "Setting Up Shell"

  if ! command_exists zsh; then
    warning "zsh not installed, skipping"
    return 0
  fi

  if [[ "$SHELL" != "$(which zsh)" ]]; then
    log "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    success "Default shell: zsh"
  else
    success "zsh already default"
  fi
}

setup_services() {
  header "Enabling Services"

  # System services
  local services=("NetworkManager" "bluetooth")
  for svc in "${services[@]}"; do
    if systemctl list-unit-files | grep -q "^$svc"; then
      sudo systemctl enable --now "$svc" 2>/dev/null && log "Enabled: $svc"
    fi
  done

  # User services
  local user_services=("pipewire" "pipewire-pulse" "wireplumber")
  for svc in "${user_services[@]}"; do
    systemctl --user enable --now "$svc" 2>/dev/null && log "Enabled (user): $svc"
  done

  success "Services enabled"
}

setup_lazyvim() {
  header "Setting Up LazyVim"

  if ! command_exists nvim; then
    warning "neovim not installed, skipping"
    return 0
  fi

  local nvim_dir="$HOME/.config/nvim"

  if [[ -d "$nvim_dir" ]]; then
    if [[ "$INTERACTIVE" = true ]]; then
      if ! confirm "Replace existing nvim config?"; then
        log "Keeping existing config"
        return 0
      fi
    fi
    local backup="$nvim_dir.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$nvim_dir" "$backup"
    warning "Backed up to: $backup"
  fi

  rm -rf "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"

  log "Cloning LazyVim..."
  git clone https://github.com/LazyVim/starter "$nvim_dir"
  rm -rf "$nvim_dir/.git"

  success "LazyVim installed (run nvim to complete setup)"
}

link_dotfiles() {
  header "Linking Dotfiles"

  # Create target directories
  mkdir -p "$HOME/.config/hypr"
  mkdir -p "$HOME/.config/kitty"
  mkdir -p "$HOME/.config/fish/functions"
  mkdir -p "$HOME/.config/fish/completions"
  mkdir -p "$HOME/.config/fish/conf.d"
  mkdir -p "$HOME/.config/tmux"
  mkdir -p "$HOME/.config/waybar"
  mkdir -p "$HOME/.config/wallpapers"

  # Helper function to create symlink
  link_file() {
    local src="$1"
    local dest="$2"

    if [[ -L "$dest" ]]; then
      rm "$dest"
    elif [[ -f "$dest" ]]; then
      mv "$dest" "$dest.backup"
      log "Backed up: $dest"
    fi

    ln -sf "$src" "$dest"
    log "Linked: $dest"
  }

  # Hyprland
  link_file "$DOTFILES_DIR/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
  link_file "$DOTFILES_DIR/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"
  link_file "$DOTFILES_DIR/hypr/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"

  # Kitty
  link_file "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

  # Fish
  link_file "$DOTFILES_DIR/fish/config.fish" "$HOME/.config/fish/config.fish"
  [[ -f "$DOTFILES_DIR/fish/fish_plugins" ]] && link_file "$DOTFILES_DIR/fish/fish_plugins" "$HOME/.config/fish/fish_plugins"

  # Fish functions
  for f in "$DOTFILES_DIR/fish/functions/"*.fish; do
    [[ -f "$f" ]] && link_file "$f" "$HOME/.config/fish/functions/$(basename "$f")"
  done

  # Fish completions
  for f in "$DOTFILES_DIR/fish/completions/"*.fish; do
    [[ -f "$f" ]] && link_file "$f" "$HOME/.config/fish/completions/$(basename "$f")"
  done

  # Fish conf.d
  for f in "$DOTFILES_DIR/fish/conf.d/"*.fish; do
    [[ -f "$f" ]] && link_file "$f" "$HOME/.config/fish/conf.d/$(basename "$f")"
  done

  # Tmux
  link_file "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

  # Waybar
  link_file "$DOTFILES_DIR/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"
  link_file "$DOTFILES_DIR/waybar/style.css" "$HOME/.config/waybar/style.css"

  # Wallpapers
  for f in "$DOTFILES_DIR/wallpapers/"*; do
    [[ -f "$f" ]] && link_file "$f" "$HOME/.config/wallpapers/$(basename "$f")"
  done

  success "Dotfiles linked"
}

generate_local_config() {
  header "Generating Machine-Specific Config"

  local hypr_local="$HOME/.config/hypr/local.conf"

  if [[ -f "$hypr_local" ]]; then
    log "local.conf already exists, skipping"
    return 0
  fi

  # Ensure directory exists
  mkdir -p "$HOME/.config/hypr"

  # Detect primary monitor
  local monitor="DP-1"
  if command_exists wlr-randr; then
    monitor=$(wlr-randr 2>/dev/null | grep -oP '^\S+' | head -1)
  fi
  monitor="${monitor:-DP-1}"

  # Detect GPU
  local has_nvidia=false
  lspci 2>/dev/null | grep -qi nvidia && has_nvidia=true

  log "Detected monitor: $monitor"
  log "NVIDIA GPU: $has_nvidia"

  # Generate local.conf
  cat > "$hypr_local" << EOF
# Machine-specific Hyprland config
# Generated by install.sh on $(date)
# Edit this file for your specific hardware

# Monitor (detected: $monitor)
monitor = $monitor, preferred, auto, 1
EOF

  # Add NVIDIA section if detected
  if [[ "$has_nvidia" = true ]] || [[ "$INSTALL_NVIDIA" = true ]]; then
    cat >> "$hypr_local" << 'EOF'

# NVIDIA GPU
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct
EOF
  fi

  success "Generated: $hypr_local"
  warning "Review and customize: $hypr_local"
}

setup_environment() {
  header "Setting Up Environment"

  local env_file="$HOME/.zshenv"

  [[ -f "$env_file" ]] && log "~/.zshenv exists, skipping" && return 0

  cat >"$env_file" <<'EOF'
# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Apps
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"
export BROWSER="google-chrome-stable"

# Wayland
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export QT_QPA_PLATFORM="wayland;xcb"
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GDK_BACKEND=wayland,x11
export MOZ_ENABLE_WAYLAND=1

# Path
export PATH="$HOME/.local/bin:$PATH"
EOF

  success "Environment configured"
}

print_post_install() {
  header "Installation Complete!"

  cat <<EOF

${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${GREEN}  All done! ${NC}
${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${CYAN}Next steps:${NC}
  1. Reboot (especially if NVIDIA was installed)
  2. Start Hyprland: ${YELLOW}Hyprland${NC}
  3. Launch nvim to finish plugin installation

${CYAN}Default keybindings:${NC}
  SUPER + Return   Terminal
  SUPER + D        App launcher
  SUPER + Q        Close window
  SUPER + E        File manager

${CYAN}Logs:${NC} $LOG_FILE

EOF
}

show_help() {
  cat <<EOF
${CYAN}Arch Linux + Hyprland Bootstrap${NC}

Usage: $0 [OPTIONS]

Options:
  --profile <n>   Also install packages/<n>.txt
  --nvidia           Install NVIDIA drivers
  --no-aur           Skip AUR packages
  --no-link          Skip linking dotfiles
  --list             List available package files
  --yes, -y          Non-interactive mode
  --help, -h         Show this help

Package files in packages/:
  core.txt           Always installed (required)
  aur.txt            AUR packages
  nvidia.txt         NVIDIA drivers (with --nvidia)
  optional.txt       Extra packages (prompted)
  laptop.txt         Laptop-specific (--profile laptop)
  desktop.txt        Desktop-specific (--profile desktop)
  work.txt           Work tools (--profile work)

Examples:
  $0                          # Interactive install
  $0 --profile laptop         # Install with laptop packages
  $0 --profile desktop --nvidia -y  # Desktop + NVIDIA, non-interactive
  $0 --list                   # Show all package files
EOF
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------

main() {
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --nvidia)
      INSTALL_NVIDIA=true
      shift
      ;;
    --no-aur)
      SKIP_AUR=true
      shift
      ;;
    --no-link)
      SKIP_LINK=true
      shift
      ;;
    --list)
      list_package_files
      exit 0
      ;;
    --yes | -y)
      INTERACTIVE=false
      shift
      ;;
    --help | -h)
      show_help
      exit 0
      ;;
    *)
      error "Unknown: $1"
      show_help
      exit 1
      ;;
    esac
  done

  # Banner
  clear
  echo -e "${PURPLE}"
  cat <<'EOF'
    ╔═══════════════════════════════════════════════════════════╗
    ║     █████╗ ██████╗  ██████╗██╗  ██╗    ██╗  ██╗██╗        ║
    ║    ██╔══██╗██╔══██╗██╔════╝██║  ██║    ██║  ██║██║        ║
    ║    ███████║██████╔╝██║     ███████║    ███████║██║        ║
    ║    ██╔══██║██╔══██╗██║     ██╔══██║    ██╔══██║██║        ║
    ║    ██║  ██║██║  ██║╚██████╗██║  ██║    ██║  ██║███████╗   ║
    ║    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚══════╝   ║
    ║                 Hyprland Bootstrap v2.0                   ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
  echo -e "${NC}"

  # Pre-flight
  check_arch
  check_internet
  check_packages_dir

  # Show what will be installed
  list_package_files

  [[ -n "$PROFILE" ]] && echo -e "${CYAN}Profile:${NC} $PROFILE"
  [[ "$INSTALL_NVIDIA" = true ]] && echo -e "${CYAN}NVIDIA:${NC} Yes"
  echo

  [[ "$INTERACTIVE" = true ]] && ! confirm "Proceed?" && exit 0

  # Init log
  mkdir -p "$(dirname "$LOG_FILE")"
  echo "=== Install started: $(date) ===" >>"$LOG_FILE"
  echo "Profile: $PROFILE, NVIDIA: $INSTALL_NVIDIA" >>"$LOG_FILE"

  # === INSTALLATION ===

  create_directories
  update_system
  install_aur_helper

  # Core packages (always)
  install_from_file "$PACKAGES_DIR/core.txt" false

  # AUR packages
  if [[ "$SKIP_AUR" = false && -f "$PACKAGES_DIR/aur.txt" ]]; then
    install_from_file "$PACKAGES_DIR/aur.txt" true
  fi

  # Profile-specific packages
  if [[ -n "$PROFILE" && -f "$PACKAGES_DIR/${PROFILE}.txt" ]]; then
    install_from_file "$PACKAGES_DIR/${PROFILE}.txt" true
  elif [[ -n "$PROFILE" ]]; then
    warning "Profile not found: $PACKAGES_DIR/${PROFILE}.txt"
  fi

  # Optional packages
  if [[ -f "$PACKAGES_DIR/optional.txt" ]]; then
    if [[ "$INTERACTIVE" = false ]] || confirm "Install optional packages?"; then
      install_from_file "$PACKAGES_DIR/optional.txt" true
    fi
  fi

  # NVIDIA
  if [[ "$INSTALL_NVIDIA" = false ]]; then
    detect_nvidia
  fi
  install_nvidia

  # === CONFIGURATION ===

  setup_shell
  setup_services
  setup_environment
  setup_lazyvim

  [[ "$SKIP_LINK" = false ]] && link_dotfiles

  # Generate machine-specific config
  generate_local_config

  # Done
  echo "=== Install completed: $(date) ===" >>"$LOG_FILE"
  print_post_install
}

main "$@"

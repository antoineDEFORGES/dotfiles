# Fish Shell Config

# Cursor
set -g fish_cursor_default block
set -g fish_cursor_insert block
set -g fish_cursor_replace_one underscore
set -g fish_cursor_visual block

# Colors
set -gx LS_COLORS "di=38;2;196;167;231"

# Vi mode
fish_vi_key_bindings

# PATH
fish_add_path $HOME/.local/bin
fish_add_path $HOME/go/bin
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.npm-global/bin

# Editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Go
set -gx GOPATH $HOME/go

# Node (global packages without sudo)
set -gx NPM_CONFIG_PREFIX $HOME/.npm-global

# Git abbreviations
abbr -a g git
abbr -a gs 'git status'
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gp 'git push'
abbr -a gl 'git pull'
abbr -a gd 'git diff'
abbr -a gco 'git checkout'
abbr -a gb 'git branch'
abbr -a glog 'git log --oneline --graph -10'

# Docker
abbr -a d docker
abbr -a dc 'docker compose'
abbr -a dps 'docker ps'

# Kubernetes
abbr -a k kubectl
abbr -a kgp 'kubectl get pods'
abbr -a kgs 'kubectl get svc'

# Dev shortcuts
abbr -a py python
abbr -a nv nvim
abbr -a lg lazygit

# Zoxide (smart cd)
if type -q zoxide
    zoxide init fish | source
end

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

# ──────────────────────────────────────────────────────────────
# Python
# ──────────────────────────────────────────────────────────────

# Pyenv
set -gx PYENV_ROOT $HOME/.pyenv
if test -d $PYENV_ROOT
    fish_add_path $PYENV_ROOT/bin
    if type -q pyenv
        pyenv init - | source
    end
end

# Poetry
if test -d $HOME/.local/share/pypoetry
    fish_add_path $HOME/.local/share/pypoetry/bin
end

# Pip
set -gx PIP_REQUIRE_VIRTUALENV true

# Python abbreviations
abbr -a py python
abbr -a py3 python3
abbr -a pip 'python -m pip'
abbr -a pip3 'python3 -m pip'
abbr -a venv 'python -m venv .venv'
abbr -a activate 'source .venv/bin/activate.fish'
abbr -a pir 'pip install -r requirements.txt'
abbr -a pf 'pip freeze > requirements.txt'
abbr -a pytest 'python -m pytest'

# ──────────────────────────────────────────────────────────────
# Node
# ──────────────────────────────────────────────────────────────

# Node (global packages without sudo)
set -gx NPM_CONFIG_PREFIX $HOME/.npm-global

# pnpm
set -gx PNPM_HOME $HOME/.local/share/pnpm
if test -d $PNPM_HOME
    fish_add_path $PNPM_HOME
end

# Node abbreviations
abbr -a ni 'npm install'
abbr -a nid 'npm install -D'
abbr -a nig 'npm install -g'
abbr -a nr 'npm run'
abbr -a nrs 'npm run start'
abbr -a nrd 'npm run dev'
abbr -a nrb 'npm run build'
abbr -a nrt 'npm run test'
abbr -a nci 'npm ci'
abbr -a nup 'npm update'
abbr -a npx npx

# Yarn
abbr -a ya yarn
abbr -a yi 'yarn install'
abbr -a yad 'yarn add'
abbr -a yadd 'yarn add -D'
abbr -a yrm 'yarn remove'

# pnpm
abbr -a pn pnpm
abbr -a pni 'pnpm install'
abbr -a pna 'pnpm add'
abbr -a pnad 'pnpm add -D'
abbr -a pnr 'pnpm run'
abbr -a pnx 'pnpm dlx'

# ──────────────────────────────────────────────────────────────
# Go
# ──────────────────────────────────────────────────────────────

set -gx GOPATH $HOME/go
set -gx GOBIN $GOPATH/bin

# Go abbreviations
abbr -a gob 'go build'
abbr -a gor 'go run'
abbr -a got 'go test'
abbr -a gotv 'go test -v'
abbr -a gotc 'go test -cover'
abbr -a gof 'go fmt ./...'
abbr -a gol 'golangci-lint run'
abbr -a gom 'go mod'
abbr -a gomt 'go mod tidy'
abbr -a gomi 'go mod init'
abbr -a goget 'go get -u'
abbr -a goi 'go install'

# ──────────────────────────────────────────────────────────────
# C/C++
# ──────────────────────────────────────────────────────────────

# Compiler flags
set -gx CC gcc
set -gx CXX g++

# C abbreviations
abbr -a mk make
abbr -a mkc 'make clean'
abbr -a mkb 'make -B'
abbr -a mkj 'make -j(nproc)'
abbr -a cmk 'cmake -B build'
abbr -a cmkb 'cmake --build build'
abbr -a cmkr 'cmake -B build -DCMAKE_BUILD_TYPE=Release'
abbr -a cmkd 'cmake -B build -DCMAKE_BUILD_TYPE=Debug'

# Compilation shortcuts
abbr -a gcc-w 'gcc -Wall -Wextra -Werror'
abbr -a gcc-d 'gcc -Wall -Wextra -g -O0'
abbr -a gcc-r 'gcc -O2'

# ──────────────────────────────────────────────────────────────
# Git abbreviations
# ──────────────────────────────────────────────────────────────

# Basic
abbr -a g git
abbr -a gs 'git status -sb'
abbr -a ga 'git add'
abbr -a gaa 'git add -A'
abbr -a gap 'git add -p'
abbr -a gc 'git commit'
abbr -a gcm 'git commit -m'
abbr -a gca 'git commit --amend'
abbr -a gcan 'git commit --amend --no-edit'

# Push/Pull/Fetch
abbr -a gp 'git push'
abbr -a gpf 'git push --force-with-lease'
abbr -a gpo 'git push -u origin HEAD'
abbr -a gl 'git pull'
abbr -a glr 'git pull --rebase'
abbr -a gf 'git fetch'
abbr -a gfa 'git fetch --all --prune'

# Branch
abbr -a gb 'git branch'
abbr -a gba 'git branch -a'
abbr -a gbd 'git branch -d'
abbr -a gbD 'git branch -D'
abbr -a gco 'git checkout'
abbr -a gcb 'git checkout -b'
abbr -a gsw 'git switch'
abbr -a gswc 'git switch -c'

# Diff
abbr -a gd 'git diff'
abbr -a gds 'git diff --staged'
abbr -a gdn 'git diff --name-only'
abbr -a gdh 'git diff HEAD~1'

# Log
abbr -a glog 'git log --oneline --graph -15'
abbr -a gloga 'git log --oneline --graph --all -20'
abbr -a glogp 'git log -p -3'
abbr -a glogs 'git log --stat -5'
abbr -a gwho 'git shortlog -sn'

# Stash
abbr -a gst 'git stash'
abbr -a gstp 'git stash pop'
abbr -a gstl 'git stash list'
abbr -a gsts 'git stash show -p'
abbr -a gstd 'git stash drop'

# Rebase
abbr -a grb 'git rebase'
abbr -a grbi 'git rebase -i'
abbr -a grbc 'git rebase --continue'
abbr -a grba 'git rebase --abort'
abbr -a grbs 'git rebase --skip'

# Merge
abbr -a gm 'git merge'
abbr -a gma 'git merge --abort'
abbr -a gmc 'git merge --continue'

# Cherry-pick
abbr -a gcp 'git cherry-pick'
abbr -a gcpa 'git cherry-pick --abort'
abbr -a gcpc 'git cherry-pick --continue'

# Reset
abbr -a grh 'git reset HEAD'
abbr -a grhh 'git reset --hard HEAD'
abbr -a grhu 'git reset --hard @{upstream}'
abbr -a grs 'git restore'
abbr -a grss 'git restore --staged'

# Remote
abbr -a gr 'git remote -v'
abbr -a gra 'git remote add'
abbr -a grr 'git remote remove'
abbr -a gru 'git remote set-url'

# Worktree
abbr -a gwt 'git worktree'
abbr -a gwta 'git worktree add'
abbr -a gwtl 'git worktree list'
abbr -a gwtr 'git worktree remove'

# Misc
abbr -a gbl 'git blame -w'
abbr -a gbs 'git bisect'
abbr -a gcl 'git clone --depth 1'
abbr -a gclean 'git clean -fd'
abbr -a gtag 'git tag'
abbr -a gsh 'git show --stat'

# ──────────────────────────────────────────────────────────────
# Docker
# ──────────────────────────────────────────────────────────────

abbr -a d docker
abbr -a dc 'docker compose'
abbr -a dps 'docker ps'

# ──────────────────────────────────────────────────────────────
# Kubernetes
# ──────────────────────────────────────────────────────────────

abbr -a k kubectl
abbr -a kgp 'kubectl get pods'
abbr -a kgs 'kubectl get svc'

# ──────────────────────────────────────────────────────────────
# General
# ──────────────────────────────────────────────────────────────

abbr -a nv nvim
abbr -a lg lazygit
abbr -a l 'ls -la'
abbr -a cls clear

# Zoxide (smart cd)
if type -q zoxide
    zoxide init fish | source
end

# direnv (auto-load .envrc)
if type -q direnv
    direnv hook fish | source
end

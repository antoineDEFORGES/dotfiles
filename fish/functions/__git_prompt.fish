function __git_prompt
    # Check if in git repo (fast check)
    set -l git_dir (git rev-parse --git-dir 2>/dev/null)
    or return

    # Use theme colors (fallback to defaults if not set)
    set -l c_branch (set -q c_git_branch; and echo $c_git_branch; or echo c4a7e7)
    set -l c_staged (set -q c_git_staged; and echo $c_git_staged; or echo 9ccfd8)
    set -l c_modified (set -q c_git_modified; and echo $c_git_modified; or echo f6c177)
    set -l c_untracked (set -q c_git_untracked; and echo $c_git_untracked; or echo 6e6a86)
    set -l c_conflict (set -q c_git_conflict; and echo $c_git_conflict; or echo eb6f92)
    set -l c_ahead (set -q c_git_ahead; and echo $c_git_ahead; or echo 9ccfd8)
    set -l c_behind (set -q c_git_behind; and echo $c_git_behind; or echo eb6f92)
    set -l c_op (set -q c_git_op; and echo $c_git_op; or echo eb6f92)
    set -l c_dim (set -q c_dim; and echo $c_dim; or echo 6e6a86)
    set -l c_tag (set -q c_git_tag; and echo $c_git_tag; or echo 31748f)
    set -l c_clean (set -q c_git_clean; and echo $c_git_clean; or echo 9ccfd8)

    set_color $c_dim
    echo -n "  "  # nf-dev-git_branch

    # ── Git operation state ──
    set -l git_op ""
    if test -d "$git_dir/rebase-merge"
        set git_op " REBASING"
        if test -f "$git_dir/rebase-merge/interactive"
            set git_op " REBASE-i"
        end
        set -l step (cat "$git_dir/rebase-merge/msgnum" 2>/dev/null)
        set -l total (cat "$git_dir/rebase-merge/end" 2>/dev/null)
        if test -n "$step" -a -n "$total"
            set git_op "$git_op $step/$total"
        end
    else if test -d "$git_dir/rebase-apply"
        if test -f "$git_dir/rebase-apply/rebasing"
            set git_op " REBASING"
        else if test -f "$git_dir/rebase-apply/applying"
            set git_op " AM"
        else
            set git_op " AM/REBASE"
        end
        set -l step (cat "$git_dir/rebase-apply/next" 2>/dev/null)
        set -l total (cat "$git_dir/rebase-apply/last" 2>/dev/null)
        if test -n "$step" -a -n "$total"
            set git_op "$git_op $step/$total"
        end
    else if test -f "$git_dir/MERGE_HEAD"
        set git_op " MERGING"
    else if test -f "$git_dir/CHERRY_PICK_HEAD"
        set git_op " CHERRY-PICK"
    else if test -f "$git_dir/REVERT_HEAD"
        set git_op " REVERTING"
    else if test -f "$git_dir/BISECT_LOG"
        set git_op " BISECTING"
    end

    if test -n "$git_op"
        set_color $c_op
        echo -n "$git_op "
    end

    # ── Branch / HEAD ──
    set -l branch (git branch --show-current 2>/dev/null)

    if test -n "$branch"
        set_color $c_branch
        echo -n "$branch"
    else
        # Detached HEAD - show tag, commit, or describe
        set -l tag (git describe --tags --exact-match HEAD 2>/dev/null)
        if test -n "$tag"
            set_color $c_tag
            echo -n " $tag"
        else
            set -l describe (git describe --contains --all HEAD 2>/dev/null | head -1)
            if test -n "$describe"
                set_color $c_modified
                echo -n " $describe"
            else
                set_color $c_modified
                echo -n " "(git rev-parse --short HEAD 2>/dev/null)
            end
        end
    end

    # ── Detailed status ──
    set -l staged 0
    set -l modified 0
    set -l untracked 0
    set -l conflicts 0

    for line in (git status --porcelain 2>/dev/null)
        set -l index (string sub -l 1 "$line")
        set -l worktree (string sub -s 2 -l 1 "$line")

        # Conflicts
        if test "$index" = "U" -o "$worktree" = "U" -o "$index$worktree" = "AA" -o "$index$worktree" = "DD"
            set conflicts (math $conflicts + 1)
        else
            # Staged changes
            if string match -qr '[MADRC]' "$index"
                set staged (math $staged + 1)
            end
            # Unstaged changes
            if string match -qr '[MD]' "$worktree"
                set modified (math $modified + 1)
            end
        end

        # Untracked
        if test "$index$worktree" = "??"
            set untracked (math $untracked + 1)
        end
    end

    # Display status counts
    if test $conflicts -gt 0
        set_color $c_conflict
        echo -n "  $conflicts"
    end
    if test $staged -gt 0
        set_color $c_staged
        echo -n "  $staged"
    end
    if test $modified -gt 0
        set_color $c_modified
        echo -n "  $modified"
    end
    if test $untracked -gt 0
        set_color $c_untracked
        echo -n "  $untracked"
    end

    # Clean indicator
    if test $conflicts -eq 0 -a $staged -eq 0 -a $modified -eq 0 -a $untracked -eq 0
        set_color $c_clean
        echo -n " "
    end

    # ── Ahead/Behind ──
    set -l ab (git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null | string split \t)
    if test (count $ab) -eq 2
        set -l ahead $ab[1]
        set -l behind $ab[2]
        if test "$ahead" -gt 0
            set_color $c_ahead
            echo -n "  $ahead"
        end
        if test "$behind" -gt 0
            set_color $c_behind
            echo -n "  $behind"
        end
    end

    # ── Stash count ──
    set -l stash_count (git stash list 2>/dev/null | wc -l | string trim)
    if test "$stash_count" -gt 0
        set_color $c_dim
        echo -n "  $stash_count"
    end

    # ── Worktree indicator ──
    set -l worktree_count (git worktree list 2>/dev/null | wc -l | string trim)
    if test "$worktree_count" -gt 1
        set_color $c_dim
        echo -n "  "(math $worktree_count - 1)
    end

    # ── Upstream tracking ──
    set -l upstream (git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
    if test -z "$upstream"
        # No upstream set
        set_color $c_modified
        echo -n " "
    else if not string match -q "origin/*" "$upstream"
        # Non-origin upstream
        set_color $c_dim
        echo -n " "(string replace -r '/.*' '' "$upstream")
    end

    set_color normal
end

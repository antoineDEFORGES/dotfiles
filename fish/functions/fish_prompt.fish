function fish_prompt
    set -l last_status $status
    set -l cwd (prompt_pwd)
    set -l git_branch (git branch --show-current 2>/dev/null)

    # Directory
    set_color 9ccfd8
    echo -n $cwd

    # Git
    if test -n "$git_branch"
        set_color 6e6a86
        echo -n " "
        set_color c4a7e7
        echo -n "$git_branch"
        if test -n "(git status --porcelain 2>/dev/null)"
            set_color f6c177
            echo -n "●"
        end
    end

    # Prompt
    if test $last_status -eq 0
        set_color c4a7e7
    else
        set_color eb6f92
    end
    echo -n " ❯ "
    set_color normal
end

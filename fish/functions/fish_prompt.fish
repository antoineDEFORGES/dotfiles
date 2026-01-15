function fish_prompt
    set -l last_status $status
    set -l cwd (prompt_pwd)

    # Use theme colors (fallback to defaults if not set)
    set -l c_dir (set -q c_directory; and echo $c_directory; or echo 9ccfd8)
    set -l c_prompt_ok (set -q c_prompt; and echo $c_prompt; or echo c4a7e7)
    set -l c_prompt_err (set -q c_prompt_error; and echo $c_prompt_error; or echo eb6f92)
    set -l c_ssh_color (set -q c_ssh; and echo $c_ssh; or echo f6c177)
    set -l c_k8s_color (set -q c_k8s; and echo $c_k8s; or echo 31748f)
    set -l c_venv_color (set -q c_venv; and echo $c_venv; or echo f6c177)
    set -l c_node_color (set -q c_node; and echo $c_node; or echo 9ccfd8)
    set -l c_aws_color (set -q c_aws; and echo $c_aws; or echo f6c177)
    set -l c_jobs_color (set -q c_jobs; and echo $c_jobs; or echo c4a7e7)
    set -l c_dim_color (set -q c_dim; and echo $c_dim; or echo 6e6a86)

    # Newline for breathing room
    echo

    # ── SSH indicator ──
    if set -q SSH_TTY
        set_color $c_ssh_color
        echo -n " "
        set_color $c_dim_color
        echo -n (whoami)@(hostname -s)
        echo -n " "
    end

    # ── Directory ──
    set_color --bold $c_dir
    echo -n " $cwd"
    set_color normal

    # ── Git info ──
    __git_prompt

    # ── Kubernetes context ──
    if type -q kubectl
        set -l k8s_ctx (kubectl config current-context 2>/dev/null)
        if test -n "$k8s_ctx"
            set_color $c_dim_color
            echo -n "  󱃾 "
            set_color $c_k8s_color
            echo -n $k8s_ctx
        end
    end

    # ── Python venv ──
    if set -q VIRTUAL_ENV
        set_color $c_dim_color
        echo -n "   "
        set_color $c_venv_color
        echo -n (basename $VIRTUAL_ENV)
    end

    # ── Node version (if .nvmrc or package.json exists) ──
    if test -f .nvmrc -o -f package.json
        if type -q node
            set_color $c_dim_color
            echo -n "   "
            set_color $c_node_color
            echo -n (node -v | string replace 'v' '')
        end
    end

    # ── AWS Profile ──
    if set -q AWS_PROFILE
        set_color $c_dim_color
        echo -n "   "
        set_color $c_aws_color
        echo -n $AWS_PROFILE
    end

    # ── Background jobs ──
    set -l job_count (jobs | wc -l | string trim)
    if test "$job_count" -gt 0
        set_color $c_dim_color
        echo -n "   "
        set_color $c_jobs_color
        echo -n $job_count
    end

    echo

    # ── Prompt char ──
    if test $last_status -eq 0
        set_color $c_prompt_ok
    else
        set_color $c_prompt_err
        echo -n " $last_status "
    end

    # Root gets different symbol
    if fish_is_root_user
        echo -n " "
    else
        echo -n "❯ "
    end
    set_color normal
end

function fish_right_prompt
    set -l duration $CMD_DURATION
    if test $duration -gt 1000
        set_color 6e6a86
        echo -n (math $duration / 1000)s
        set_color normal
    end
end

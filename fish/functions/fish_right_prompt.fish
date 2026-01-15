function fish_right_prompt
    set -l duration $CMD_DURATION

    # Command duration (show if > 500ms)
    if test $duration -gt 500
        set_color 6e6a86

        if test $duration -gt 3600000
            # Hours
            set -l hours (math -s0 $duration / 3600000)
            set -l mins (math -s0 $duration % 3600000 / 60000)
            echo -n $hours"h"$mins"m"
        else if test $duration -gt 60000
            # Minutes
            set -l mins (math -s0 $duration / 60000)
            set -l secs (math -s0 $duration % 60000 / 1000)
            echo -n $mins"m"$secs"s"
        else if test $duration -gt 1000
            # Seconds
            set -l secs (math -s1 $duration / 1000)
            echo -n $secs"s"
        else
            # Milliseconds
            echo -n $duration"ms"
        end

        set_color normal
    end
end

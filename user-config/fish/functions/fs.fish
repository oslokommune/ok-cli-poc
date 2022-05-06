#!/usr/bin/env fish

# Functions
function fs --description "Source output of script (fs = fish source)."
    if test -z $argv[1]
        echo "You need to specify command to execute."
        echo "USAGE: fs <command>"
        return 1
    end

    set -x IS_FISH_SOURCED true

    $argv > /tmp/fsout
    set -l exit_code $status

    if not test $exit_code -eq 0
        echo Error: command returned exit code $exit_code with output:
        echo
        cat /tmp/fsout

        return $exit_code
    end
    
    #echo "Sourcing:"
    #cat /tmp/fsout

    source /tmp/fsout
end

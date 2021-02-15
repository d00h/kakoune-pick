provide-module pick-file %{
    require-module pick-base
    declare-option str pick_file_find "fd --no-ignore-vcs --type file | sort"

    define-command -docstring %{
        } pick-file -params 0.. %{
        evaluate-commands %sh{
            set -o noglob
            output=$(mktemp -d -t kak-temp-XXXXXXXX)/fifo
            mkfifo ${output}
            ( ${kak_opt_pick_file_find} . | \
              ${kak_opt_pick_filter} "$*" > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null
            echo "
                set-register '/' %val{bufname} 
                edit! -readonly -fifo ${output} *pick-file* 10
                set-option buffer filetype grep
                hook buffer NormalKey <ret> pick-file-jump
                hook buffer BufCloseFifo .* %{
                    execute-keys -client ${kak_client} n
                }
                hook buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output})} }"
        }
    }

}

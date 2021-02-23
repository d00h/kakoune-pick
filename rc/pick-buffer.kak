provide-module pick-buffer %{
    require-module pick-base

    define-command -hidden list-buffers-jump %{
        execute-keys '<a-x>s([^\n\r]+)<ret>'
        buffer "%reg{1}"
    }

    define-command -docstring %{
        find buffer and jump

        usage: list-buffers filter
         } list-buffers -params 0.. %{
        evaluate-commands %sh{
            set -o noglob
            output=$(mktemp -d -t kak-temp-XXXXXXXX)/fifo
            mkfifo ${output}
            ( echo ${kak_buflist} | tr " " "\n" | sort |  \
              ${kak_opt_pick_filter} "$*" > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null
            echo "
                set-register '/' %val{bufname} 
                edit! -readonly -fifo ${output} *buffers*
                pick-highlight-hook
                hook -once global WinDisplay .* %{ try %{ delete-buffer! *buffers* } }
                set-option buffer filetype grep
                hook buffer NormalKey <ret> list-buffers-jump
                hook buffer BufCloseFifo .* %{
                    execute-keys -client ${kak_client} n
                    evaluate-commands -client ${kak_client} pick-highlight-line
                }
                hook buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output})} }"
        }
    }
}

provide-module dh-find-buffer %{
    declare-option str find_buffer_filter "fzf --tiebreak index +i --filter"

    define-command -override -hidden find-buffer-jump %{
        try %{
            execute-keys '<a-x>s([^\n\r]+)<ret>'
            buffer "%reg{1}"
        }
    }

    define-command -override -hidden find-buffer-refresh %{
        add-highlighter -override "buffer/find-buffer-cursor" line %val{cursor_line} PrimarySelection
    }

    define-command -override -docstring %{
        find buffer and jump

        usage: find-buffer filter
         } find-buffer -params 0.. %{
        evaluate-commands %sh{
            set -o noglob
            output=$(mktemp -d -t kak-temp-XXXXXXXX)/fifo
            mkfifo ${output}
            ( echo ${kak_buflist} | tr " " "\n" | sort |  \
              ${kak_opt_find_buffer_filter} "$*" > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null
            echo "
                set-register '/' %val{bufname} 
                edit! -readonly -fifo ${output} '*buffers*'

                find-buffer-refresh
                hook -once global WinDisplay .* %{ try %{ delete-buffer! '*buffers*' } }
                hook buffer RawKey .* %{ find-buffer-refresh }
                set-option buffer filetype grep
                hook buffer NormalKey <ret> find-buffer-jump
                hook buffer BufCloseFifo .* %{
                    execute-keys -client ${kak_client} n
                    evaluate-commands -client ${kak_client} find-buffer-refresh
                }
                hook buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output})} }"
        }
    }
}

provide-module dh-find-file %{

    declare-option str find_file_command "fd --no-ignore-vcs --type file --exclude *.pyc"
    declare-option str find_file_filter "fzf --tiebreak index +i --filter"

    define-command -override -hidden find-file-refresh %{
        add-highlighter -override "buffer/find-file-cursor" line %val{cursor_line} PrimarySelection
    }

    define-command -override -hidden find-file-jump %{
        try %{
            execute-keys '<a-x>s^([^\n\r]*)$<ret>'
            edit -existing %reg{1} 
        }
    }

    define-command -override -docstring %{
        find file and jump

        usage: find-file filter
         } find-file -params 0.. %{
        evaluate-commands %sh{
            set -o noglob
            output=$(mktemp -d -t kak-temp-XXXXXXXX)/fifo
            mkfifo ${output}
            ( ${kak_opt_find_file_command} . | \
              ${kak_opt_find_file_filter} "$*" > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null
            echo "
                set-register '/' %val{bufname} 
                edit! -readonly -fifo ${output} '*files*'
                find-file-refresh
                hook -once global WinDisplay .* %{ try %{ delete-buffer! '*files*' } }

                hook buffer RawKey .* %{ find-file-refresh }
                set-option buffer filetype grep
                hook buffer NormalKey <ret> find-file-jump
                hook buffer BufCloseFifo .* %{
                    execute-keys -client ${kak_client} n
                    evaluate-commands -client ${kak_client} find-file-refresh
                }
                hook buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output})} }"
        }
    }
}

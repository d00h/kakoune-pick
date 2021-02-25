provide-module pick-kakoune %{
    require-module pick-base
    declare-option str pick_kakoune_find "fd --no-ignore-vcs --type file --extension kak"

    define-command -hidden list-kakoune-jump %{
        execute-keys '<a-x>s([^\n\r]+)<ret>'
        source %reg{1}
    }

    define-command -docstring %{
        Find kakoune scripts and execute its
        editor sessions for example

        usage: list-kakoune filter
    } list-kakoune -params .. %{
        evaluate-commands %sh{
            set -o noglob
            output=$(mktemp -d -t kak-temp-XXXXXXXX)/fifo
            mkfifo ${output}
            ( ${kak_opt_pick_kakoune_find} . | \
              ${kak_opt_pick_filter} "$*" > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null
            echo "edit! -readonly -fifo ${output} '*kakoune*'
               pick-highlight-hook
               hook -once global WinDisplay .* %{ try %{ delete-buffer! '*kakoune*' } }
               set-option buffer filetype grep
               hook buffer NormalKey <ret> list-kakoune-jump 
               hook buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output})} }"
        }
    }
}


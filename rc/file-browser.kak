provide-module -override dh-file-browser %{
    
    declare-option -hidden str file_browser_command "ls --color=never -1 --group-directories-first -p"
    declare-option -hidden str file_browser_target
    declare-option -hidden str-to-str-map file_browser_pos

    define-command -override -hidden file-browser-save-pos %{
        set-option -add global file_browser_pos "%opt{file_browser_target}=%val{cursor_line}"
    }

    define-command -override -hidden file-browser-restore-pos %{
        execute-keys %sh{
            eval "set -- $kak_quoted_opt_file_browser_pos"
            while [ $# -gt 0 ]; do
                target=${1%%=*}
                saved_pos=${1#*=}
                if [ "${target}" == "${kak_opt_file_browser_target}" ]; then
                    echo "${saved_pos}g"
                fi
                shift
            done;
        }
        file-browser-refresh
    }

    define-command -override -hidden file-browser-refresh %{
        echo %opt{file_browser_target}
        add-highlighter -override "buffer/file-browser-cursor" line %val{cursor_line} PrimarySelection
        add-highlighter -override "buffer/file-browser-folder" regex ^[^/]+/[^\n]* 0:type
    }
    
    define-command -override -hidden file-browser-select-up %{
        file-browser-save-pos
        execute-keys '<a-x>s^([^\n\r]*)$<ret>'
        file-browser-select "%opt{file_browser_target}/%reg{1}"
    }

    define-command -override -hidden file-browser-select-down %{
        file-browser-save-pos
        file-browser-select "%opt{file_browser_target}/.."
    }
    
    define-command -override -hidden file-browser-select -params 1 %{
        evaluate-commands %sh{
            set -o noglob
            target=$(realpath $1)
            if [ -d "${target}" ]; then
                output=$(mktemp -d -t kak-temp-XXXXXXXX)/fifo
                mkfifo ${output}
                ( ${kak_opt_file_browser_command} ${target} > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null
                echo "
                    edit! -readonly -fifo ${output} '*files*'
                    set-option buffer file_browser_target ${target}
                    hook buffer BufCloseFifo .* %{
                        evaluate-commands -client ${kak_client} file-browser-restore-pos
                    }
                    hook buffer RawKey .* %{ file-browser-refresh }
                    hook -once global WinDisplay .* %{ try %{ delete-buffer! '*files*' } }
                    hook -once buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output})} }
                    map buffer normal <ret> ': file-browser-select-up<ret>'
                    map buffer normal l ': file-browser-select-up<ret>'
                    map buffer normal e ': file-browser-select-up<ret>'
                    map buffer normal h ': file-browser-select-down<ret>'
                "
            elif [ -f "${target}" ]; then
                echo "
                    edit -existing ${target}
                "
            fi;
       }
    }

    define-command -override -docstring %{
        usage: file-browser
    } file-browser -params 0 %{
        evaluate-commands %sh{
            if [ -f "${kak_buffile}" ]; then
                target=$(dirname ${kak_buffile})
                echo "file-browser-select ${target}"
            else
                echo "file-browser-select ."
            fi;
        }
    }
}

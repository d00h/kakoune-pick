provide-module dh-find-action %{
    declare-option -hidden int find_action_pos 1
    declare-option str-to-str-map find_action_config

    define-command -override -docstring %{
        usage: add-action name command
    } add-action -params 2 %{
        set-option -add global find_action_config "%arg{1}=%arg{2}"
    }

    define-command -override -docstring %{
        usage: clear-actions 
    } clear-actions -params 0 %{ set-option global find_action_config }

    define-command -override -hidden find-action-run %{
        set-option global find_action_pos %val{cursor_line}
        execute-keys '<a-x>s([^\n\r]+)<ret>'
        evaluate-commands -client %val{client} %sh{
            echo delete-buffer! "*actions*"
            eval "set -- $kak_quoted_opt_find_action_config"
            while [ $# -gt 0 ]; do
                name=${1%%=*}
                command=${1#*=}
                if [ "${name}" == "${kak_reg_1}" ]; then
                    echo "${command}"
                fi
                shift
            done;
        }
    }

    define-command -override -hidden find-action-restore-pos %{
        execute-keys %opt{find_action_pos}g
        find-action-refresh
     }

    define-command -override -hidden find-action-refresh %{
        add-highlighter -override "buffer/find-action-cursor" line %val{cursor_line} PrimarySelection
    }

    define-command -override -docstring %{
        find action and run

        usage: find-action
         } find-action -params 0 %{
        evaluate-commands %sh{
            set -o noglob
            output=$(mktemp -d -t kak-temp-XXXXXXXX)/fifo
            mkfifo ${output}
            ( (
                eval "set -- $kak_quoted_opt_find_action_config"
                while [ $# -gt 0 ]; do
                    name=${1%%=*}
                    command=${1#*=}
                    echo ${name}
                    shift
                done;
            ) > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null
            echo "
                edit! -readonly -fifo ${output} '*actions*' 
                set-option buffer filetype grep
                hook buffer RawKey .* %{ find-action-refresh }
                hook -once global WinDisplay .* %{ try %{ delete-buffer! '*actions*' } }
                hook buffer NormalKey <ret> find-action-run
                hook buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output})} }
                hook buffer BufCloseFifo .* %{
                    evaluate-commands -client ${kak_client} find-action-restore-pos
                }
           "
         }
    }
}

# Debug
# clear-actions
# add-action hello "echo hello world!"
# add-action bye %{
#     echo bye bye!
# }
# add-action "make build1" %{
#     make build
# }

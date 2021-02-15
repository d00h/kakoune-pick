provide-module pick-base %{
    declare-option str pick_filter "fzf --tiebreak index +i --filter"

    define-command -hidden pick-file-jump %{
        evaluate-commands %{ 
            try %{
                execute-keys '<a-x>s^([^\n\r]*)$<ret>'
                edit -existing %reg{1} 
            }
        }
    }

    define-command -hidden pick-error-jump %{
        evaluate-commands %{ 
            try %{
                execute-keys '<a-x>s^([^:]+):(\d+)<ret>'
                edit -existing %reg{1} %reg{2} 
            }
        }
    }
}





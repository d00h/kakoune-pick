declare-option -hidden str pick_python_script %val{source}

provide-module pick-python  %{
    require-module pick-base

    define-command list-python -docstring %{
            grep ast places in python source via xpath
        } -params 1.. %{
        evaluate-commands %sh{
            set -o noglob
            output=$(mktemp -d -t kak-temp-XXXXXXXX)/fifo
            mkfifo ${output}
            target=$1
            shift
            ( python "${kak_opt_pick_python_script%.*}.py" grep ${target} . | \
              ${kak_opt_pick_filter} "$*" > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null
            echo "edit! -readonly -fifo ${output} *python*
               hook -once global WinDisplay .* %{ try %{ delete-buffer! *python* } }
               set-option buffer filetype grep
               hook buffer NormalKey <ret> pick-error-jump
               hook buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output})} }"
        }
    }

    define-command -docstring %{
           find python places
              class
              def

           usage: list-python-tags filter
        } list-python-tags -params .. %{ list-python tags %arg{@} }

    define-command -docstring %{
           find python functions with decorator
             @route

           usage: list-python-routes filter
        } list-python-routes -params .. %{ list-python routes %arg{@} }

    define-command -docstring %{
           find python functions
           start with 'test_'

           usage: list-python-tests filter
        } list-python-tests -params .. %{ pick-python tests %arg{@} }

    define-command -docstring %{
           find python functions with
             @fixture
             @yield_fixture

           usage: list-python-fixtures filter
        } list-python-fixtures  -params .. %{ pick-python fixtures %arg{@} }
} 



declare-option str plantuml_command "java -jar /home/d00h/Apps/plantuml/plantuml.jar -tutxt -pipe"

define-command -override plantuml %{
 evaluate-commands %sh{
    set -o noglob
    output=$(mktemp -d -t kak-temp-XXXXXXXX)/fifo
    mkfifo ${output}
    ( cat ${kak_buffile} | ${kak_opt_plantuml_command} > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null
    echo "
          echo -debug \"cat ${kak_buffile} | ${kak_opt_plantuml_command}\"
          edit! -readonly -fifo ${output} '*plantuml*'
          hook -once global WinDisplay .* %{ try %{ delete-buffer! '*planuml*' } }
          hook buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output})} }"
         "
   }
}

# nop %sh{
#       ( java -jar ${HOME}/Apps/plantuml/plantuml.jar -tutxt ${kak_buffile} )&
# }      

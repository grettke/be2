# shellcheck disable=SC2039,SC2112

function moshemal() {
  if [ "$#" -ne 1 ] || [ -z "$1" ] ; then
    printf "Evaluate a single-line EXPR on a local Emacs instance defined in the variable EMACSSOCKET.\n"
    printf "Usage: %s EXPR.\n" "${FUNCNAME[0]} "
    return 1
  fi
  local code="$1"
  local val=$(/usr/local/bin/emacs --batch --eval "(progn (require 'server) (princ (server-eval-at \"$EMACSSOCKET\" '$code)))")
  printf "%s\n" "$val"
}

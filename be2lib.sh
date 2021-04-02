# shellcheck disable=SC2039,SC2112

function be2() {
  if [ "$#" -ne 1 ] || [ -z "$1" ] ; then
    printf "Evaluate a single-line quoted EXPR on a local Emacs instance defined in the variable BE2SOCKET.\n"
    printf "Usage: %sEXPR.\n" "${FUNCNAME[0]} "
    return 1
  fi
  local code="$1"
  local val
  val=$(/usr/local/bin/emacs --batch --eval "(progn (require 'server) (princ (server-eval-at \"$BE2SOCKET\" '$code)))")
  printf "%s\n" "$val"
}

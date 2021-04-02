# shellcheck disable=SC2039,SC2112

function moshemal() {
  if [ "$#" -ne 1 ] || [ -z "$1" ] ; then
    printf "Evaluate a single-line quoted EXPR on a local Emacs instance defined in the variable MOSHEMALSOCKET.\n"
    printf "Usage: %sEXPR.\n" "${FUNCNAME[0]} "
    return 1
  fi
  local code="$1"
  local val
  val=$(/usr/local/bin/emacs --batch --eval "(progn (require 'server) (princ (server-eval-at \"$MOSHEMALSOCKET\" '$code)))")
  printf "%s\n" "$val"
}

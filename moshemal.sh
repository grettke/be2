#!/usr/local/bin/bash
# shellcheck disable=SC2039,SC2112

function moshemal() {
  local code="$1"
  local val=$(/usr/local/bin/emacs --batch --eval "(progn (require 'server) (princ (server-eval-at \"$EMACSSOCKET\" '$code)))")
  printf "%s\n" "$val"
}

moshemal "$1"

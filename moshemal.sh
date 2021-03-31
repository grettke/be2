!#/usr/local/bin/emacs
# shellcheck disable=SC2039,SC2112

function moshemal() {
  local code="$1"
  local val=$(/usr/local/bin/emacs --batch --eval "(progn (require 'server) (princ (server-eval-at \"/Users/gcr/server-sockets/emacs-gcr.sock\" '$code)))")
  printf "%s\n" "$val"
}

moshemal "$1"
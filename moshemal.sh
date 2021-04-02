#!/usr/local/bin/bash

export MOSHEMALSOCKET="/Users/gcr/server-sockets/emacs.sock"
export MOSHEMALHOME="/Users/gcr/src/moshemal"

source "$MOSHEMALHOME/moshemallib.sh"

moshemal "$1"

#!/bin/sh
if [[ ${SHIFTER_RUNTIME:-} ]]; then
    ulimit -c 0
    unset PYTHONPATH
    unset PYTHONSTARTUP
    export HOME=/home/vagrant
    export PYENV_ROOT=$HOME/.pyenv
    source "$HOME"/.bashrc >& /dev/null
    eval export HOME=~$USER
fi
exec "$@"

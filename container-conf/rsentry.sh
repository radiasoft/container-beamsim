#!/bin/sh
# Non-root users get the full {build_run_user_home} environment in the container.
if (( $EUID != 0 )); then
    # No core files. If someone wants a corefile, the can raise the limit.
    ulimit -c 0
    unset PYTHONPATH
    unset PYTHONSTARTUP
    export HOME={build_run_user_home}
    export PYENV_ROOT=$HOME/.pyenv
    source "$HOME"/.bashrc >& /dev/null
    eval export HOME=~$USER
fi
exec "$@"

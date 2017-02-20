#!/bin/bash
#
# To run: curl radia.run | bash -s containers/radiasoft/beamsim codes...
#
set -e
: ${beamsim_repo:=https://github.com/radiasoft/container-beamsim}

beamsim_main() {
    if [ ! $@ ]; then
        install_usage 'you must specify a list of codes to install'
    fi
    echo "$@"
    install_tmp_dir
    git clone -q "$beamsim_repo"
    cd "$(basename $beamsim_repo)/container-conf"
    bash -l codes.sh "$@"
}

beamsim_main "${install_extra_args[@]}"

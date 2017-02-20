#!/bin/bash
build_image_base=radiasoft/python2

build_as_run_user() {
    cd "$build_guest_conf"
    local noise_pid
    if [[ $TRAVIS == true ]]; then
        while true; do
            echo "$(date): some noise for travis"
            sleep 60
        done &
        noise_pid=$!
    fi
    . ./codes.sh
    if [[ -n $noise_pid ]]; then
        kill -9 "$noise_pid"
    fi
}

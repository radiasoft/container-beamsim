#!/bin/bash
build_image_base=radiasoft/beamsim-part1
build_travis_trigger_next=( radiasoft/sirepo beamsim-jupyter )

build_as_run_user() {
    cd "$build_guest_conf"
    curl radia.run | codes_dir="$(pwd)/codes" bash -s srw rslinac rsbeams
}

#!/bin/bash
build_image_base=radiasoft/beamsim-part1
build_travis_trigger_next=( sirepo beamsim-jupyter )

build_as_run_user() {
    cd "$build_guest_conf"
    . ./codes.sh
}

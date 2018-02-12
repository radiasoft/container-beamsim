#!/bin/bash
build_image_base=radiasoft/beamsim-part2
build_travis_trigger_next=( radiasoft/sirepo beamsim-jupyter )
build_is_public=1

build_as_run_user() {
    cd "$build_guest_conf"
    install_repo_eval code jspec warp srw rslinac rsbeams
}

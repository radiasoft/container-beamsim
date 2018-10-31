#!/bin/bash
build_image_base=radiasoft/python2
build_travis_trigger_next=( radiasoft/sirepo beamsim-jupyter )
build_is_public=1

build_as_run_user() {
    install_repo_eval beamsim-codes
    build_run_user_home_chmod_public
}

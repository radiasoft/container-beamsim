#!/bin/bash
build_image_base=radiasoft/fedora
build_travis_trigger_next=( radiasoft/sirepo beamsim-jupyter )
build_is_public=1

build_as_run_user() {
    # Make sure permissions after home-env are right
    build_run_user_home_chmod_public
    # now install beasim-codes which should already be public
    install_repo_eval beamsim-codes
}

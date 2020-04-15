#!/bin/bash
build_image_base=radiasoft/fedora
build_travis_trigger_next=( radiasoft/sirepo beamsim-jupyter )
build_is_public=1

build_as_run_user() {
    umask 022
    # Install beamsim-codes which should already be public
    install_repo_eval beamsim-codes
}

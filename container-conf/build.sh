#!/bin/bash
build_docker_entrypoint='["/rsentry"]'
build_image_base=radiasoft/fedora
build_is_public=1

build_as_root() {
    export build_run_user_home
    build_replace_vars rsentry.sh /rsentry
    chmod a=rx /rsentry
}

build_as_run_user() {
    # Install beamsim-codes which should already be public
    install_repo_eval beamsim-codes
}

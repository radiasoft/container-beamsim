#!/bin/bash
build_docker_entrypoint='["/rsentry"]'
build_image_base=radiasoft/fedora
build_is_public=1

build_as_root() {
    install -m 555 rsentry.sh /rsentry
}

build_as_run_user() {
    # Install beamsim-codes which should already be public
    install_repo_eval beamsim-codes
}

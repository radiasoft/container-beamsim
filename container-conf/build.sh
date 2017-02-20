#!/bin/bash
build_image_base=radiasoft/python2

build_as_run_user() {
    cd "$build_guest_conf"
    . ./codes.sh
}

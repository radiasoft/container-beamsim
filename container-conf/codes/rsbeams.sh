#!/bin/bash
#in part1: codes_dependencies common
rsbeams_pwd=$(pwd)
for r in rsbeams rssynergia rswarp; do
    codes_download radiasoft/"$r"
    codes_patch_requirements_txt
    python setup.py install
    cd "$rsbeams_pwd"
done

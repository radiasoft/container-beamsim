#!/bin/bash
#part1: codes_dependencies common
codes_dependencies xraylib
codes_download srio/shadow3
#TODO(robnagler) shadow3 doesn't include dependencies
# codes_patch_requirements_txt
python setup.py install

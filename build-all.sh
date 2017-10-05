#!/bin/bash
#
# Travis dies on long builds so run this to build a container
#
set -euo pipefail
export build_push=1
cd ~/src/radiasoft
for f in python2 beamsim-part1 beamsim-part2 beamsim; do
    cd "container-$f"
    curl radia.run | bash -s container-build
    cd ..
done

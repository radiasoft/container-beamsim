#!/bin/bash
pip uninstall -y opmd-viewer >& /dev/null || true
codes_download https://github.com/openPMD/openPMD-viewer.git 0f63a238c26b52244565063a05f424a512663476
python setup.py install

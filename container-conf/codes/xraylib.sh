#!/bin/bash
codes_yum install swig
codes_download http://lvserver.ugent.be/xraylib/xraylib-3.2.0.tar.gz
./configure --prefix="$(pyenv prefix)" \
    --enable-python --disable-perl \
    --disable-ruby \
    --disable-python-numpy \
    --disable-fortran2003
make
make install

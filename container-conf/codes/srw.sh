#!/bin/bash
codes_dependencies common
codes_yum install fftw2-devel
codes_dependencies mpi4py
srw_pwd=$PWD
codes_download mrakitin/bnlcrl
codes_patch_requirements_txt
python setup.py install
cd "$srw_pwd"
# ochubar/SRW is over 600MB so GitHub times out sometimes. This is a
# stripped down copy
codes_download SRW-light '' SRW
perl -pi -e 's/-j8//' Makefile
perl -pi -e "s/'fftw'/'sfftw'/" cpp/py/setup.py
perl -pi -e 's/-lfftw/-lsfftw/; s/\bcc\b/gcc/; s/\bc\+\+/g++/' cpp/gcc/Makefile
make
d=$(python -c 'import distutils.sysconfig as s; print s.get_python_lib()')
(
    cd env/work/srw_python
    install -m 644 {srwl,uti}*.py srwlpy.so "$d"
)

#!/bin/bash
#part1: codes_dependencies common
codes_dependencies  Forthon pygist openPMD
# May only be needed for diags in warp init warp_script.py
pip install python-dateutil
warp_pwd=$PWD
codes_download https://bitbucket.org/berkeleylab/warp.git 4b3428bb01d7506b66be721f5413f53729d93903
cd pywarp90
make clean install
cat > setup.local.py <<'EOF'
if parallel:
    import os, re
    r = re.compile('^-l(.+)', flags=re.IGNORECASE)
    for x in os.popen('mpifort --showme:link').read().split():
        m = r.match(x)
        if not m:
            continue
        arg = m.group(1)
        if x[1] == 'L':
             library_dirs.append(arg)
             extra_link_args += ['-Wl,-rpath', '-Wl,' + arg]
        else:
             libraries.append(arg)
EOF
make FCOMP='-F gfortran --fcompexec mpifort' pclean pinstall
cd "$warp_pwd"
codes_download https://depot.radiasoft.org/foss/warp-initialization-tools-20160519.tar.gz
python setup.py install

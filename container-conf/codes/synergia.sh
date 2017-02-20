#!/bin/bash
#
# You need 2GB RAM at least or mpicxx will run out of virtual memory
#
# Testing
#     synergia=$(pwd)/install/bin/synergia
#     cd build/synergia2/examples/fodo_simple1
#     LD_LIBRARY_PATH=/usr/lib64/openmpi/lib $synergia fodo_simple1.py
#
#     cd build/synergia2
#     make test
#     Expect:
#         100% tests passed, 0 tests failed out of 177
#         Total Test time (real) = 421.95 sec
#
# Debugging:
#     full clean: git clean -dfx
#     partial clean: rm -rf db/*/chef-libs build/chef-libs
#     ./contract.py
#
# Once bootstrap is installed, you can do this to see what's what:
#     rm -rf config; DEBUG_CONFIG=1 ./contract.py --list-targets

# We can't the stock RPMs from Fedora, because...
#
#     libpng: tries to import libpng.h directly, instead of /usr/include/libpng16/png.h
#
#     NLopt: finds it, but then causes a crash in "else" (!nlopt_internal):
#          File "/home/vagrant/tmp/contract-synergia2/packages/nlopt.py", line 26, in <module>
#            nlopt_lib = Option(local_root,"nlopt/lib",default_lib,str,"NLOPT library directory")
#          NameError: name 'default_lib' is not defined
#
#     fftw3: doesn't work, b/c packages/fftw3.py looks for libfftw3.so, not libfftw3.so.3
#
#     bison: This is bison 3 so incompatible; force to bison_internal
#         xsif_yacc.ypp:158:30: error: ‘yylloc’ was not declared in this scope
#
#     tables: always uses synergia's own tables (see below for bug with that)
#
#     boost-openmpi-devel: when running synergia:
#         ImportError: /lib64/libboost_python.so.1.55.0: undefined symbol: PyUnicodeUCS4_FromEncodedObject
#
# This was happening at one point:
#     fetching https://compacc.fnal.gov/projects/attachments/download/20/tables-2.1.2.tar.gz
#     [...]
#     File "/home/vagrant/.pyenv/versions/2.7.10/lib/python2.7/ssl.py", line 808, in do_handshake
#       self._sslobj.do_handshake()
#     IOError: [Errno socket error] [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed (_ssl.c:590)
#
# Synergia's internal hdf5 does not compile so have to use hdf5 from Fedora.
#     h5tools_dump.c:635:9: error: expected expression before '/' token
#        //HGOTO_ERROR(dimension_break, H5E_tools_min_id_g, "Could not allocate[...]
#
#
# So copied to apa11, download the file and install in depot/foss
#     wget --no-check-certificate https://compacc.fnal.gov/projects/attachments/download/20/tables-2.1.2.tar.gz
#     chmod 444 tables-2.1.2.tar.gz
#     perl -pi -e 's{https://compacc.fnal.gov/projects/attachments/download/20}{https://depot.radiasoft.org/foss}' packages/pytables_pkg.py
#
# h5py also installs hdf5 RPMs, which is what's needed (see above)
codes_dependencies mpi4py
codes_yum install flex cmake eigen3-devel glib2-devel
pip install pyparsing nose

synergia_bootstrap() {
    local fnal=http://cdcvs.fnal.gov/projects
    local radiasoft=http://depot.radiasoft.org/foss/synergia
    # "git clone --depth 1" doesn't work in some case
    #     fatal: dumb http transport does not support --depth
    # so if you don't pass a commit to codes_download, you'll see this error.
    codes_download "$radiasoft"/contract-synergia2.git origin/devel
    fgrep -Rl "$fnal" . | xargs perl -pi -e "s{\\Q$fnal}{$radiasoft}g"
    ./bootstrap
}

synergia_contractor() {
    # Turn off parallel make
    local f
    local -a x=()
    # Don't be greedy, use half the cores
    local cores=$(( $(grep -c '^core id *:' /proc/cpuinfo) / 2 ))
    if [[ $cores -lt 1 ]]; then
        cores=1
    fi
    for f in bison chef-libs fftw3 freeglut libpng nlopt qutexmlrpc qwt synergia2; do
        x+=( "$f"/make_use_custom_parallel=1 "$f"/make_custom_parallel="$cores")
    done
    for f in bison fftw3 libpng nlopt; do
        x+=( "$f"_internal=1 )
    done
    x+=(
        #NOT in master: boost/parallel="$cores"
        #chef-libs/repo=https://github.com/radiasoft/accelerator-modeling-chef.git
        #chef-libs/branch=5277ecbbdec02e9394eca4e079a651053b6a0ab4
        #chef-libs/branch=radiasoft-devel
    )
    if [[ $codes_synergia_branch ]]; then
        x+=( synergia2/branch=$codes_synergia_branch )
        if [[ $codes_synergia_branch == devel-pre3 ]]; then
            x+=( boost_internal=1 )
        fi
    fi
    ./contract.py --configure "${x[@]}"
    ./contract.py
}

synergia_install() {
    # openmpi should be added automatically (/etc/ld.so.conf.d), but there's
    # a conflict with hdf5, which has same library name in /usr/lib64 as in
    # /usr/lib64/openmpi/lib.
    perl -pi -e '
        s{(?<=install_dir/lib)}{/synergia};
        s{(?=ldpathadd ")}{ldpathadd /usr/lib64/openmpi/lib\n}s;
    ' install/bin/synergia
    local d=$(pyenv prefix)
    # Synergia installer doesn't set modes correctly in all cases
    chmod -R a+rX install
    (
        set -e
        cd install
        cp -a bin include "$d"
        mv lib "$d/lib/synergia"
    )
    return $?
}

synergia_pyenv_exec() {
    cat > ~/.pyenv/pyenv.d/exec/rs-beamsim-synergia.bash <<'EOF'
#!/bin/bash
#
# Synergia needs these special paths to work.
#
export SYNERGIA2DIR=$(pyenv prefix)/lib/synergia
export LD_LIBRARY_PATH=$SYNERGIA2DIR:/usr/lib64/openmpi/lib
export PYTHONPATH=$SYNERGIA2DIR
EOF
}

synergia_bootstrap
synergia_contractor
synergia_install
synergia_pyenv_exec

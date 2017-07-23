#!/bin/bash
#
# Install codes into containers. The code installation scripts reside in
# You can install individual codes (and dependencies) with:
#
# git clone https://github.com/radiasoft/containers
# cd containers/radiasoft/beamsim
# bash -l codes.sh <code1> <code2>
# pyenv rehash
#
# A list of available codes can be found in "codes" subdirectory.
#
set -e

# Build scripts directory
: ${codes_dir:=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd)/codes}

codes_data_src_dir=$codes_dir/data

# Where to install binaries (needed by genesis.sh)
codes_bin_dir=$(dirname "$(pyenv which python)")

# Where to install binaries (needed by genesis.sh)
codes_lib_dir=$(python -c 'from distutils.sysconfig import get_python_lib as x; print x()')

# Avoids dependency loops
declare -A codes_installed

codes_curl() {
    curl -s -S -L "$@"
}

codes_dependencies() {
    codes_install_loop "$@"
}

codes_download() {
    # If download is an rpm, also installs
    local repo=$1
    local qualifier=$2
    local package=$3
    local version=$4
    if [[ ! $repo =~ / ]]; then
        repo=radiasoft/$repo
    fi
    if [[ ! $repo =~ ^(ftp|https?): ]]; then
        repo=https://github.com/$repo.git
    fi
    codes_msg "Download: $repo"
    case $repo in
        *.git)
            local d=$(basename "$repo" .git)
            if [[ $qualifier ]]; then
                # Don't pass --depth in this case for a couple of reasons:
                # 1) we don't know where the commit is; 2) It might be a simple http
                # transport (synergia.sh) which doesn't support git
                git clone --recursive -q "$repo"
                cd "$d"
                git checkout "$qualifier"
            else
                git clone --recursive --depth 1 "$repo"
                cd "$d"
            fi
            local manifest=(
                "$d"
                "$(git rev-parse HEAD)"
            )
            ;;
        *.tar\.gz)
            local b=$(basename "$repo" .tar.gz)
            local d=${qualifier:-$b}
            local t=tarball-$RANDOM
            codes_curl -o "$t" "$repo"
            tar xzf "$t"
            rm -f "$t"
            cd "$d"
            if [[ ! $b =~ ^(.+)-([[:digit:]].+)$ ]]; then
                codes_err "$repo: basename does not match version regex"
            fi
            local manifest=(
                "${BASH_REMATCH[1]}"
                "${BASH_REMATCH[2]}"
            )
            ;;
        *.rpm)
            local b=$(basename "$repo")
            local n="${b//-*/}"
            # FRAGILE: works for current set of RPMs
            if rpm --quiet -q "$n"; then
                echo "$b already installed"
            else
                codes_yum install "$repo"
            fi
            local manifest=(
                "$(rpm -q --queryformat '%{NAME}' "$n")"
                "$(rpm -q --queryformat '%{VERSION}-%{RELEASE}' "$n")"
            )
            ;;
        *)
            codes_err "$repo: unknown repository format; must end in .git, .rpm, .tar.gz"
            ;;
    esac
    if [[ -n $(type -t pykern) ]]; then
        local venv=
        if [[ -n $(find . -name \*.py) ]]; then
            venv=( $(pyenv version) )
            venv=${venv[0]}
        fi
        pykern rsmanifest add_code --pyenv="$venv" \
            "${package:-${manifest[0]}}" "${version:-${manifest[1]}}" "$repo" "$(pwd)"
    fi
    return 0
}

codes_download_foss() {
    local path=$1
    shift
    codes_download https://depot.radiasoft.org/foss/"$path" "$@"
}
    

codes_err() {
    codes_msg "$@"
    return 1
}

codes_install() {
    local sh=$1
    local module=$(basename "$sh" .sh)
    if [[ ${codes_installed[$module]} ]]; then
        return 0
    fi
    codes_installed[$module]=1
    local prev=$(pwd)
    local dir=$HOME/src/radiasoft/codes/$module-$(date -u +%Y%m%d.%H%M%S)
    rm -rf "$dir"
    mkdir -p "$dir"
    if [[ ! -f $sh ]]; then
        # Might be passed as 'genesis', 'genesis.sh', 'codes/genesis.sh', or
        # (some special name) 'foo/bar/code1.sh'
        sh=$codes_dir/$module.sh
    fi
    codes_msg "Build: $module"
    codes_msg "Directory: $dir"
    cd "$dir"
    . "$sh"
    cd "$prev"
}

codes_install_loop() {
    local f
    for f in "$@"; do
        codes_install "$f"
    done
}

codes_main() {
    local -a codes=( $@ )
    if [[ ! $codes ]]; then
        codes=( "$codes_dir"/*.sh )
    fi
    codes_install_loop "${codes[@]}"
}

codes_msg() {
    echo "$(date -u +%H:%M:%SZ)" "$@" 1>&2
}

codes_patch_requirements_txt() {
    # numpy==1.9.3 is the only version that works with all the codes
    local t=tmp.$$
    grep -v numpy requirements.txt > "$t"
    mv -f "$t" requirements.txt
}

codes_yum() {
    codes_msg "yum $@"
    sudo yum --color=never -y -q "$@"
    if [[ -n $(type -p package-cleanup) ]]; then
        sudo package-cleanup --cleandupes
    fi
}

if [[ $0 == ${BASH_SOURCE[0]} ]]; then
    # Run independently from the shell
    if [[ ! $(cat /etc/fedora-release 2>/dev/null) =~ release.21 ]]; then
        codes_msg 'Only Fedora 21 is supported at this time'
    fi
    # make sure pyenv loaded
    if [[ $(type -t pyenv) != function ]]; then
        if [[ ! $(type -f pyenv 2>/dev/null) =~ /bin/pyenv$ ]]; then
            codes_err 'ERROR: You must have pyenv in your path'
        fi
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
    fi
    codes_main "$@"
else
    codes_main
fi

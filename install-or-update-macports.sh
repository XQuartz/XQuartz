#!/bin/sh -e

# presently hard-coded to base branch "release-2.8"
MACPORTS_VERSION="2.8"
BASE_DIR=$(pwd)

die() {
    echo "${@}" >&2
    exit 1
}

BUILD_TOOLS_CONFIGS="STD CMAKE"

BUILD_TOOLS_PREFIX_STD="/opt/buildX11"
BUILD_TOOLS_PREFIX_CMAKE="/opt/buildX11-cmake"

# Note that docbook-utils is needed for fontconfig docs, but we're skipping it here because of https://trac.macports.org/ticket/62354
PORTS_STD="autoconf automake pkgconfig libtool py310-mako meson xmlto asciidoc doxygen fop groff gtk-doc graphviz"
PORTS_CMAKE="cmake"

BASE_PATH="/usr/bin:/bin:/usr/sbin:/sbin"

TMP_BASE=$(mktemp -d /tmp/macports-XXXXXXX)
trap "rm -rf ${TMP_BASE}" EXIT INT QUIT TERM

bootstrap_base() {
    local BUILD_TOOLS_PREFIX=$1

    if ! [ -f "${BUILD_TOOLS_PREFIX}/bin/port" ] ; then
        cd "${TMP_BASE}" || die "Could not change to tmp directory"

        if ! [ -d "${TMP_BASE}/macports-base" ] ; then
            git clone -b release-${MACPORTS_VERSION} --depth 1 https://github.com/macports/macports-base.git || die "Could not clone macports-base"
            cd macports-base || die "Could not enter macports-base"
        fi

        ./configure --prefix="${BUILD_TOOLS_PREFIX}" --with-applications-dir="${BUILD_TOOLS_PREFIX}/Applications" --without-startupitems || die "Could not configure macports"
        make -j$(sysctl -n hw.activecpu) || die "macports-base build failed"
        sudo make install || die "macports-base install failed into ${BUILD_TOOLS_PREFIX}"
    fi

    if ! [ -f "${BUILD_TOOLS_PREFIX}/bin/port" ] ; then
        die "MacPorts should be installed now, but ${BUILD_TOOLS_PREFIX}/bin/port not found"
    fi
}

push_pkgconfig() {
    local BUILD_TOOLS_PREFIX=$1

    if [ -d "${BUILD_TOOLS_PREFIX}/lib/pkgconfig-stored" ] ; then
        sudo mv -f ${BUILD_TOOLS_PREFIX}/lib/pkgconfig-stored ${BUILD_TOOLS_PREFIX}/lib/pkgconfig || die "Could not move ${BUILD_TOOLS_PREFIX}/lib/pkgconfig-stored back into position"
    fi

    if [ -d "${BUILD_TOOLS_PREFIX}/share/pkgconfig-stored" ] ; then
        sudo mv -f ${BUILD_TOOLS_PREFIX}/share/pkgconfig-stored ${BUILD_TOOLS_PREFIX}/share/pkgconfig || die "Could not move ${BUILD_TOOLS_PREFIX}/share/pkgconfig-stored back into position"
    fi
}

pop_pkgconfig() {
    local BUILD_TOOLS_PREFIX=$1

    if [ -d "${BUILD_TOOLS_PREFIX}/lib/pkgconfig" ] ; then
        sudo mv -f ${BUILD_TOOLS_PREFIX}/lib/pkgconfig ${BUILD_TOOLS_PREFIX}/lib/pkgconfig-stored || die "Could not move ${BUILD_TOOLS_PREFIX}/lib/pkgconfig to stored"
    fi

    if [ -d "${BUILD_TOOLS_PREFIX}/share/pkgconfig" ] ; then
        sudo mv -f ${BUILD_TOOLS_PREFIX}/share/pkgconfig ${BUILD_TOOLS_PREFIX}/share/pkgconfig-stored || die "Could not move ${BUILD_TOOLS_PREFIX}/share/pkgconfig to stored"
    fi
}

do_sign_update() {
    local BUILD_TOOLS_PREFIX=${BUILD_TOOLS_PREFIX_STD}

    SPARKLE_DSTROOT="${TMP_BASE}/Sparkle"
    mkdir -p "${SPARKLE_DSTROOT}"
    cd "${BASE_DIR}/src/Sparkle2x"
    xcodebuild install -scheme sign_update "INSTALL_PATH=${BUILD_TOOLS_PREFIX}/bin" "DSTROOT=${SPARKLE_DSTROOT}"
    #xcodebuild install -scheme generate_keys "INSTALL_PATH=${BUILD_TOOLS_PREFIX}/bin" "DSTROOT=${SPARKLE_DSTROOT}"
    sudo ditto "${SPARKLE_DSTROOT}" /
}

do_macports_preifx() {
    local BUILD_TOOLS_PREFIX=$1
    shift

    push_pkgconfig ${BUILD_TOOLS_PREFIX}

    bootstrap_base "${BUILD_TOOLS_PREFIX}"

    export PATH="${BUILD_TOOLS_PREFIX}/bin:${BASE_PATH}"

    sudo ${BUILD_TOOLS_PREFIX}/bin/port -v selfupdate || die "Could not selfupdate macports"
    sudo ${BUILD_TOOLS_PREFIX}/bin/port -N -v -f install ${@} || die "Could not install basic toolchain"

    # cmake can mess up the way meson searches for dependnecies, so deactivate it and the rest of the recursive leaves
    sudo ${BUILD_TOOLS_PREFIX}/bin/port deactivate rleaves

    pop_pkgconfig ${BUILD_TOOLS_PREFIX}

    echo "MacPorts toolchain and Sparkle signing tools successfully installed in ${BUILD_TOOLS_PREFIX}"

    export PATH="${BASE_PATH}"
}

set -x

for CONFIG in ${BUILD_TOOLS_CONFIGS} ; do
   BUILD_TOOLS_PREFIX_VAR=BUILD_TOOLS_PREFIX_${CONFIG}
   PORTS_VAR=PORTS_${CONFIG}
   do_macports_preifx "${!BUILD_TOOLS_PREFIX_VAR}" ${!PORTS_VAR}
done

sudo ${BUILD_TOOLS_PREFIX_STD}/bin/port select python3 python310 || die "Could not select python3"

#do_sign_update

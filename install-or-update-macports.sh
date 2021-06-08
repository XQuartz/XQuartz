BUILD_TOOLS_PREFIX="/opt/buildX11"

# presently hard-coded to base branch "release-2.7"
# MACPORTS_VERSION="2.7"

export PATH="${BUILD_TOOLS_PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin"

die() {
    echo "${@}" >&2
    exit 1
}

if ! [ -f "${BUILD_TOOLS_PREFIX}/bin/port" ] ; then
    cd /tmp || die "Could not change to tmp directory"

    if [ -d "/tmp/macports-base" ] ; then
        sudo rm -rf /tmp/macports-base || die "Could not remove /tmp/macports-base"
    fi

    git clone -b release-2.7 --depth 1 https://github.com/macports/macports-base.git || die "Could not clone macports-base"
    cd macports-base || die "Could not enter macports-base"
    ./configure --prefix="${BUILD_TOOLS_PREFIX}" --with-applications-dir="${BUILD_TOOLS_PREFIX}/Applications" --without-startupitems || die "Could not configure macports"
    make -j$(sysctl -n hw.activecpu) || die "macports-base build failed"
    sudo make install || die "macports-base install failed into ${BUILD_TOOLS_PREFIX}"
fi

if ! [ -f "${BUILD_TOOLS_PREFIX}/bin/port" ] ; then
    die "MacPorts should be installed now, but ${BUILD_TOOLS_PREFIX}/bin/port not found"
fi

if [ -d "${BUILD_TOOLS_PREFIX}/lib/pkgconfig-stored" ] ; then
    sudo mv -f ${BUILD_TOOLS_PREFIX}/lib/pkgconfig-stored ${BUILD_TOOLS_PREFIX}/lib/pkgconfig || die "Could not move ${BUILD_TOOLS_PREFIX}/lib/pkgconfig-stored back into position"
fi

if [ -d "${BUILD_TOOLS_PREFIX}/share/pkgconfig-stored" ] ; then
    sudo mv -f ${BUILD_TOOLS_PREFIX}/share/pkgconfig-stored ${BUILD_TOOLS_PREFIX}/share/pkgconfig || die "Could not move ${BUILD_TOOLS_PREFIX}/share/pkgconfig-stored back into position"
fi

sudo ${BUILD_TOOLS_PREFIX}/bin/port -v selfupdate || die "Could not selfupdate macports"

# Note that docbook-utils is needed for fontconfig docs, but we're skipping it here because of https://trac.macports.org/ticket/62354
sudo ${BUILD_TOOLS_PREFIX}/bin/port -N -v install autoconf automake pkgconfig libtool py39-mako meson xmlto asciidoc doxygen fop groff gtk-doc || die "Could not install basic toolchain"
sudo ${BUILD_TOOLS_PREFIX}/bin/port select python3 python39 || die "Could not select python3"

if [ -d "${BUILD_TOOLS_PREFIX}/lib/pkgconfig" ] ; then
    sudo mv -f ${BUILD_TOOLS_PREFIX}/lib/pkgconfig ${BUILD_TOOLS_PREFIX}/lib/pkgconfig-stored || die "Could not move ${BUILD_TOOLS_PREFIX}/lib/pkgconfig to stored"
fi

if [ -d "${BUILD_TOOLS_PREFIX}/share/pkgconfig" ] ; then
    sudo mv -f ${BUILD_TOOLS_PREFIX}/share/pkgconfig ${BUILD_TOOLS_PREFIX}/share/pkgconfig-stored || die "Could not move ${BUILD_TOOLS_PREFIX}/share/pkgconfig to stored"
fi

echo "MacPorts toolchain successfully installed in ${BUILD_TOOLS_PREFIX}"

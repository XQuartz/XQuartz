#!/bin/sh -x -e

# Note that the build system needs to be macOS 11.3 or newer, Intel or Apple Silicon
#
# Before building, be sure to checkout sources and configure the system:
#
# 1) Install the latest version of Xcode.
#
# 2) Use the the "install-or-update-macports.sh" script to install autoconf, automake,
#    pkgconfig, glibtool, and meson to ${BUILD_TOOLS_PREFIX}.
#
# 3) Make sure the ${BUILD_TOOLS_PREFIX}/{lib,share}/pkgconfig directories are moved
#    aside or they will interfere.  The "install-or-update-macports.sh" script will
#    manage these directories for you, moving them aside on completion and back on
#    future updates.
#
# 4) Setup authentication for altool with one of the following options:
#    4a) Create an app-specific password for altool at appleid.apple.com.  Save this as pkg/altool.user and pkg/altool.password
#    4b) Create an API Key as documented at https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api
#        Save this as pkg/altool.user and pkg/altool.password
#    4c) (AppleInternal) Install cliff at pkg/altool.cliff, store the username as pkg/altool.user, and
#        save the cliff properties file (based on pkg/altool.cliff/conf/corporate_user_cliff_properties.template)
#        as pkg/altool.cliff.properties
#
# 5) Add credential files to the pkg sundirectory:
#        pkg/altool.* (see #4 above)
#        pkg/bintray.cred
#        pkg/sparkle_priv.pem
#
# 6) Ensure the macOS keychain contains the private key for our Developer ID certificates
#
# To update a submodule to a newer version, just checkout the appropriate
# branch in the submodule and then commit the changed hash at the top level.
#
# TODO:
#   * build tools for documentation
#   * Do we want to add Bincompat packages:
#     src/xorg/lib/libXp
#     src/xorg/lib/libXevie
#     src/xorg/lib/libXfontcache
#     src/xorg/lib/libxkbui
#     src/xorg/lib/libXTrap
#     src/xorg/lib/libXxf86misc
#   * If so, we don't need headers and arm64 slices for bincompat libs

PREFIX=/opt/X11
BUILD_TOOLS_PREFIX=/opt/buildX11
APPLICATION_PATH=/Applications/Utilities
IDENTIFIER_PREFIX=org.xquartz

CODESIGN_ASC_PROVIDER="NA574AWV7E"
CODESIGN_IDENTITY_APP="Developer ID Application: Apple Inc. - XQuartz (${CODESIGN_ASC_PROVIDER})"
CODESIGN_IDENTITY_PKG="Developer ID Installer: Apple Inc. - XQuartz (${CODESIGN_ASC_PROVIDER})"

APPLICATION_VERSION=2.8.9
APPLICATION_VERSION_STRING=2.8.0_rc1

if [ "${APPLICATION_VERSION_STRING}" != "${APPLICATION_VERSION_STRING/alpha/}" ] ; then
    SPARKLE_FEED_URL="https://www.xquartz.org/releases/sparkle/alpha.xml"
elif [ "${APPLICATION_VERSION_STRING}" != "${APPLICATION_VERSION_STRING/beta/}" ] ; then
    SPARKLE_FEED_URL="https://www.xquartz.org/releases/sparkle/beta.xml"
elif [ "${APPLICATION_VERSION_STRING}" != "${APPLICATION_VERSION_STRING/rc/}" ] ; then
    SPARKLE_FEED_URL="https://www.xquartz.org/releases/sparkle/beta.xml"
else
    SPARKLE_FEED_URL="https://www.xquartz.org/releases/sparkle/release.xml"
fi

if [ "${APPLICATION_VERSION_STRING}" != "${APPLICATION_VERSION_STRING/alpha/}" ] ; then
     # Alpha builds use ASan
     SANITIZER_LIB_DIR=$(echo $(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/*/lib/darwin)

     SANITIZER_CFLAGS="-fsanitize=address"
     SANITIZER_LIBS="libclang_rt.asan_osx_dynamic.dylib"

     SANITIZER_LDFLAGS="-Wl,-rpath,${PREFIX}/lib/asan"
     for dylib in ${SANITIZER_LIBS} ; do
         SANITIZER_LDFLAGS="${SANITIZER_LDFLAGS} -Wl,${SANITIZER_LIB_DIR}/${dylib}"
     done

     OPT_CFLAGS="-O0 -fno-optimize-sibling-calls -fno-omit-frame-pointer"

     # ASan requires use to not use -D_FORTIFY_SOURCE=2, or it can lead to false-positives
     HARDENING_CFLAGS="-fstack-protector-all"
     export MACOSX_DEPLOYMENT_TARGET=10.10
elif [ "${APPLICATION_VERSION_STRING}" != "${APPLICATION_VERSION_STRING/beta/}" ] ; then
     # Beta builds use full stack protection and disable optimizations
     OPT_CFLAGS="-O0 -fno-optimize-sibling-calls -fno-omit-frame-pointer"
     HARDENING_CFLAGS="-fstack-protector-all -D_FORTIFY_SOURCE=2"
     export MACOSX_DEPLOYMENT_TARGET=10.9
else
     # Release-candidate and Release builds
     OPT_CFLAGS="-Os"
     HARDENING_CFLAGS="-fstack-protector-strong -D_FORTIFY_SOURCE=2"
     export MACOSX_DEPLOYMENT_TARGET=10.9
fi

ARCH_FLAGS="-target fat-apple-macos${MACOSX_DEPLOYMENT_TARGET} -arch x86_64 -arch arm64"
DEBUG_CFLAGS="-g3 -gdwarf-2"
MAKE="gnumake"
MAKE_OPTS="V=1 -j$(sysctl -n hw.activecpu)"

BASE_DIR=$(pwd)

PRODUCTS_DIR=${BASE_DIR}/products
mkdir -p ${PRODUCTS_DIR}

DESTDIR=${PRODUCTS_DIR}/XQuartz.dest
PKG_ROOT=${PRODUCTS_DIR}/XQuartz.signed
SYM_ROOT=${PRODUCTS_DIR}/XQuartz.symbols

WARNING_CFLAGS="-Werror=unguarded-availability-new -Werror=objc-method-access"

# Don't let startx use openssl from /opt/buildX11 (https://github.com/XQuartz/XQuartz/issues/29)
export ac_cv_path_OPENSSL=/usr/bin/openssl

# timespec_get() was added in macOS 10.15
export ac_cv_func_timespec_get=no

# clock_gettime was added in macOS 10.12
export ac_cv_func_clock_gettime=no

# mkostemp was added in macOS 10.12
export ac_cv_func_mkostemp=no

export PATH="${PREFIX}/bin:${BUILD_TOOLS_PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PKG_CONFIG_PATH="${PREFIX}/share/pkgconfig:${PREFIX}/lib/pkgconfig"
export FONTPATH="${PREFIX}/share/fonts/misc/,${PREFIX}/share/fonts/TTF/,${PREFIX}/share/fonts/OTF,${PREFIX}/share/fonts/Type1/,${PREFIX}/share/fonts/75dpi/:unscaled,${PREFIX}/share/fonts/100dpi/:unscaled,${PREFIX}/share/fonts/75dpi/,${PREFIX}/share/fonts/100dpi/,/Library/Fonts,/System/Library/Fonts"
export ACLOCAL="aclocal -I ${PREFIX}/share/aclocal -I ${BUILD_TOOLS_PREFIX}/share/aclocal"
export CPPFLAGS="-I${PREFIX}/include -F${APPLICATION_PATH}/XQuartz.app/Contents/Frameworks -DFAIL_HARD"
export CFLAGS="${ARCH_FLAGS} ${SANITIZER_CFLAGS} ${OPT_CFLAGS} ${DEBUG_CFLAGS} ${HARDENING_CFLAGS} ${WARNING_CFLAGS}"
export CXXFLAGS="${CFLAGS}"
export OBJCFLAGS="${CFLAGS}"
export LDFLAGS="${ARCH_FLAGS} ${SANITIZER_LDFLAGS} -L${PREFIX}/lib -F${APPLICATION_PATH}/XQuartz.app/Contents/Frameworks"
export CC="/usr/bin/clang"
export CXX="/usr/bin/clang++"
export OBJC="/usr/bin/clang"

# meson is strict about it's toolchain names, especially relevant when cross-compiling.
# The machine doing the building is the build machine, and the tools
# it uses for the build are CC_FOR_BUILD/CXX_FOR_BUILD
# https://mesonbuild.com/Reference-tables.html#Environment-variables-per-machine
export CC_FOR_BUILD="${CC}"
export CXX_FOR_BUILD="${CXX}"

# For static analysis if we want to do it
#SCAN_BUILD="scan-build-mp-10 -v -V -o clang.d --use-cc=${CC} --use-c++=${CXX}"

die() {
        echo "${@}" >&2
        exit 1
}

do_patches() {
    local PROJECT_PATCHES_DIR="${1}"
    if [ -d "${PROJECT_PATCHES_DIR}" -a ! -f "${PROJECT_PATCHES_DIR}/applied" ] ; then
        for patch in "${PROJECT_PATCHES_DIR}"/* ; do
            patch -p1 < "${patch}" || die "Unable to apply patch ${patch}"
        done
        touch "${PROJECT_PATCHES_DIR}/applied"
    fi
}

# Precondition for all do_*_build():
#   $1 is the module to build
#
# Postcondition:
#   Object files are left in place.
#   Content is installed to DESTDIR and the live filesystem.
#
# Options:
#   SCAN_BUILD can be set for static analysis
#   SKIP_CLEAN can be set to YES
#   SKIP_AUTORECONF can be set to YES
do_autotools_build() {
    local PROJECT_DIR="${BASE_DIR}/${1}"
    local PROJECT_PATCHES_DIR="${PROJECT_DIR}.patches"
    local CONFOPT_FILE="${PROJECT_DIR}.confopt"
    [ -f "${CONFOPT_FILE}" ] || CONFOPT_FILE=/dev/null

    cd "${PROJECT_DIR}" || die "Could not change directory to ${PROJECT_DIR}"

    PROJECT=$(basename $(pwd))

    # Oddball paths
    case ${PROJECT} in
    freeglut)
        cd freeglut
        ;;
    esac

    do_patches "${PROJECT_PATCHES_DIR}"

    case ${PROJECT} in
    freetype2)
        ./autogen.sh
        ;;
    xterm)
        ;;
    *)
        if [ ! -f configure -o "${SKIP_AUTORECONF}" != "YES" ] ; then
            autoreconf -fvi || die "Unable to autoreconf in $(pwd)"
        fi
        ;;
    esac

    ${SCAN_BUILD} ./configure --prefix=${PREFIX} --disable-static $(eval echo $(cat "${CONFOPT_FILE}")) || die "Could not configure in $(pwd)"

    [[ "${SKIP_CLEAN}" == "YES" ]] || ${MAKE} clean || die "Unable to make clean in $(pwd)"

    ${SCAN_BUILD} ${MAKE} ${MAKE_OPTS} || die "Could not make in $(pwd)"

    sudo ${MAKE} install DESTDIR=${DESTDIR} || die "Could not make install in $(pwd)"
    sudo ${MAKE} install || die "Could not make install in $(pwd)"

    # Prune the .la files that we don't want
    sudo rm -f ${DESTDIR}${PREFIX}/lib/*.la
    sudo rm -f ${PREFIX}/lib/*.la
}

do_meson_build() {
    local PROJECT_DIR="${BASE_DIR}/${1}"
    local PROJECT_PATCHES_DIR="${PROJECT_DIR}.patches"
    local CONFOPT_FILE="${PROJECT_DIR}.confopt"
    local MESON_CROSS_DIR="${BASE_DIR}/meson_support/meson/cross"
    [ -f "${CONFOPT_FILE}" ] || CONFOPT_FILE=/dev/null

    cd "${PROJECT_DIR}" || die "Could not change directory to ${PROJECT_DIR}"

    PROJECT=$(basename $(pwd))

    do_patches "${PROJECT_PATCHES_DIR}"

    # We need to do this hacky dance because of a bug in meson.
    # We need to configure meson as a cross compiler to build arm64 from x86_64
    # See https://mesonbuild.com/Cross-compilation.html
    # https://github.com/mesonbuild/meson/issues/8206
    for arch in arm64 x86_64 ; do
        CFLAGS="-target ${arch}-apple-macos${MACOSX_DEPLOYMENT_TARGET} ${OPT_CFLAGS} ${DEBUG_CFLAGS} ${WARNING_CFLAGS}" \
            OBJCFLAGS="-target ${arch}-apple-macos${MACOSX_DEPLOYMENT_TARGET} ${OPT_CFLAGS} ${DEBUG_CFLAGS} ${WARNING_CFLAGS}" \
            CXXFLAGS="-target ${arch}-apple-macos${MACOSX_DEPLOYMENT_TARGET} ${OPT_CFLAGS} ${DEBUG_CFLAGS} ${WARNING_CFLAGS}" \
            LDFLAGS="-target ${arch}-apple-macos${MACOSX_DEPLOYMENT_TARGET} -L${PREFIX}/lib -F${APPLICATION_PATH}/XQuartz.app/Contents/Frameworks" \
            meson build.${arch} -Dprefix=${PREFIX} $(eval echo $(cat "${CONFOPT_FILE}")) --cross-file ${MESON_CROSS_DIR}/${arch}-darwin-xquartz || die "Could not configure in $(pwd)"
        ninja -C build.${arch} || die "Failed to compile in $(pwd)"
        sudo DESTDIR="${DESTDIR}.meson.${arch}" ninja -C build.${arch} install || die "Failed to install in $(pwd)"

        # Prune the .la files that we don't want
        sudo rm -f "${DESTDIR}.meson.${arch}${PREFIX}/lib"/*.la
    done

    sudo cp -a "${DESTDIR}.meson.arm64" "${DESTDIR}.meson.fat"

    cd "${DESTDIR}.meson.fat"
    find . -type f | while read file ; do
        if /usr/bin/file "${file}" | grep -q "Mach-O" ; then
            sudo lipo -create -output "${file}" "${DESTDIR}.meson.arm64/${file}" "${DESTDIR}.meson.x86_64/${file}"
        fi
    done

    sudo ditto "${DESTDIR}.meson.fat" "${DESTDIR}"
    sudo ditto "${DESTDIR}.meson.fat" /

    # Cleanup the meson universal hack directories
    sudo rm -rf "${DESTDIR}".meson.*
}

do_checks() {
    find "${DESTDIR}" -type f | while read file ; do
        if /usr/bin/file "${file}" | grep -q "Mach-O" ; then
            if otool -L "${file}" | grep -q "/opt/local" ; then
                die "=== ${file} links against an invalid library ==="
            fi

            if otool -L "${file}" | grep -q "/usr/local" ; then
                die "=== ${file} links against an invalid library ==="
            fi

            if otool -L "${file}" | grep -q "${BUILD_TOOLS_PREFIX}" ; then
                die "=== ${file} links against an invalid library ==="
            fi

            # Ignore Sparkle since it handles back deployment properly
            [ "${file/Sparkle/}" != "${file}" ] && continue

            # Ignore mesa for now
            [ "${file/swrast_dri.so/}" != "${file}" ] && continue
            [ "${file/libOSMesa/}" != "${file}" ] && continue

            # Ignore _voucher* symbols (mig) and symbols from libc++ and libobjc that the compiler might have added
            if nm -arch x86_64 -m "${file}"  | grep -v "_voucher" | grep -v "darwin_check_fd_set_overflow" | grep -v "from libc++" | grep -v "from libobjc" | grep -q "weak external" ; then
                die "=== ${file} has a weak link ==="
            fi
        fi
    done
}

do_strip_sign_dsyms() {
    if [ -d "${PKG_ROOT}" ] ; then
        sudo rm -rf "${PKG_ROOT}"
    fi

    if [ -d "${SYM_ROOT}" ] ; then
        sudo rm -rf "${SYM_ROOT}"
    fi

    sudo ditto "${DESTDIR}" "${PKG_ROOT}"
    sudo mkdir -p "${SYM_ROOT}"

    sudo chown -R root:wheel "${PKG_ROOT}"

    find "${PKG_ROOT}/opt/X11" -type f | while read file ; do
        if /usr/bin/file "${file}" | grep -q "Mach-O" ; then
            sudo dsymutil --out="${SYM_ROOT}"/$(basename "${file}").dSYM "${file}"
            sudo cp "${file}" "${SYM_ROOT}"
            sudo strip -S "${file}"

            sudo codesign -s "${CODESIGN_IDENTITY_APP}" --digest-algorithm=sha1,sha256 --force --preserve-metadata=entitlements,requirements,flags --identifier "org.xquartz.$(basename "${file}")" --options runtime "${file}"
        fi
    done

    find "${PKG_ROOT}/Applications" -type f | while read file ; do
        if /usr/bin/file "${file}" | grep -q "Mach-O" ; then
            sudo dsymutil --out="${SYM_ROOT}"/$(basename "${file}").dSYM "${file}"
            sudo cp "${file}" "${SYM_ROOT}"
            sudo strip -S "${file}"
        fi
    done

    sudo codesign -s "${CODESIGN_IDENTITY_APP}" --digest-algorithm=sha1,sha256 --deep --force --preserve-metadata=identifier,entitlements,requirements,flags --options runtime "${PKG_ROOT}${APPLICATION_PATH}"/XQuartz.app/Contents/Frameworks/Sparkle.framework/Versions/A/Resources/Autoupdate.app
    sudo codesign -s "${CODESIGN_IDENTITY_APP}" --digest-algorithm=sha1,sha256 --deep --force --preserve-metadata=identifier,entitlements,requirements,flags --options runtime "${PKG_ROOT}${APPLICATION_PATH}"/XQuartz.app/Contents/Frameworks/Sparkle.framework
    sudo codesign -s "${CODESIGN_IDENTITY_APP}" --digest-algorithm=sha1,sha256 --deep --force --preserve-metadata=identifier,entitlements,requirements,flags --options runtime "${PKG_ROOT}${APPLICATION_PATH}"/XQuartz.app
}

do_sym_tarball() {
    OUTPUT_TARBALL="${BASE_DIR}"/XQuartz-${APPLICATION_VERSION_STRING}.dSYMS.tar.bz2

    cd "${SYM_ROOT}"
    tar cjf "${OUTPUT_TARBALL}" .
    cd "${BASE_DIR}"
}

do_pkg() {
    PKG_CONFIG_ROOT="${BASE_DIR}"/pkg
    PKG_COMPONENT_PLIST="${PKG_CONFIG_ROOT}"/XQuartzComponent.plist
    PKG_REQUIREMENTS_PLIST="${PKG_CONFIG_ROOT}"/XQuartzRequirements.plist
    PKG_DISTRIBUTION_PLIST="${PKG_CONFIG_ROOT}"/XQuartzDistribution.plist

    PKG_OUTPUT="${BASE_DIR}"/XQuartz-${APPLICATION_VERSION_STRING}.pkg

    # Initial configuration created like this and then manually edited:
    # pkgbuild --analyze --root "${DESTDIR}" "${PKG_COMPONENT_PLIST}"

    pkgbuild --sign "${CODESIGN_IDENTITY_PKG}" --scripts "${PKG_CONFIG_ROOT}"/scripts --root "${PKG_ROOT}" --install-location / --component-plist "${PKG_COMPONENT_PLIST}" "${PKG_CONFIG_ROOT}"/XQuartzComponent.pkg

    # Initial configuration created like this and then manually edited:
    # productbuild --synthesize --product "${PKG_REQUIREMENTS_PLIST}" --package "${PKG_CONFIG_ROOT}"/XQuartzComponent.pkg "${PKG_DISTRIBUTION_PLIST}"

    productbuild --sign "${CODESIGN_IDENTITY_PKG}" --distribution "${PKG_DISTRIBUTION_PLIST}" --resources "${PKG_CONFIG_ROOT}"/resources --package-path "${PKG_CONFIG_ROOT}" "${PKG_OUTPUT}"
    rm "${PKG_CONFIG_ROOT}"/XQuartzComponent.pkg
}

do_dmg() {
    PKG_INPUT="${BASE_DIR}"/XQuartz-${APPLICATION_VERSION_STRING}.pkg
    DMG_OUTPUT="${BASE_DIR}"/XQuartz-${APPLICATION_VERSION_STRING}.dmg
    DMG_DIR="${BASE_DIR}"/XQuartz-${APPLICATION_VERSION_STRING}.d

    mkdir -p "${DMG_DIR}"
    cp "${PKG_INPUT}" "${DMG_DIR}"/Xquartz.pkg

    [[ -e "${DMG_OUTPUT}" ]] && rm -f "${DMG_OUTPUT}"
    hdiutil create -srcfolder "${DMG_DIR}" -fs JHFS+ -format UDBZ -volname "XQuartz-${APPLICATION_VERSION_STRING}" "${DMG_OUTPUT}"
    xcrun codesign -s "${CODESIGN_IDENTITY_APP}" --digest-algorithm=sha1,sha256 --force "${DMG_OUTPUT}"
}

do_notarize() {
    DMG="${BASE_DIR}"/XQuartz-${APPLICATION_VERSION_STRING}.dmg

    ALTOOL_USER_FILE="${BASE_DIR}"/pkg/altool.user
    ALTOOL_PASS_FILE="${BASE_DIR}"/pkg/altool.password

    ALTOOL_APIKEY_FILE="${BASE_DIR}"/pkg/altool.apiKey
    ALTOOL_APIISSUER_FILE="${BASE_DIR}"/pkg/altool.apiIssuer

    ALTOOL_CLIFF_DIR="${BASE_DIR}"/pkg/altool.cliff
    ALTOOL_CLIFF_PROPERTIES="${BASE_DIR}"/pkg/altool.cliff.properties

    # <rdar://problem/52532145> Latest XQuartz is not notarized
    if [ -f "${ALTOOL_APIKEY_FILE}" -a -f "${ALTOOL_APIISSUER_FILE}" ] ; then
         ALTOOL_AUTH="--apiKey $(cat "${ALTOOL_APIKEY_FILE}") --apiIssuer $(cat "${ALTOOL_APIISSUER_FILE}")"
    elif [ -f "${ALTOOL_USER_FILE}" -a -f "${ALTOOL_PASS_FILE}" ] ; then
        ALTOOL_AUTH="-u $(cat "${ALTOOL_USER_FILE}") -p $(cat "${ALTOOL_PASS_FILE}")"
    elif [ -f "${ALTOOL_USER_FILE}" -a -d "${ALTOOL_CLIFF_DIR}" -a -f "${ALTOOL_CLIFF_PROPERTIES}" ] ; then
        ALTOOL_AUTH="-u $(cat "${ALTOOL_USER_FILE}") --cliff-path ${ALTOOL_CLIFF_DIR}/bin/cliff --cliff-properties-file ${ALTOOL_CLIFF_PROPERTIES}"
    fi

    if [ -n "${ALTOOL_AUTH}" ] ; then
        xcrun altool --notarize-app --primary-bundle-id org.xquartz.X11 ${ALTOOL_AUTH} --file "${DMG}" --asc-provider "${CODESIGN_ASC_PROVIDER}"

        # Check the notarization with:
        echo "Check on the status of notarization with:"
        echo "   xcrun altool --notarization-info <request-uuid> <auth information>"

        sleep 10
        while ! xcrun stapler staple "${DMG}" ; do
            echo "Waiting for notarization to complete"
            sleep 10
        done

        # Check the disk image with:
        # spctl --assess --type open --context context:primary-signature --verbose "${DMG}"
    fi
}

do_dist() {
    DMG="${BASE_DIR}"/XQuartz-${APPLICATION_VERSION_STRING}.dmg
    SYM_TARBALL="${BASE_DIR}"/XQuartz-${APPLICATION_VERSION_STRING}.dSYMS.tar.bz2

    openssl sha256 "${DMG}" > "${DMG}".sha256sum
    openssl sha512 "${DMG}" > "${DMG}".sha512sum

    openssl sha256 "${SYM_TARBALL}" > "${SYM_TARBALL}".sha256sum
    openssl sha512 "${SYM_TARBALL}" > "${SYM_TARBALL}".sha512sum

    if [ -f "${BASE_DIR}"/pkg/bintray.cred ] ; then
        BINTRAY_CRED="$(cat "${BASE_DIR}"/pkg/bintray.cred)"
        for f in "${DMG}"* "${SYM_TARBALL}"* ; do
            echo "Uploading ${f}"
            curl -T "${f}" -u${BINTRAY_CRED} https://api.bintray.com/content/xquartz/downloads/XQuartz/"${APPLICATION_VERSION_STRING}"/$(basename "${f}")

            # The response printed by curl has no newline, so add it here
            echo ""
        done

        echo "Visit https://bintray.com/xquartz/downloads/XQuartz/${APPLICATION_VERSION_STRING}/view/general to accept the uploads to bintray"
    fi

    if [ -f "${BASE_DIR}"/pkg/sparkle_priv.pem ] ; then
        DSA=$(openssl dgst -sha1 -binary < "${DMG}" | openssl dgst -sha1 -sign "${BASE_DIR}"/pkg/sparkle_priv.pem | openssl enc -base64)
        SIZE=$(wc -c "${DMG}" | awk '{print $1}')

        echo "      <item>"
        echo "         <sparkle:minimumSystemVersion>${MACOSX_DEPLOYMENT_TARGET}</sparkle:minimumSystemVersion>"
        echo "         <title>XQuartz-${APPLICATION_VERSION_STRING}</title>"
        echo "         <sparkle:releaseNotesLink>https://www.xquartz.org/releases/bare/XQuartz-${APPLICATION_VERSION_STRING}.html</sparkle:releaseNotesLink>"
        echo "         <pubDate>$(date -u +"%a, %d %b %Y %T %Z")</pubDate>"
        echo "         <enclosure url=\"https://dl.bintray.com/xquartz/downloads/XQuartz-${APPLICATION_VERSION_STRING}.dmg\" sparkle:version=\"${APPLICATION_VERSION}\" sparkle:shortVersionString=\"XQuartz-${APPLICATION_VERSION_STRING}\" length=\"${SIZE}\" type=\"application/octet-stream\" sparkle:dsaSignature=\"${DSA}\" sparkle:installationType=\"package\" />"
        echo "      </item>"
    fi

    echo "Commits For the release page:"
    cd "${BASE_DIR}"
    git submodule | egrep -v '(cairo|libpng1[245]|libXaw8|libXevie|libXfontcache|libxkbui|libXp |libXt-flatnamespace|libXTrap|libXTrap|libXxf86misc|xpyb|xorg/test)' | sed 's: *\(.*\) src/\(.*\) (\(.*\)):  * \2 \3 (\1):'
}

if [ -d ${BUILD_TOOLS_PREFIX}/share/pkgconfig -o -d ${BUILD_TOOLS_PREFIX}/lib/pkgconfig ] ; then
    die "Ensure that these directories don't exist as they can interfere with the build:
${BUILD_TOOLS_PREFIX}/share/pkgconfig
${BUILD_TOOLS_PREFIX}/lib/pkgconfig"
fi

# TODO: Is there a better way to do this?
if [ ! -f submodules.initialized ] ; then
    git submodule init || die "Failed to initialize submodules"
    git submodule update || die "Failed to initialize submodules"
    git submodule foreach git submodule init || die "Failed to initialize submodules"
    git submodule foreach git submodule update || die "Failed to initialize submodules"
    touch submodules.initialized
fi

# Install our base configs and other misc content
sudo ditto ${BASE_DIR}/base ${DESTDIR}
sudo ditto ${BASE_DIR}/base /

if [ -n "${SANITIZER_LIBS}" ] ; then
    sudo install -o root -g wheel -m 0755 -d ${DESTDIR}${PREFIX}/lib/asan
    sudo install -o root -g wheel -m 0755 -d ${PREFIX}/lib/asan

    for dylib in ${SANITIZER_LIBS} ; do
        sudo install -o root -g wheel -m 0755 ${SANITIZER_LIB_DIR}/${dylib} ${DESTDIR}${PREFIX}/lib/asan
        sudo install -o root -g wheel -m 0755 ${SANITIZER_LIB_DIR}/${dylib} ${PREFIX}/lib/asan
    done
fi

# Build Sparkle
cd ${BASE_DIR}/src/Sparkle
do_patches ${BASE_DIR}/src/Sparkle.patches
xcodebuild install -configuration Release \
    ARCHS="arm64 x86_64" \
    DSTROOT="${DESTDIR}.Sparkle" \
    INSTALL_PATH="${APPLICATION_PATH}/XQuartz.app/Contents/Frameworks" \
    DYLIB_INSTALL_NAME_BASE="@executable_path/../Frameworks" \
    MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET}" \
    DEAD_CODE_STRIPPING=NO \
    GCC_GENERATE_DEBUGGING_SYMBOLS=YES

sudo ditto ${DESTDIR}.Sparkle ${DESTDIR}
sudo ditto ${DESTDIR}.Sparkle /

# Bincompat versions of libpng
#do_autotools_build src/libpng/libpng12
#do_autotools_build src/libpng/libpng14
#do_autotools_build src/libpng/libpng15
#sudo rm -f {${DESTDIR}${PREFIX},${PREFIX}}/bin/libpng*-config
#sudo rm -f {${DESTDIR}${PREFIX},${PREFIX}}/lib/libpng1?.dylib
#sudo rm -f {${DESTDIR}${PREFIX},${PREFIX}}/lib/libpng12.0.*.dylib
#sudo rm -f {${DESTDIR}${PREFIX},${PREFIX}}/lib/libpng.3.*.0.dylib

do_autotools_build src/libpng/libpng16

do_autotools_build src/freetype2
do_autotools_build src/pixman

do_autotools_build src/fontconfig

do_autotools_build src/xorg/util/macros

do_autotools_build src/xorg/doc/xorg-docs
do_autotools_build src/xorg/doc/xorg-sgml-doctools

do_autotools_build src/xorg/proto/xorgproto
do_autotools_build src/xorg/proto/xcbproto

do_autotools_build src/xorg/util/bdftopcf
do_autotools_build src/xorg/util/lndir

do_autotools_build src/xorg/font/util

do_autotools_build src/xorg/lib/libxtrans
do_autotools_build src/xorg/lib/pthread-stubs

do_autotools_build src/xorg/lib/libXau

do_autotools_build src/xorg/lib/libxcb
do_autotools_build src/xorg/lib/libxcb-util
do_autotools_build src/xorg/lib/libxcb-render-util
do_autotools_build src/xorg/lib/libxcb-image
do_autotools_build src/xorg/lib/libxcb-cursor
do_autotools_build src/xorg/lib/libxcb-errors
do_autotools_build src/xorg/lib/libxcb-keysyms
do_autotools_build src/xorg/lib/libxcb-wm

do_autotools_build src/xorg/lib/libXdmcp
do_autotools_build src/xorg/lib/libX11
do_autotools_build src/xorg/lib/libXext
do_autotools_build src/xorg/lib/libAppleWM
do_autotools_build src/xorg/lib/libdmx
do_autotools_build src/xorg/lib/libfontenc
do_autotools_build src/xorg/lib/libxshmfence
do_autotools_build src/xorg/lib/libFS
do_autotools_build src/xorg/lib/libICE
do_autotools_build src/xorg/lib/libSM

# Bincompat
#do_autotools_build src/xorg/lib/libXt-flatnamespace

do_autotools_build src/xorg/lib/libXt

# Bincompat
#do_autotools_build src/xorg/lib/libXt7-stub

do_autotools_build src/xorg/lib/libXmu
do_autotools_build src/xorg/lib/libXpm

# Bincompat
#do_autotools_build src/xorg/lib/libXaw8

do_autotools_build src/xorg/lib/libXaw
do_autotools_build src/xorg/lib/libXaw3d
do_autotools_build src/xorg/lib/libXfixes
do_autotools_build src/xorg/lib/libXcomposite
do_autotools_build src/xorg/lib/libXrender
do_autotools_build src/xorg/lib/libXdamage
do_autotools_build src/xorg/lib/libXcursor
do_autotools_build src/xorg/lib/libXfont
do_autotools_build src/xorg/lib/libXfont2
do_autotools_build src/xorg/lib/libXxf86vm
do_autotools_build src/xorg/lib/libXft
do_autotools_build src/xorg/lib/libXi
do_autotools_build src/xorg/lib/libXinerama
do_autotools_build src/xorg/lib/libxkbfile
do_autotools_build src/xorg/lib/libXrandr
do_autotools_build src/xorg/lib/libXpresent
do_autotools_build src/xorg/lib/libXres
do_autotools_build src/xorg/lib/libXScrnSaver
do_autotools_build src/xorg/lib/libXtst
do_autotools_build src/xorg/lib/libXv
do_autotools_build src/xorg/lib/libXvMC

do_autotools_build src/xorg/data/bitmaps

do_autotools_build src/xorg/app/appres
do_autotools_build src/xorg/app/beforelight
do_autotools_build src/xorg/app/bitmap
do_autotools_build src/xorg/app/editres
do_autotools_build src/xorg/app/fonttosfnt
do_autotools_build src/xorg/app/fslsfonts
do_autotools_build src/xorg/app/fstobdf
do_autotools_build src/xorg/app/iceauth
do_autotools_build src/xorg/app/ico
do_autotools_build src/xorg/app/listres
do_autotools_build src/xorg/app/luit
do_autotools_build src/xorg/app/mkfontdir
do_autotools_build src/xorg/app/mkfontscale
do_autotools_build src/xorg/app/oclock
do_autotools_build src/xorg/app/quartz-wm
do_autotools_build src/xorg/app/rgb
do_autotools_build src/xorg/app/sessreg
do_autotools_build src/xorg/app/setxkbmap
do_autotools_build src/xorg/app/showfont
do_autotools_build src/xorg/app/smproxy
do_autotools_build src/xorg/app/twm
do_autotools_build src/xorg/app/viewres
do_autotools_build src/xorg/app/xauth
do_autotools_build src/xorg/app/xbacklight
do_autotools_build src/xorg/app/xcalc
do_autotools_build src/xorg/app/xclipboard
do_autotools_build src/xorg/app/xclock
do_autotools_build src/xorg/app/xcmsdb
do_autotools_build src/xorg/app/xcompmgr
do_autotools_build src/xorg/app/xconsole
do_autotools_build src/xorg/app/xcursorgen
do_autotools_build src/xorg/app/xditview
do_autotools_build src/xorg/app/xdm
do_autotools_build src/xorg/app/xdpyinfo
do_autotools_build src/xorg/app/xedit
do_autotools_build src/xorg/app/xev
do_autotools_build src/xorg/app/xeyes
do_autotools_build src/xorg/app/xfd
do_autotools_build src/xorg/app/xfontsel
do_autotools_build src/xorg/app/xfs
do_autotools_build src/xorg/app/xfsinfo
do_autotools_build src/xorg/app/xgamma
do_autotools_build src/xorg/app/xgc
do_autotools_build src/xorg/app/xhost
do_autotools_build src/xorg/app/xinit
do_autotools_build src/xorg/app/xinput
do_autotools_build src/xorg/app/xkbcomp
do_autotools_build src/xorg/app/xkbevd
do_autotools_build src/xorg/app/xkbprint
do_autotools_build src/xorg/app/xkbutils
do_autotools_build src/xorg/app/xkill
do_autotools_build src/xorg/app/xload
do_autotools_build src/xorg/app/xlogo
do_autotools_build src/xorg/app/xlsatoms
do_autotools_build src/xorg/app/xlsclients
do_autotools_build src/xorg/app/xlsfonts
do_autotools_build src/xorg/app/xmag
do_autotools_build src/xorg/app/xman
do_autotools_build src/xorg/app/xmessage
do_autotools_build src/xorg/app/xmh
do_autotools_build src/xorg/app/xmodmap
do_autotools_build src/xorg/app/xmore
do_autotools_build src/xorg/app/xpr
do_autotools_build src/xorg/app/xprop
do_autotools_build src/xorg/app/xrandr
do_autotools_build src/xorg/app/xrdb
do_autotools_build src/xorg/app/xrefresh
do_autotools_build src/xorg/app/xscope
do_autotools_build src/xorg/app/xset
do_autotools_build src/xorg/app/xsetmode
do_autotools_build src/xorg/app/xsetpointer
do_autotools_build src/xorg/app/xsetroot
do_autotools_build src/xorg/app/xsm
do_autotools_build src/xorg/app/xstdcmap
do_autotools_build src/xorg/app/xvinfo
do_autotools_build src/xorg/app/xwd
do_autotools_build src/xorg/app/xwininfo
do_autotools_build src/xorg/app/xwud

do_autotools_build src/xterm

do_autotools_build src/xorg/data/cursors

do_autotools_build src/xorg/font/encodings
do_autotools_build src/xorg/font/adobe-100dpi
do_autotools_build src/xorg/font/adobe-75dpi
do_autotools_build src/xorg/font/adobe-utopia-100dpi
do_autotools_build src/xorg/font/adobe-utopia-75dpi
do_autotools_build src/xorg/font/adobe-utopia-type1
do_autotools_build src/xorg/font/alias
do_autotools_build src/xorg/font/arabic-misc
do_autotools_build src/xorg/font/bh-100dpi
do_autotools_build src/xorg/font/bh-75dpi
do_autotools_build src/xorg/font/bh-lucidatypewriter-100dpi
do_autotools_build src/xorg/font/bh-lucidatypewriter-75dpi
do_autotools_build src/xorg/font/bh-ttf
do_autotools_build src/xorg/font/bh-type1
do_autotools_build src/xorg/font/bitstream-100dpi
do_autotools_build src/xorg/font/bitstream-75dpi
do_autotools_build src/xorg/font/bitstream-speedo
do_autotools_build src/xorg/font/bitstream-type1
do_autotools_build src/xorg/font/cronyx-cyrillic
do_autotools_build src/xorg/font/cursor-misc
do_autotools_build src/xorg/font/daewoo-misc
do_autotools_build src/xorg/font/dec-misc
do_autotools_build src/xorg/font/ibm-type1
do_autotools_build src/xorg/font/isas-misc
do_autotools_build src/xorg/font/jis-misc
do_autotools_build src/xorg/font/micro-misc
do_autotools_build src/xorg/font/misc-cyrillic
do_autotools_build src/xorg/font/misc-ethiopic
do_autotools_build src/xorg/font/misc-meltho
do_autotools_build src/xorg/font/misc-misc
do_autotools_build src/xorg/font/mutt-misc
do_autotools_build src/xorg/font/schumacher-misc
do_autotools_build src/xorg/font/screen-cyrillic
do_autotools_build src/xorg/font/sony-misc
do_autotools_build src/xorg/font/sun-misc
do_autotools_build src/xorg/font/winitzki-cyrillic
do_autotools_build src/xorg/font/xfree86-type1

do_meson_build src/mesa/mesa
do_autotools_build src/mesa/glu
do_autotools_build src/freeglut

# Manually build glxinfo and glxgears
cd ${BASE_DIR}/src/mesa/demos/src/xdemos
${CC} ${CPPFLAGS} ${CFLAGS} -c glxinfo.c
${CC} ${CPPFLAGS} ${CFLAGS} -c glinfo_common.c
${CC} ${CPPFLAGS} ${CFLAGS} -c glxgears.c
${CC} ${LDFLAGS} glxinfo.o glinfo_common.o -lGL -lX11 -o glxinfo
${CC} ${LDFLAGS} glxgears.o -lGL -lX11 -o glxgears

sudo install -o root -g wheel -m 0755 -d ${DESTDIR}${PREFIX}/bin
sudo install -o root -g wheel -m 0755 glxinfo ${DESTDIR}${PREFIX}/bin
sudo install -o root -g wheel -m 0755 glxgears ${DESTDIR}${PREFIX}/bin

sudo install -o root -g wheel -m 0755 -d ${PREFIX}/bin
sudo install -o root -g wheel -m 0755 glxinfo ${PREFIX}/bin
sudo install -o root -g wheel -m 0755 glxgears ${PREFIX}/bin

# TODO do_autotools_build src/cairo
# TODO do_autotools_build src/xorg/lib/xpyb

do_autotools_build src/xkeyboard-config

do_autotools_build src/xorg/xserver
do_autotools_build src/xorg/driver/xf86-input-void
do_autotools_build src/xorg/driver/xf86-video-dummy
do_autotools_build src/xorg/driver/xf86-video-nested

do_autotools_build src/xquartz/xserver

# We want X to be Xquartz by default
sudo rm -f ${DESTDIR}${PREFIX}/bin/X
sudo ln -s Xquartz ${DESTDIR}${PREFIX}/bin/X
sudo rm -f ${PREFIX}/bin/X
sudo ln -s Xquartz ${PREFIX}/bin/X

# TODO: Do we want to do anything with the tests?
#do_autotools_build src/xorg/test/rendercheck
#do_autotools_build src/xorg/test/x11perf
#do_autotools_build src/xorg/test/xhiv
#do_autotools_build src/xorg/test/xorg-gtest
#do_autotools_build src/xorg/test/xorg-integration-tests
#do_autotools_build src/xorg/test/xts
#do_autotools_build src/xorg/test/xtsttopng

do_checks

do_strip_sign_dsyms
do_sym_tarball
do_pkg
do_dmg

set +x

/bin/echo -n "Proceed with notarization? (enter \"YES\" to notarize) "
read MAYBE
if [ "${MAYBE}" != "YES" ] ; then
    exit 0
fi

do_notarize

/bin/echo -n "Proceed with distribution? (enter \"YES\" to distribute) "
read MAYBE
if [ "${MAYBE}" != "YES" ] ; then
    exit 0
fi

do_dist

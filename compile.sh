#!/bin/sh -x -e

# Note that the build system needs to be macOS 11.3 or newer, Intel or Apple Silicon
#
# Before building, be sure to checkout sources and configure the system:
#
# 1) Install the latest version of Xcode.
#
# 2) Use the the "install-or-update-macports.sh" script to install autoconf, automake,
#    pkgconfig, glibtool, and meson to ${BUILD_TOOLS_PREFIX_STD} and cmake to
#    ${BUILD_TOOLS_PREFIX_CMAKE}.
#
# 3) Make sure the ${BUILD_TOOLS_PREFIX_*}/{lib,share}/pkgconfig directories are moved
#    aside or they will interfere.  The "install-or-update-macports.sh" script will
#    manage these directories for you, moving them aside on completion and back on
#    future updates.
#
# 4) Setup authentication for notarytool with one of the following options:
#    4a) Create an app-specific password for notarytool at appleid.apple.com.  Save this as pkg/notarytool.user and pkg/notarytool.password
#    4b) Create an API Key as documented at https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api
#        Save this as pkg/notarytool.user and pkg/notarytool.password
#
# 5) Add credential files to the pkg sundirectory:
#        pkg/notarytool.* (see #4 above)
#        pkg/sparkle_dsa_priv.pem
#        pkg/sparkle_eddsa_priv.key
#        pkg/github.token (see https://docs.github.com/en/articles/creating-an-access-token-for-command-line-use)
#        pkg/github.user
#
# 6) Ensure the macOS keychain contains the private key for our Developer ID certificates
#
# To update a submodule to a newer version, just checkout the appropriate
# branch in the submodule and then commit the changed hash at the top level.

PREFIX=/opt/X11
BUILD_TOOLS_PREFIX_STD="/opt/buildX11"
BUILD_TOOLS_PREFIX_CMAKE="/opt/buildX11-cmake"
APPLICATION_PATH=/Applications/Utilities
IDENTIFIER_PREFIX=org.xquartz

CODESIGN_ASC_PROVIDER="NA574AWV7E"
CODESIGN_IDENTITY_APP="Developer ID Application: Apple Inc. - XQuartz (${CODESIGN_ASC_PROVIDER})"
CODESIGN_IDENTITY_PKG="Developer ID Installer: Apple Inc. - XQuartz (${CODESIGN_ASC_PROVIDER})"

APPLICATION_VERSION=2.8.54
APPLICATION_VERSION_STRING=2.8.5_beta5

SPARKLE_PUBLIC_EDKEY="pgjiBdCBJJg1rSqFR3GtMPXaRKcU9Jjeh6OqfkH4j+8="
if [ "${APPLICATION_VERSION_STRING}" != "${APPLICATION_VERSION_STRING/alpha/}" ] ; then
    SPARKLE_FEED_URL="https://www.xquartz.org/releases/sparkle-r1/alpha.xml"
elif [ "${APPLICATION_VERSION_STRING}" != "${APPLICATION_VERSION_STRING/beta/}" ] ; then
    SPARKLE_FEED_URL="https://www.xquartz.org/releases/sparkle-r1/beta.xml"
elif [ "${APPLICATION_VERSION_STRING}" != "${APPLICATION_VERSION_STRING/rc/}" ] ; then
    SPARKLE_FEED_URL="https://www.xquartz.org/releases/sparkle-r1/rc.xml"
else
    SPARKLE_FEED_URL="https://www.xquartz.org/releases/sparkle-r1/release.xml"
fi

if [ "${APPLICATION_VERSION_STRING}" != "${APPLICATION_VERSION_STRING/alpha/}" ] ; then
    # Alpha builds use ASan
    SANITIZER_LIB_DIR_SRC=$(echo $(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/*/lib/darwin)

    SANITIZER_CFLAGS="-fsanitize=address"
    SANITIZER_LIBS="libclang_rt.asan_osx_dynamic.dylib"
    SANITIZER_LIB_DIR="${PREFIX}/lib/sanitizers"

    SANITIZER_LDFLAGS="-Wl,-rpath,${SANITIZER_LIB_DIR}"
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

ARCHS_BIN="arm64 x86_64"
ARCHS_LIB="${ARCHS_BIN}"
ARCHS_LIB_BINCOMPAT_2_7="x86_64"

if [ -d "/Library/Developer/CommandLineTools/SDKs/MacOSX10.13.sdk" ] ; then
    SDKROOT_i386="/Library/Developer/CommandLineTools/SDKs/MacOSX10.13.sdk"
    ARCHS_LIB="${ARCHS_LIB} i386"
    ARCHS_LIB_BINCOMPAT_2_7="${ARCHS_LIB_BINCOMPAT_2_7} i386"
else
    echo "This build will not be distributable due to lack of i386 support."
fi

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

export XMLTO=${BUILD_TOOLS_PREFIX_STD}/bin/xmlto
export ASCIIDOC=${BUILD_TOOLS_PREFIX_STD}/bin/asciidoc
export DOXYGEN=${BUILD_TOOLS_PREFIX_STD}/bin/doxygen
export FOP=${BUILD_TOOLS_PREFIX_STD}/bin/fop
export FOP_OPTS="-Xmx2048m -Djava.awt.headless=true"
export GROFF=${BUILD_TOOLS_PREFIX_STD}/bin/groff
export PS2PDF=${BUILD_TOOLS_PREFIX_STD}/bin/ps2pdf

export PATH="${PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PKG_CONFIG_PATH="${PREFIX}/share/pkgconfig:${PREFIX}/lib/pkgconfig"
export FONTPATH="${PREFIX}/share/fonts/misc/,${PREFIX}/share/fonts/TTF/,${PREFIX}/share/fonts/OTF,${PREFIX}/share/fonts/Type1/,${PREFIX}/share/fonts/75dpi/:unscaled,${PREFIX}/share/fonts/100dpi/:unscaled,${PREFIX}/share/fonts/75dpi/,${PREFIX}/share/fonts/100dpi/,/Library/Fonts,${PREFIX}/share/system_fonts"
export ACLOCAL="aclocal -I ${PREFIX}/share/aclocal -I ${BUILD_TOOLS_PREFIX_STD}/share/aclocal"

die() {
    echo "${@}" >&2
    exit 1
}

first() {
    local all="${@}"
    echo "${all%% *}"
}

last() {
    local all="${@}"
    echo "${all##* }"
}

has() {
    local target=${1}
    shift || return 1

    for s in "${@}"; do
        if [ "${target}" == "${s}" ] ; then
            return 0
        fi
    done
    return 1
}

remove() {
    local target=${1}
    local result=""
    shift || return 0

    for s in "${@}"; do
        if [ "${target}" != "${s}" ] ; then
            result="${result:+${result} }${s}"
        fi
    done
    echo "${result}"
}

setup_environment() {
    local archs=${@}
    local arch_flags="-target fat-apple-macos${MACOSX_DEPLOYMENT_TARGET}"
    local sdkdir

    for arch in ${archs} ; do
        arch_flags="${arch_flags} -arch ${arch}"
    done

    if has i386 ${archs} ; then
        sdkdir=${SDKROOT_i386}
    fi

    export CPPFLAGS="-I${PREFIX}/include -F${APPLICATION_PATH}/XQuartz.app/Contents/Frameworks -DFAIL_HARD"
    export CFLAGS="${sdkdir:+-isysroot ${sdkdir}} ${arch_flags} ${OPT_CFLAGS} ${DEBUG_CFLAGS} ${HARDENING_CFLAGS} ${WARNING_CFLAGS}"
    export LDFLAGS="${sdkdir:+-isysroot ${sdkdir}} ${arch_flags} -L${PREFIX}/lib -F${APPLICATION_PATH}/XQuartz.app/Contents/Frameworks"

    if ! has i386 ${archs} ; then
        export CFLAGS="${CFLAGS} ${SANITIZER_CFLAGS}"
        export LDFLAGS="${LDFLAGS} ${SANITIZER_LDFLAGS}"
    fi

    export CXXFLAGS="${CFLAGS}"
    export OBJCFLAGS="${CFLAGS}"

    # These are all the same now, but could be conditionalized in the future
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
}

do_patches() {
    local patchdir="${1}"
    if [ -d "${patchdir}" -a ! -f "${patchdir}/applied" ] ; then
        for patch in "${patchdir}"/* ; do
            patch -p1 < "${patch}" || die "Unable to apply patch ${patch}"
        done
        touch "${patchdir}/applied"
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
    local project_dir="${BASE_DIR}/${1}"
    local config=${2}
    local variable="ARCHS_${config}"
    local archs=${!variable}

    local patches_dir="${project_dir}.patches"
    local confopt_file="${project_dir}.confopt"
    [ -f "${confopt_file}" ] || confopt_file=/dev/null

    cd "${project_dir}" || die "Could not change directory to ${project_dir}"

    export PATH="${PREFIX}/bin:${BUILD_TOOLS_PREFIX_STD}/bin:/usr/bin:/bin:/usr/sbin:/sbin"

    PROJECT=$(basename $(pwd))

    do_patches "${patches_dir}"

    case ${PROJECT} in
    xterm)
        ;;
    *)
        if [ ! -f configure -o "${SKIP_AUTORECONF}" != "YES" ] ; then
            autoreconf -fvi || die "Unable to autoreconf in $(pwd)"
        fi
        ;;
    esac

    # Cleanup the universal hack directories
    sudo rm -rf "${DESTDIR}".lipo.*

    if ! has i386 ${archs} ; then
        # x86_64 and arm64 can always be built together
        do_autotools_build_sub fat ${confopt_file} ${archs}
    elif [ -z "${SANITIZER_LIBS}" ] && ! has arm64 ${archs} ; then
        # i386 and x86_64 can be built together (against the older SDK) if we
        # don't also need an arm64 slice (eg: legacy bincompat dylibs)
        do_autotools_build_sub fat ${confopt_file} ${archs}
    else
        # We need to build an x86_64 slice along with i386 in order for it to execute on Apple Silico Macs
        do_autotools_build_sub noarm "${confopt_file}" $(remove arm64 ${archs})
        do_autotools_build_sub no32 "${confopt_file}" $(remove i386 ${archs})
        do_lipo noarm i386 no32 "$(remove i386 ${archs})"
    fi

    case ${PROJECT} in
    libXaw8|libXp|libXevie|libXfontcache|libxkbui|libXTrap|libXxf86misc)
        # These projects exist for bincompat reasons only.  Only ship libraries
        sudo rm -rf "${DESTDIR}.lipo.fat${PREFIX}/"{bin,include,share,lib/pkgconfig}
        for f in ${DESTDIR}.lipo.fat${PREFIX}/lib/* ; do
            [ -h "${f}" ] && sudo rm "${f}"
        done
        ;;
    esac

    # Remove LC_RPATHs that the compiler adds for sanitizers (we set our own)
    find "${DESTDIR}.lipo.fat" -type f | while read file ; do
        if /usr/bin/file "${file}" | grep -q "Mach-O" ; then
            if [ -n "${SANITIZER_LIB_DIR_SRC}" ] ; then
                sudo install_name_tool -delete_rpath "${SANITIZER_LIB_DIR_SRC}" "${file}" >& /dev/null || true
            fi
        fi
    done

    sudo ditto "${DESTDIR}.lipo.fat" "${DESTDIR}"
    sudo ditto "${DESTDIR}.lipo.fat" /

    # Cleanup the universal hack directories
    sudo rm -rf "${DESTDIR}".lipo.*

    export PATH="${PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
}

do_autotools_build_sub() {
    local set=$1
    shift
    local confopt_file=${1}
    shift
    local archs=${@}

    setup_environment ${archs} || die "Failed to setup environment"

    ${SCAN_BUILD} ./configure --prefix=${PREFIX} --disable-static --enable-docs --enable-devel-docs --enable-builddocs --with-doxygen --with-xmlto --with-fop $(eval echo $(cat "${confopt_file}")) || die "Could not configure in $(pwd)"

    [[ "${SKIP_CLEAN}" == "YES" ]] || ${MAKE} clean || die "Unable to make clean in $(pwd)"

    ${SCAN_BUILD} ${MAKE} ${MAKE_OPTS} || die "Could not make in $(pwd)"

    sudo ${MAKE} install DESTDIR=${DESTDIR}.lipo.${set} || die "Could not make install in $(pwd)"

    # Prune the .la files that we don't want
    sudo rm -f ${DESTDIR}.lipo.${set}${PREFIX}/lib/*.la
}

# Lipo out multiple ${DESTDIR}.<set> into ${DESTDIR}.fat
# do_lipo <set 1> <archs 1> [... <set n> <archs n>]
do_lipo() {
    local sets=""
    local archs=""
    local input_files=""

    # Thin out our sets to just the archs we want from each set.
    # This is because we can have x86_64 in both i386+x86_64 and arm64+x86_64
    while true ; do
        set=$1
        shift || break
        archs=$1
        shift || die "Invalid usage of do_lipo"

        sets="${sets} ${set}"

        pushd "${DESTDIR}.lipo.${set}"
        find . -type f | while read file ; do
            if /usr/bin/file "${file}" | grep -q "Mach-O" ; then
                for arch in $(lipo -archs "${file}") ; do
                    if ! has ${arch} ${archs} ; then
                        sudo lipo -remove ${arch} -output ${file}.lipo_result ${file} || die "lipo failed to remove ${arch} from ${file}"
                        sudo mv ${file}.lipo_result ${file} || die "failed to move lipo result back"
                    fi
                done
            fi
        done
        popd
    done

    # Now lipo everything together
    sudo cp -a "${DESTDIR}.lipo.$(first ${sets})" "${DESTDIR}.lipo.fat"

    pushd "${DESTDIR}.lipo.fat"
    find . -type f | while read file ; do
        if /usr/bin/file "${file}" | grep -q "Mach-O" ; then
            unset input_files
            for set in ${sets} ; do
                input_files="${input_files} ${DESTDIR}.lipo.${set}/${file}"
            done
            sudo lipo -create -output "${file}" ${input_files} || die "lipo failed to create ${file}"
        fi
    done
}

do_meson_build() {
    local project_dir="${BASE_DIR}/${1}"
    local config=${2}
    local variable="ARCHS_${config}"
    local archs=${!variable}

    local patches_dir="${project_dir}.patches"
    local confopt_file="${project_dir}.confopt"
    local meson_cross_dir="${BASE_DIR}/meson_support/meson/cross"
    [ -f "${confopt_file}" ] || confopt_file=/dev/null

    cd "${project_dir}" || die "Could not change directory to ${project_dir}"

    export PATH="${PREFIX}/bin:${BUILD_TOOLS_PREFIX_STD}/bin:/usr/bin:/bin:/usr/sbin:/sbin"

    PROJECT=$(basename $(pwd))

    do_patches "${patches_dir}"

    # Cleanup the universal hack directories
    sudo rm -rf "${DESTDIR}".lipo.*

    # We need to do this hacky dance because of a bug in meson.
    # We need to configure meson as a cross compiler to build arm64 from x86_64
    # See https://mesonbuild.com/Cross-compilation.html
    # https://github.com/mesonbuild/meson/issues/8206
    for arch in ${archs} ; do
        setup_environment ${arch} || die "Failed to setup environment"
        meson build.${arch} -Dprefix=${PREFIX} $(eval echo $(cat "${confopt_file}")) --cross-file ${meson_cross_dir}/${arch}-darwin-xquartz || die "Could not configure in $(pwd)"
        ninja --verbose -C build.${arch} || die "Failed to compile in $(pwd)"
        sudo DESTDIR="${DESTDIR}.lipo.${arch}" ninja --verbose -C build.${arch} install || die "Failed to install in $(pwd)"

        # Meson removes the LC_RPATH that we asked for.  This hack re-adds it
        # cf: https://github.com/mesonbuild/meson/issues/11109
        find "${DESTDIR}.lipo.${arch}" -type f | while read file ; do
            if /usr/bin/file "${file}" | grep -q "Mach-O" ; then
                sudo install_name_tool -add_rpath "${SANITIZER_LIB_DIR}" "${file}"
            fi
        done

        # Prune the .la files that we don't want
        sudo rm -f "${DESTDIR}.lipo.${arch}${PREFIX}/lib"/*.la
    done

    if [ "$(last ${archs})" == "$(first ${archs})" ] ; then
        sudo cp -a "${DESTDIR}.lipo.$(first ${archs})" "${DESTDIR}.lipo.fat"
    else
        local lipo_args=""
        for arch in ${archs} ; do
            lipo_args="${lipo_args} ${arch} ${arch}"
        done
        do_lipo ${lipo_args}
    fi

    sudo ditto "${DESTDIR}.lipo.fat" "${DESTDIR}"
    sudo ditto "${DESTDIR}.lipo.fat" /

    # Cleanup the universal hack directories
    sudo rm -rf "${DESTDIR}".lipo.*

    export PATH="${PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
}

do_cmake_build() {
    local project_dir="${BASE_DIR}/${1}"
    local config=${2}
    local variable="ARCHS_${config}"
    local archs=${!variable}

    local patches_dir="${project_dir}.patches"
    local confopt_file="${project_dir}.confopt"
    [ -f "${confopt_file}" ] || confopt_file=/dev/null

    cd "${project_dir}" || die "Could not change directory to ${project_dir}"

    export PATH="${PREFIX}/bin:${BUILD_TOOLS_PREFIX_CMAKE}/bin:/usr/bin:/bin:/usr/sbin:/sbin"

    PROJECT=$(basename $(pwd))

    do_patches "${patches_dir}"

    # Cleanup the universal hack directories
    sudo rm -rf "${DESTDIR}".lipo.*

    for arch in ${archs} ; do
        setup_environment ${arch} || die "Failed to setup environment"
        mkdir -p "${project_dir}/build.${arch}" || die "Failed to create build directory: ${project_dir}/build.${arch}"
        cd "${project_dir}/build.${arch}" || die "Could not change directory to ${project_dir}/build.${arch}"

        if [ "${arch}" == "i386" ] ; then
            sdkdir=${SDKROOT_i386}
        else
            sdkdir=$(xcrun --show-sdk-path)
        fi

        cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
              -DCMAKE_INSTALL_NAME_DIR="${PREFIX}/lib" \
              -DCMAKE_OSX_ARCHITECTURES="${arch}" \
              -DCMAKE_OSX_SYSROOT="${sdkdir}" \
              -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET}" \
              $(eval echo $(cat "${confopt_file}")) .. || die "Could not configure in $(pwd)"

        ${SCAN_BUILD} ${MAKE} ${MAKE_OPTS} VERBOSE=1 || die "Could not make in $(pwd)"
        sudo ${MAKE} install DESTDIR=${DESTDIR}.lipo.${arch} VERBOSE=1 || die "Could not make install in $(pwd)"

        # Prune the .la files that we don't want
        sudo rm -f "${DESTDIR}.lipo.${arch}${PREFIX}/lib"/*.la
    done

    if [ "$(last ${archs})" == "$(first ${archs})" ] ; then
        sudo cp -a "${DESTDIR}.lipo.$(first ${archs})" "${DESTDIR}.lipo.fat"
    else
        local lipo_args=""
        for arch in ${archs} ; do
            lipo_args="${lipo_args} ${arch} ${arch}"
        done
        do_lipo ${lipo_args}
    fi

    sudo ditto "${DESTDIR}.lipo.fat" "${DESTDIR}"
    sudo ditto "${DESTDIR}.lipo.fat" /

    # Cleanup the universal hack directories
    sudo rm -rf "${DESTDIR}".lipo.*

    export PATH="${PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin"
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

            if otool -L "${file}" | grep -q "${BUILD_TOOLS_PREFIX_STD}" ; then
                die "=== ${file} links against an invalid library ==="
            fi

            if otool -L "${file}" | grep -q "${BUILD_TOOLS_PREFIX_CMAKE}" ; then
                die "=== ${file} links against an invalid library ==="
            fi

            # Ignore Sparkle since it handles back deployment properly
            [ "${file/Sparkle/}" != "${file}" ] && continue

            # Ignore mesa for now
            [ "${file/swrast_dri.so/}" != "${file}" ] && continue
            [ "${file/libOSMesa/}" != "${file}" ] && continue

            # Ignore sanitizers
            [ "${file/asan/}" != "${file}" ] && continue
            [ "${file/ubsan/}" != "${file}" ] && continue
            [ "${file/tsan/}" != "${file}" ] && continue

            # Ignore _voucher* symbols (mig) and symbols from libc++ and libobjc that the compiler might have added
            if nm -arch x86_64 -m "${file}"  | grep -v "_voucher" | grep -v "darwin_check_fd_set_overflow" | grep -v "_pthread_attr_set_qos_class_np" | grep -v "_pthread_mutexattr" | grep -v "from libc++" | grep -v "from libobjc" | grep -q "(undefined) weak external" ; then
                die "=== ${file} has a weak link ==="
            fi
        fi
    done
}

do_remove_legacy_protos() {
    sudo rm -rf ${DESTDIR}${PREFIX}/include/X11/PM
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/evieproto.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xtrapbits.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xf86rushstr.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xcalibrateproto.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xf86mscstr.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xtrapddmi.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/lgewire.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/Xeviestr.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xtraplib.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/windowswm.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/fontcachstr.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xf86misc.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/fontcache.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xtrapemacros.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/Printstr.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/Print.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/windowswmstr.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xtrapproto.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xf86rush.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xtraplibp.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xcalibratewire.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/xtrapdi.h
    sudo rm -f ${DESTDIR}${PREFIX}/include/X11/extensions/fontcacheP.h
    sudo rm -f ${DESTDIR}${PREFIX}/share/pkgconfig/trapproto.pc
    sudo rm -f ${DESTDIR}${PREFIX}/share/pkgconfig/xcalibrateproto.pc
    sudo rm -f ${DESTDIR}${PREFIX}/share/pkgconfig/xproxymngproto.pc
    sudo rm -f ${DESTDIR}${PREFIX}/share/pkgconfig/fontcacheproto.pc
    sudo rm -f ${DESTDIR}${PREFIX}/share/pkgconfig/evieproto.pc
    sudo rm -f ${DESTDIR}${PREFIX}/share/pkgconfig/printproto.pc
    sudo rm -f ${DESTDIR}${PREFIX}/share/pkgconfig/xf86rushproto.pc
    sudo rm -f ${DESTDIR}${PREFIX}/share/pkgconfig/lg3dproto.pc
    sudo rm -f ${DESTDIR}${PREFIX}/share/pkgconfig/windowswmproto.pc
    sudo rm -f ${DESTDIR}${PREFIX}/share/pkgconfig/xf86miscproto.pc
    sudo rm -f ${DESTDIR}${PREFIX}/share/man/man7/Xprint.7
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

            if [ -z "${SANITIZER_LIBS}" ] ; then
                sudo strip -S "${file}"
            fi

            sudo codesign -s "${CODESIGN_IDENTITY_APP}" --digest-algorithm=sha1,sha256 --force --preserve-metadata=entitlements,requirements,flags --identifier "org.xquartz.$(basename "${file}")" --options runtime "${file}"
        fi
    done

    find "${PKG_ROOT}/Applications" -type f | while read file ; do
        if /usr/bin/file "${file}" | grep -q "Mach-O" ; then
            sudo dsymutil --out="${SYM_ROOT}"/$(basename "${file}").dSYM "${file}"
            sudo cp "${file}" "${SYM_ROOT}"

            if [ -z "${SANITIZER_LIBS}" ] ; then
                sudo strip -S "${file}"
            fi
        fi
    done

    sudo codesign -s "${CODESIGN_IDENTITY_APP}" --digest-algorithm=sha1,sha256 --deep --force --preserve-metadata=identifier,entitlements,requirements,flags --options runtime "${PKG_ROOT}${APPLICATION_PATH}"/XQuartz.app/Contents/Frameworks/Sparkle.framework/Versions/A/Resources/Autoupdate.app
    sudo codesign -s "${CODESIGN_IDENTITY_APP}" --digest-algorithm=sha1,sha256 --deep --force --preserve-metadata=identifier,entitlements,requirements,flags --options runtime "${PKG_ROOT}${APPLICATION_PATH}"/XQuartz.app/Contents/Frameworks/Sparkle.framework
    sudo codesign -s "${CODESIGN_IDENTITY_APP}" --digest-algorithm=sha1,sha256 --deep --force --preserve-metadata=identifier,entitlements,requirements,flags --options runtime --entitlements ${BASE_DIR}/XQuartz-entitlements.plist "${PKG_ROOT}${APPLICATION_PATH}"/XQuartz.app
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

do_notarize() {
    PKG="${BASE_DIR}"/XQuartz-${APPLICATION_VERSION_STRING}.pkg

    NOTARYTOOL_USER_FILE="${BASE_DIR}"/pkg/notarytool.user
    NOTARYTOOL_PASS_FILE="${BASE_DIR}"/pkg/notarytool.password

    NOTARYTOOL_APIKEY_FILE="${BASE_DIR}"/pkg/notarytool.apiKey
    NOTARYTOOL_APIISSUER_FILE="${BASE_DIR}"/pkg/notarytool.apiIssuer

    # <rdar://problem/52532145> Latest XQuartz is not notarized
    if [ -f "${NOTARYTOOL_APIKEY_FILE}" -a -f "${NOTARYTOOL_APIISSUER_FILE}" ] ; then
        NOTARYTOOL_AUTH="--key $(cat "${NOTARYTOOL_APIKEY_FILE}") --issuer $(cat "${NOTARYTOOL_APIISSUER_FILE}")"
    elif [ -f "${NOTARYTOOL_USER_FILE}" -a -f "${NOTARYTOOL_PASS_FILE}" ] ; then
        NOTARYTOOL_AUTH="--apple-id $(cat "${NOTARYTOOL_USER_FILE}") --password $(cat "${NOTARYTOOL_PASS_FILE}")"
    fi

    if [ -n "${NOTARYTOOL_AUTH}" ] ; then
        xcrun notarytool submit --wait ${NOTARYTOOL_AUTH} --team-id "${CODESIGN_ASC_PROVIDER}" "${PKG}"
        xcrun stapler staple "${PKG}"

        # Check the disk image with:
        # spctl --assess --type open --context context:primary-signature --verbose "${PKG}"
    fi
}

do_dist() {
    PKG="${BASE_DIR}"/XQuartz-${APPLICATION_VERSION_STRING}.pkg
    SYM_TARBALL="${BASE_DIR}"/XQuartz-${APPLICATION_VERSION_STRING}.dSYMS.tar.bz2

    openssl sha256 "${PKG}" > "${PKG}".sha256sum
    openssl sha512 "${PKG}" > "${PKG}".sha512sum

    openssl sha256 "${SYM_TARBALL}" > "${SYM_TARBALL}".sha256sum
    openssl sha512 "${SYM_TARBALL}" > "${SYM_TARBALL}".sha512sum

    if [ -f "${BASE_DIR}"/pkg/github.user -a "${BASE_DIR}"/pkg/github.token ] ; then
        local gh_user="$(cat "${BASE_DIR}"/pkg/github.user)"
        local gh_token="$(cat "${BASE_DIR}"/pkg/github.token)"
        local gh_project=XQuartz
        local gh_repo=XQuartz

        local tag=XQuartz-${APPLICATION_VERSION_STRING}
        local prerelease="false"
        if [ "${tag}" != "${tag/alpha/}" ] || [ "${tag}" != "${tag/beta/}" ] || [ "${tag}" != "${tag/rc/}" ] ; then
            prerelease="true"
        fi

        # https://docs.github.com/en/rest/reference/repos#create-a-release
        git tag -a ${tag} -m ${tag}
        git push -f origin ${tag}
        response=$(curl -i -u ${gh_user}:${gh_token} \
            -d "{ \
                \"tag_name\": \"${tag}\", \
                \"name\": \"${tag}\", \
                \"body\": \"See https://www.xquartz.org/releases/${tag}.html\", \
                \"prerelease\": ${prerelease}, \
                \"draft\": true \
            }" \
            https://api.github.com/repos/${gh_project}/${gh_repo}/releases)

        # Get ID
        eval $(echo "$response" | grep -m 1 "id.:" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')
        if [ -z "$id" ] ; then
            echo "${response}" >&2
            die "Error: Failed to get release id for tag: $tag"
        fi

        local tmpfile=$(mktemp)

        for f in "${PKG}"* "${SYM_TARBALL}"* ; do
            echo "Uploading ${f}"

            GH_ASSET_URL="https://uploads.github.com/repos/${GH_PROJECT}/${GH_REPO}/releases/${id}/assets?name=$(basename ${f})"
            if ! curl -i -u ${gh_user}:${gh_token} \
                    -o ${tmpfile} \
                    --progress-bar \
                    --data-binary @${f} \
                    -H "Content-Type: application/octet-stream" \
                    https://uploads.github.com/repos/${gh_project}/${gh_repo}/releases/${id}/assets?name=$(basename ${f}) ; then
                cat ${tmpfile} >&2
                die "Failed to upload $(basename ${f})."
            fi

            # The response printed by curl has no newline, so add it here
            echo ""
        done

        rm ${tmpfile}

        echo "Visit https://github.com/${gh_project}/${gh_repo}/releases to review / publish the release."
    fi

    if [ -f "${BASE_DIR}"/pkg/sparkle_dsa_priv.pem -a -f "${BASE_DIR}"/pkg/sparkle_eddsa_priv.key ] ; then
        ED_SIG_AND_SIZE=$(${BUILD_TOOLS_PREFIX_STD}/bin/sign_update -f "${BASE_DIR}"/pkg/sparkle_eddsa_priv.key "${PKG}")

        echo "      <item>"
        echo "         <sparkle:minimumSystemVersion>${MACOSX_DEPLOYMENT_TARGET}</sparkle:minimumSystemVersion>"
        echo "         <title>XQuartz-${APPLICATION_VERSION_STRING}</title>"
        echo "         <sparkle:releaseNotesLink>https://www.xquartz.org/releases/bare/XQuartz-${APPLICATION_VERSION_STRING}.html</sparkle:releaseNotesLink>"
        echo "         <pubDate>$(date -u +"%a, %d %b %Y %T %Z")</pubDate>"
        echo "         <enclosure url=\"https://github.com/XQuartz/XQuartz/releases/download/XQuartz-${APPLICATION_VERSION_STRING}/XQuartz-${APPLICATION_VERSION_STRING}.pkg\" sparkle:version=\"${APPLICATION_VERSION}\" sparkle:shortVersionString=\"XQuartz-${APPLICATION_VERSION_STRING}\" type=\"application/octet-stream\" ${ED_SIG_AND_SIZE} sparkle:installationType=\"package\" />"
        echo "      </item>"
    fi

    echo "Commits For the release page:"
    cd "${BASE_DIR}"
    git submodule | egrep -v '(libXt-flatnamespace|xorg/test|Sparkle2x)' | sed 's: *\(.*\) src/\(.*\) (\(.*\)):  * \2 \3 (\1):'
}

if [ -d ${BUILD_TOOLS_PREFIX_STD}/share/pkgconfig -o -d ${BUILD_TOOLS_PREFIX_STD}/lib/pkgconfig -o
     -d ${BUILD_TOOLS_PREFIX_CMAKE}/share/pkgconfig -o -d ${BUILD_TOOLS_PREFIX_CMAKE}/lib/pkgconfig ] ; then
    die "Ensure that these directories don't exist as they can interfere with the build:
${BUILD_TOOLS_PREFIX_STD}/share/pkgconfig
${BUILD_TOOLS_PREFIX_STD}/lib/pkgconfig
${BUILD_TOOLS_PREFIX_CMAKE}/share/pkgconfig
${BUILD_TOOLS_PREFIX_CMAKE}/lib/pkgconfig"
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
    sudo install -o root -g wheel -m 0755 -d ${DESTDIR}${SANITIZER_LIB_DIR}
    sudo install -o root -g wheel -m 0755 -d ${SANITIZER_LIB_DIR}

    for dylib in ${SANITIZER_LIBS} ; do
        sudo install -o root -g wheel -m 0755 ${SANITIZER_LIB_DIR_SRC}/${dylib} ${DESTDIR}${SANITIZER_LIB_DIR}
        sudo install -o root -g wheel -m 0755 ${SANITIZER_LIB_DIR_SRC}/${dylib} ${SANITIZER_LIB_DIR}
    done
fi

# Build Sparkle
cd ${BASE_DIR}/src/Sparkle
do_patches ${BASE_DIR}/src/Sparkle.patches
xcodebuild install -configuration Release \
    ARCHS="${ARCHS_BIN}" \
    DSTROOT="${DESTDIR}.Sparkle" \
    INSTALL_PATH="${APPLICATION_PATH}/XQuartz.app/Contents/Frameworks" \
    DYLIB_INSTALL_NAME_BASE="@executable_path/../Frameworks" \
    MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET}" \
    DEAD_CODE_STRIPPING=NO \
    GCC_GENERATE_DEBUGGING_SYMBOLS=YES

sudo ditto ${DESTDIR}.Sparkle ${DESTDIR}
sudo ditto ${DESTDIR}.Sparkle /

# Bincompat versions of libpng
do_autotools_build src/libpng/libpng12 LIB_BINCOMPAT_2_7
do_autotools_build src/libpng/libpng14 LIB_BINCOMPAT_2_7
do_autotools_build src/libpng/libpng15 LIB_BINCOMPAT_2_7
sudo rm -f {${DESTDIR}${PREFIX},${PREFIX}}/bin/libpng*-config
sudo rm -f {${DESTDIR}${PREFIX},${PREFIX}}/lib/libpng1?.dylib
sudo rm -f {${DESTDIR}${PREFIX},${PREFIX}}/lib/libpng12.0.*.dylib
sudo rm -f {${DESTDIR}${PREFIX},${PREFIX}}/lib/libpng.3.*.0.dylib

do_autotools_build src/libpng/libpng16 LIB

do_meson_build src/freetype2 LIB
do_meson_build src/pixman LIB

do_meson_build src/fontconfig LIB

do_autotools_build src/xorg/util/macros BIN

do_autotools_build src/xorg/doc/xorg-docs BIN
do_autotools_build src/xorg/doc/xorg-sgml-doctools BIN

do_meson_build src/xorg/proto/xorgproto BIN
do_autotools_build src/xorg/proto/xcbproto BIN

do_autotools_build src/xorg/util/bdftopcf BIN
do_autotools_build src/xorg/util/lndir BIN

do_autotools_build src/xorg/font/util LIB

do_autotools_build src/xorg/lib/libxtrans LIB
do_autotools_build src/xorg/lib/pthread-stubs LIB

do_autotools_build src/xorg/lib/libXau LIB

do_autotools_build src/xorg/lib/libxcb LIB
do_autotools_build src/xorg/lib/libxcb-util LIB
do_autotools_build src/xorg/lib/libxcb-render-util LIB
do_autotools_build src/xorg/lib/libxcb-image LIB
do_autotools_build src/xorg/lib/libxcb-cursor LIB
do_autotools_build src/xorg/lib/libxcb-errors LIB
do_autotools_build src/xorg/lib/libxcb-keysyms LIB
do_autotools_build src/xorg/lib/libxcb-wm LIB

do_autotools_build src/xorg/lib/libXdmcp LIB
do_autotools_build src/xorg/lib/libX11 LIB
do_autotools_build src/xorg/lib/libXext LIB
do_autotools_build src/xorg/lib/libAppleWM LIB
do_autotools_build src/xorg/lib/libdmx LIB
do_autotools_build src/xorg/lib/libfontenc LIB
do_autotools_build src/xorg/lib/libxshmfence LIB
do_autotools_build src/xorg/lib/libFS LIB
do_autotools_build src/xorg/lib/libICE LIB
do_autotools_build src/xorg/lib/libSM LIB

# Bincompat
do_autotools_build src/xorg/lib/libXt-flatnamespace LIB_BINCOMPAT_2_7
do_autotools_build src/xorg/lib/libXt7-stub LIB_BINCOMPAT_2_7
sudo install -o root -g wheel -m 0755 -d ${DESTDIR}${PREFIX}/lib/flat_namespace
sudo mv ${DESTDIR}${PREFIX}/lib/libXt.6.dylib ${DESTDIR}${PREFIX}/lib/flat_namespace
sudo install -o root -g wheel -m 0755 -d ${PREFIX}/lib/flat_namespace
sudo mv ${PREFIX}/lib/libXt.6.dylib ${PREFIX}/lib/flat_namespace

do_autotools_build src/xorg/lib/libXt LIB
do_autotools_build src/xorg/lib/libXmu LIB
do_autotools_build src/xorg/lib/libXpm LIB

# Bincompat
do_autotools_build src/xorg/lib/libXaw8 LIB_BINCOMPAT_2_7

do_autotools_build src/xorg/lib/libXaw LIB
do_autotools_build src/xorg/lib/libXaw3d LIB
do_autotools_build src/xorg/lib/libXfixes LIB
do_autotools_build src/xorg/lib/libXcomposite LIB
do_autotools_build src/xorg/lib/libXrender LIB
do_autotools_build src/xorg/lib/libXdamage LIB
do_autotools_build src/xorg/lib/libXcursor LIB
do_autotools_build src/xorg/lib/libXfont LIB
do_autotools_build src/xorg/lib/libXfont2 LIB
do_autotools_build src/xorg/lib/libXxf86vm LIB
do_autotools_build src/xorg/lib/libXft LIB
do_autotools_build src/xorg/lib/libXi LIB
do_autotools_build src/xorg/lib/libXinerama LIB
do_autotools_build src/xorg/lib/libxkbfile LIB
do_autotools_build src/xorg/lib/libXrandr LIB
do_autotools_build src/xorg/lib/libXpresent LIB
do_autotools_build src/xorg/lib/libXres LIB
do_autotools_build src/xorg/lib/libXScrnSaver LIB
do_autotools_build src/xorg/lib/libXtst LIB
do_autotools_build src/xorg/lib/libXv LIB
do_meson_build src/xorg/lib/libXvMC LIB
do_meson_build src/xorg/lib/libxcvt LIB

# Bincompat
do_autotools_build src/xorg/lib/libxkbui LIB_BINCOMPAT_2_7
do_autotools_build src/xorg/lib/libXp LIB_BINCOMPAT_2_7
do_autotools_build src/xorg/lib/libXevie LIB_BINCOMPAT_2_7
do_autotools_build src/xorg/lib/libXfontcache LIB_BINCOMPAT_2_7
do_autotools_build src/xorg/lib/libXTrap LIB_BINCOMPAT_2_7
do_autotools_build src/xorg/lib/libXxf86misc LIB_BINCOMPAT_2_7

do_autotools_build src/xorg/data/bitmaps BIN

do_autotools_build src/xorg/app/appres BIN
do_autotools_build src/xorg/app/beforelight BIN
do_autotools_build src/xorg/app/bitmap BIN
do_autotools_build src/xorg/app/editres BIN
do_autotools_build src/xorg/app/fonttosfnt BIN
do_autotools_build src/xorg/app/fslsfonts BIN
do_autotools_build src/xorg/app/fstobdf BIN
do_autotools_build src/xorg/app/iceauth BIN
do_autotools_build src/xorg/app/ico BIN
do_autotools_build src/xorg/app/listres BIN
do_autotools_build src/xorg/app/luit BIN
do_autotools_build src/xorg/app/mkfontscale BIN
do_autotools_build src/xorg/app/oclock BIN
do_autotools_build src/xorg/app/quartz-wm BIN
do_autotools_build src/xorg/app/rgb BIN
do_autotools_build src/xorg/app/sessreg BIN
do_autotools_build src/xorg/app/setxkbmap BIN
do_autotools_build src/xorg/app/showfont BIN
do_autotools_build src/xorg/app/smproxy BIN
do_autotools_build src/xorg/app/twm BIN
do_autotools_build src/xorg/app/viewres BIN
do_autotools_build src/xorg/app/xauth BIN
do_autotools_build src/xorg/app/xbacklight BIN
do_autotools_build src/xorg/app/xcalc BIN
do_autotools_build src/xorg/app/xclipboard BIN
do_autotools_build src/xorg/app/xclock BIN
do_autotools_build src/xorg/app/xcmsdb BIN
do_autotools_build src/xorg/app/xcompmgr BIN
do_autotools_build src/xorg/app/xconsole BIN
do_autotools_build src/xorg/app/xcursorgen BIN
do_autotools_build src/xorg/app/xditview BIN
do_autotools_build src/xorg/app/xdm BIN
do_autotools_build src/xorg/app/xdpyinfo BIN
do_autotools_build src/xorg/app/xedit BIN
do_autotools_build src/xorg/app/xev BIN
do_autotools_build src/xorg/app/xeyes BIN
do_autotools_build src/xorg/app/xfd BIN
do_autotools_build src/xorg/app/xfontsel BIN
do_autotools_build src/xorg/app/xfs BIN
do_autotools_build src/xorg/app/xfsinfo BIN
do_autotools_build src/xorg/app/xgamma BIN
do_autotools_build src/xorg/app/xgc BIN
do_autotools_build src/xorg/app/xhost BIN
do_autotools_build src/xorg/app/xinit BIN
do_autotools_build src/xorg/app/xinput BIN
do_autotools_build src/xorg/app/xkbcomp BIN
do_autotools_build src/xorg/app/xkbevd BIN
do_autotools_build src/xorg/app/xkbprint BIN
do_autotools_build src/xorg/app/xkbutils BIN
do_autotools_build src/xorg/app/xkill BIN
do_autotools_build src/xorg/app/xload BIN
do_autotools_build src/xorg/app/xlogo BIN
do_autotools_build src/xorg/app/xlsatoms BIN
do_autotools_build src/xorg/app/xlsclients BIN
do_autotools_build src/xorg/app/xlsfonts BIN
do_autotools_build src/xorg/app/xmag BIN
do_autotools_build src/xorg/app/xman BIN
do_autotools_build src/xorg/app/xmessage BIN
do_autotools_build src/xorg/app/xmh BIN
do_autotools_build src/xorg/app/xmodmap BIN
do_autotools_build src/xorg/app/xmore BIN
do_autotools_build src/xorg/app/xpr BIN
do_autotools_build src/xorg/app/xprop BIN
do_autotools_build src/xorg/app/xrandr BIN
do_autotools_build src/xorg/app/xrdb BIN
do_autotools_build src/xorg/app/xrefresh BIN
do_autotools_build src/xorg/app/xscope BIN
do_autotools_build src/xorg/app/xset BIN
do_autotools_build src/xorg/app/xsetmode BIN
do_autotools_build src/xorg/app/xsetpointer BIN
do_autotools_build src/xorg/app/xsetroot BIN
do_autotools_build src/xorg/app/xsm BIN
do_autotools_build src/xorg/app/xstdcmap BIN
do_autotools_build src/xorg/app/xvinfo BIN
do_autotools_build src/xorg/app/xwd BIN
do_autotools_build src/xorg/app/xwininfo BIN
do_autotools_build src/xorg/app/xwud BIN

do_autotools_build src/xterm BIN

do_autotools_build src/xorg/data/cursors LIB

do_autotools_build src/xorg/font/encodings LIB
do_autotools_build src/xorg/font/adobe-100dpi LIB
do_autotools_build src/xorg/font/adobe-75dpi LIB
do_autotools_build src/xorg/font/adobe-utopia-100dpi LIB
do_autotools_build src/xorg/font/adobe-utopia-75dpi LIB
do_autotools_build src/xorg/font/adobe-utopia-type1 LIB
do_autotools_build src/xorg/font/alias LIB
do_autotools_build src/xorg/font/arabic-misc LIB
do_autotools_build src/xorg/font/bh-100dpi LIB
do_autotools_build src/xorg/font/bh-75dpi LIB
do_autotools_build src/xorg/font/bh-lucidatypewriter-100dpi LIB
do_autotools_build src/xorg/font/bh-lucidatypewriter-75dpi LIB
do_autotools_build src/xorg/font/bh-ttf LIB
do_autotools_build src/xorg/font/bh-type1 LIB
do_autotools_build src/xorg/font/bitstream-100dpi LIB
do_autotools_build src/xorg/font/bitstream-75dpi LIB
do_autotools_build src/xorg/font/bitstream-speedo LIB
do_autotools_build src/xorg/font/bitstream-type1 LIB
do_autotools_build src/xorg/font/cronyx-cyrillic LIB
do_autotools_build src/xorg/font/cursor-misc LIB
do_autotools_build src/xorg/font/daewoo-misc LIB
do_autotools_build src/xorg/font/dec-misc LIB
do_autotools_build src/xorg/font/ibm-type1 LIB
do_autotools_build src/xorg/font/isas-misc LIB
do_autotools_build src/xorg/font/jis-misc LIB
do_autotools_build src/xorg/font/micro-misc LIB
do_autotools_build src/xorg/font/misc-cyrillic LIB
do_autotools_build src/xorg/font/misc-ethiopic LIB
do_autotools_build src/xorg/font/misc-meltho LIB
do_autotools_build src/xorg/font/misc-misc LIB
do_autotools_build src/xorg/font/mutt-misc LIB
do_autotools_build src/xorg/font/schumacher-misc LIB
do_autotools_build src/xorg/font/screen-cyrillic LIB
do_autotools_build src/xorg/font/sony-misc LIB
do_autotools_build src/xorg/font/sun-misc LIB
do_autotools_build src/xorg/font/winitzki-cyrillic LIB
do_autotools_build src/xorg/font/xfree86-type1 LIB

do_meson_build src/mesa/mesa LIB
do_meson_build src/mesa/glu LIB
do_cmake_build src/freeglut LIB

# Manually build glxinfo and glxgears
setup_environment ${ARCHS_BIN}
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

do_meson_build src/cairo LIB

do_meson_build src/xkeyboard-config LIB

do_meson_build src/xorg/xserver BIN
do_autotools_build src/xorg/driver/xf86-input-void BIN
do_autotools_build src/xorg/driver/xf86-video-dummy BIN
do_autotools_build src/xorg/driver/xf86-video-nested BIN

do_meson_build src/xquartz/xserver BIN

# We want X to be Xquartz by default
sudo rm -f ${DESTDIR}${PREFIX}/bin/X
sudo ln -s Xquartz ${DESTDIR}${PREFIX}/bin/X
sudo rm -f ${PREFIX}/bin/X
sudo ln -s Xquartz ${PREFIX}/bin/X

# TODO: Do we want to do anything with the tests?
#do_meson_build src/xorg/test/rendercheck BIN
#do_autotools_build src/xorg/test/x11perf BIN
#do_autotools_build src/xorg/test/xhiv BIN
#do_autotools_build src/xorg/test/xorg-gtest BIN
#do_autotools_build src/xorg/test/xorg-integration-tests BIN
#do_meson_build src/xorg/test/xts BIN
#do_meson_build src/xorg/test/xtsttopng BIN

do_remove_legacy_protos

do_checks

do_strip_sign_dsyms
do_sym_tarball
do_pkg

set +x

if ! has i386 ${ARCHS_LIB} ; then
    echo "Skipping notarization and distribution due to lack of i386 SDK"
    exit 0
fi

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

#!/bin/sh

usage() {
    cat <<EOF
Usage: ${0##*/} [--submodules-only]

With no arguments, performs a full clean: uninstalls XQuartz, removes build
products/packages, and resets all submodules to a pristine state.

  --submodules-only   Only clean the submodule working trees (drop applied
                      patches, remove build dirs and untracked cruft, and
                      reset the patch 'applied' markers so patches reapply on
                      the next build). Does NOT uninstall XQuartz or touch
                      products/packages.
EOF
}

submodules_only=0
case "$1" in
    --submodules-only) submodules_only=1 ;;
    -h|--help) usage; exit 0 ;;
    "") ;;
    *) usage; exit 1 ;;
esac

clean_submodules() {
    git submodule foreach --recursive "git checkout -f"
    git submodule foreach --recursive "rm -rf build.arm64 build.x86_64 build.i386"
    git submodule foreach --recursive "git clean -d -f"
    find . -name applied -exec rm {} \;
    git submodule update
    git submodule foreach --recursive "git submodule update"
    git submodule foreach --recursive "git clean -d -f"
}

if [ "$submodules_only" -eq 1 ] ; then
    clean_submodules
    exit 0
fi

sudo rm -rf /Applications/Utilities/XQuartz.app /opt/X11
sudo rm -rf products
rm -rf XQuartz-*.d*
rm -rf XQuartz-*.pkg*
sudo rm -rf src/Sparkle/build
clean_submodules
git clean -d -f

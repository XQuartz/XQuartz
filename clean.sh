sudo rm -rf /Applications/Utilities/XQuartz.app /opt/X11 $TMPDIR/XQuartz.dest*
git submodule foreach --recursive git checkout -f
git submodule foreach --recursive git clean -d -f
find . -name applied -exec rm {} \;
git clean -d -f

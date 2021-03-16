sudo rm -rf /Applications/Utilities/XQuartz.app /opt/X11
sudo rm -rf products
rm -rf XQuartz-*.d*
git submodule foreach --recursive git checkout -f
git submodule foreach --recursive git clean -d -f
sudo rm -rf src/Sparkle/build
sudo rm -rf src/mesa/mesa/build.*
find . -name applied -exec rm {} \;
git clean -d -f

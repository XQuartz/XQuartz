if [ -x /opt/X11/bin/xset ] ; then
        fontpath="/opt/X11/lib/X11/fonts/misc/,/opt/X11/lib/X11/fonts/TTF/,/opt/X11/lib/X11/fonts/OTF,/opt/X11/lib/X11/fonts/Type1/,/opt/X11/lib/X11/fonts/75dpi/:unscaled,/opt/X11/lib/X11/fonts/100dpi/:unscaled,/opt/X11/lib/X11/fonts/75dpi/,/opt/X11/lib/X11/fonts/100dpi/"

        [ -e "$HOME"/.fonts/fonts.dir ] && fontpath="$fontpath,$HOME/.fonts"
        [ -e "$HOME"/Library/Fonts/fonts.dir ] && fontpath="$fontpath,$HOME/Library/Fonts"
        [ -e /Library/Fonts/fonts.dir ] && fontpath="$fontpath,/Library/Fonts"
        [ -e /System/Library/Fonts/fonts.dir ] && fontpath="$fontpath,/System/Library/Fonts"

        /opt/X11/bin/xset fp= "$fontpath"
        unset fontpath
fi

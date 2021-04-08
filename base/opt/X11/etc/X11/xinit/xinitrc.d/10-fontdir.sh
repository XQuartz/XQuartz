if [ -x /opt/X11/bin/xset ] ; then
        fontpath="/opt/X11/share/fonts/misc/,/opt/X11/share/fonts/TTF/,/opt/X11/share/fonts/OTF,/opt/X11/share/fonts/Type1/,/opt/X11/share/fonts/75dpi/:unscaled,/opt/X11/share/fonts/100dpi/:unscaled,/opt/X11/share/fonts/75dpi/,/opt/X11/share/fonts/100dpi/,/opt/X11/share/system_fonts/"

        [ -e "$HOME"/.fonts/fonts.dir ] && fontpath="$fontpath,$HOME/.fonts"
        [ -e "$HOME"/Library/Fonts/fonts.dir ] && fontpath="$fontpath,$HOME/Library/Fonts"
        [ -e /Library/Fonts/fonts.dir ] && fontpath="$fontpath,/Library/Fonts"

        /opt/X11/bin/xset fp= "$fontpath"
        unset fontpath
fi

if [ -x /opt/X11/bin/xset ] ; then
    fontpath="/opt/X11/share/fonts/misc/,/opt/X11/share/fonts/TTF/,/opt/X11/share/fonts/OTF,/opt/X11/share/fonts/Type1/,/opt/X11/share/fonts/75dpi/:unscaled,/opt/X11/share/fonts/100dpi/:unscaled,/opt/X11/share/fonts/75dpi/,/opt/X11/share/fonts/100dpi/"

    fontpath="${fontpath},/opt/X11/share/system_fonts/"
    for subdir in /opt/X11/share/system_fonts/*/ ; do
        [ -e "${subdir}"/fonts.dir ] && fontpath="${fontpath},${subdir}"
    done

    [ -e "${HOME}"/.fonts/fonts.dir ] && fontpath="${fontpath},${HOME}/.fonts"

    if [ -e /Library/Fonts/fonts.dir ] ; then
        fontpath="${fontpath},/Library/Fonts"
        for subdir in /Library/Fonts/*/ ; do
            [ -e "${subdir}"/fonts.dir ] && fontpath="${fontpath},${subdir}"
        done
    fi

    if [ -e "${HOME}"/Library/Fonts/fonts.dir ] ; then
        fontpath="$fontpath,${HOME}/Library/Fonts"
        for subdir in "${HOME}"/Library/Fonts/*/ ; do
            [ -e "${subdir}"/fonts.dir ] && fontpath="${fontpath},${subdir}"
        done
    fi

    /opt/X11/bin/xset fp= "$fontpath"
    unset fontpath
fi

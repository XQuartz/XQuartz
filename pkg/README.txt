== Disclaimer ==

XQuartz is released by the open source XQuartz project.  While Apple Inc. is an active participant in this project, it should be noted that this is a community sponsored release and not an official Apple release.

== Important Notices ==

=== OS X Requirements ===

10.6.3, or later is required to install this package.

=== Default X11 Server ===

If this is your first time installing XQuartz, you may wish to logout and log back in.  This will update your DISPLAY environment variable to point to XQuartz.app rather than X11.app.  If you would prefer to keep using X11.app as your default server (you can still launch XQuartz.app manually), you'll want to disable /Library/LaunchAgents/org.macosforge.xquartz.startx.plist using launchctl(1).

== Changes in 2.7.11 ==
  * All changes in 2.7.10 plus:
  * lib:
    * fontconfig
      * Fix font caching (#97546)
    * libpng 1.6.26
    * libX11
      * Plug a memory leak
    * libXi 1.7.8
      * Plus fixes for a memory leak and improved error handling
    * mesa 12.0.1

== Changes in 2.7.10 ==
  * All changes in 2.7.9 plus:
  * app:
    * mkfontdir
      * Fix a buffer underrun crash (#96905)
    * quartz-wm
      * Properly handle updates to WM_PROTOCOLS property changes (#92652)
    * xinit
      * Fixed support for enabling TCP server connections (#95379)
      * Added support for enabling IGLX (#96260)
        * defaults write org.macosforge.xquartz.X11 enable_iglx -bool true
    * xterm 326
  * proto:
    * xcb-proto 1.12
    * xproto 7.0.31
  * lib:
    * fontconfig 2.12.1
      * CVE-2016-5384
    * freetype 2.7
    * libpng 1.5.27
    * libpng 1.6.25
    * libxcb 1.12
    * libX11 1.6.4
    * libXfixes 5.0.3
    * libXfont 1.5.2
      * Fix a buffer overrun (#83224)
    * libXfont2
      * Fix a buffer overrun (#83224)
    * libXi 1.7.7
    * libXrandr 1.5.1
    * libXrender 0.9.10
    * libXt
      * libXt.6.dylib is now a two-level-namespace dylib
      * libXt.7.dylib is now a stub dylib that re-exports libXt.6.dylib (for binary compatibility with anything built against XQuartz 2.7.9)
      * A flat_namespace version of libXt is available in /opt/X11/lib/flat_namespace to help ease the transition (#96292)
         * Set DYLD_LIBRARY_PATH=/opt/X11/lib/flat_namespace when executing older non-compliant software (eg: Motif-based applications)
         * Motif users are encouraged to file bugs against Motif to encourage them to fix that library.
    * libXtst 1.2.3
    * libXv 1.0.11
      * CVE-2016-5407
    * libXvMC 1.0.10
    * mesa 11.2.2
    * xcb-util-cursor 0.1.3
  * server:
    * xorg-server 1.18.4 plus other patches
      * Fix the issue where the h key could be come "stuck" after hiding XQuartz with cmd-h (#92648)

== Changes in 2.7.9 ==
  * All changes in 2.7.8 plus:
  * app:
    * glxgears 8.3.0
    * glxinfo 8.3.0
    * quartz-wm 1.3.2
    * xkbcomp 1.3.1
    * xinput 1.6.2
    * xrandr 1.5.0
    * xterm 324
  * lib:
    * cairo 1.14.6
    * freetype 2.6.3
    * libpng 1.2.56
    * libpng 1.4.19
    * libpng 1.5.26
    * libpng 1.6.21
      * CVE-2015-7981
      * CVE-2015-8126
      * CVE-2015-8540
    * libXaw
      * Remove incorrect export of vendorShellClassRec and vendorShellWidgetClass
    * libXaw3D
      * Remove incorrect export of vendorShellClassRec and vendorShellWidgetClass
    * libXfont2 2.0.1
    * libXi 1.7.6
    * libXplugin
      * Worked around an El Capitan regression that would cause OpenGL widgets to sometimes remain visible (#93318)
    * libXt
      * No longer linked with -flat_namespace
      * Binary compatibility maintained for existing clients of libXt.6.dylib
    * pixman 0.34.0
    * xcb-util-keysyms 0.4.0
  * proto:
    * inputproto 2.3.2
    * videoproto 2.3.3
  * server:
    * xorg-server 1.17.4 plus other patches

== Changes in 2.7.8 ==
  * All changes in 2.7.7 plus:
  * app:
    * bdtopcf 1.0.5
    * bitmap 1.0.8
    * fslsfonts 1.0.5
    * fstobdf 1.0.6
    * iceauth 1.0.7
    * mkfontscale 1.1.2
    * rgb 1.0.6
    * sessreg 1.1.0
    * setxkbmap 1.3.1
    * showfont 1.0.5
    * smproxy 1.0.6
    * twm 1.0.9
    * x11perf 1.6.0
    * xauth
      * Fix support for Yosemite launchd socket (#2068)
    * xcalc 1.0.6
    * xcmsdb 1.0.5
    * xcompmgr 1.1.7
    * xdpyinfo 1.3.2
    * xditview 1.0.4
    * xedit 1.2.2
    * xev 1.2.2
    * xfindproxy 1.0.4
    * xfs 1.1.4
    * xfsinfo 1.0.5
    * xgamma 1.0.6
    * xgc 1.0.5
    * xhost 1.0.7
    * xinit 1.3.4
    * xkbcomp 1.3.0
    * xkbevd 1.1.4
    * xkbprint 1.0.4
    * xlsatoms 1.1.2
    * xlsfonts 1.0.5
    * xmag 1.0.6
    * xman 1.1.4
    * xmh 1.0.3
    * xmodmap 1.0.9
    * xterm 314
    * xvinfo 1.1.3
  * lib:
    * cairo 1.14.2
    * freetype 2.6.1
      * CVE-2014-2240
      * CVE-2014-9656
      * CVE-2014-9657
      * CVE-2014-9658
      * CVE-2014-9661
      * CVE-2014-9662
      * CVE-2014-9663
      * CVE-2014-9664
      * CVE-2014-9665
      * CVE-2014-9666
      * CVE-2014-9668
      * CVE-2014-9670
      * CVE-2014-9671
      * CVE-2014-9672
      * CVE-2014-9673
      * CVE-2014-9674
      * CVE-2014-9675
    * glu 9.0.0
    * libfontenc 1.1.3
    * libFS 1.0.7
    * libpng 1.2.53
    * libpng 1.4.16
    * libpng 1.5.23
      * CVE-2014-9495
    * libX11 1.6.3
    * libXaw 1.0.13
    * libxcb 1.11.1
    * libXdmcp 1.1.2
    * libXfont 1.5.1
      * CVE-2015-1802
      * CVE-2015-1803
      * CVE-2015-1804
    * libXi 1.7.5
    * libxkbfile 1.0.9
    * libXp 1.0.3
    * libXpresent 1.0.0
    * libXrandr 1.5.0
    * libXrender 0.9.9
    * libxshmfence 1.2
    * libXt 1.1.5
    * libXvMC 1.0.9
    * libXxf86vm 1.1.4
    * mesa 11.0.3
      * Fixes GLhandleARB declaration (#858)
    * pixman 0.32.8
    * xcb-util 0.4.0
    * xcb-util-cursor 0.1.2
    * xcb-util-errors 1.0
    * xcb-util-image 0.4.0
    * xcb-util-keysyms 0.4.0
    * xtrans 1.3.5
  * misc:
    * font-util 1.3.1
    * Sparkle 1.6.1
      * Fix the "This update is locked with a password." issue with auto-updates.
        * Note that this bug is fixed for updates FROM 2.7.8_beta2 or later.  Updating from 2.7.7_rc1 through 2.7.8_beta1 may encounter this bug.
    * xorg-docs 1.7.1
  * proto:
    * fontsproto 2.1.3
    * kbproto 1.0.7
    * randrproto 1.5.0
    * xproto 7.0.28
  * server:
    * xf86-input-void 1.4.1
    * xorg-server 1.16.4 plus other patches
      * CVE-2014-8091
      * CVE-2014-8092
      * CVE-2014-8093
      * CVE-2014-8094
      * CVE-2014-8095
      * CVE-2014-8096
      * CVE-2014-8097
      * CVE-2014-8098
      * CVE-2014-8099
      * CVE-2014-8100
      * CVE-2014-8101
      * CVE-2014-8102
      * CVE-2014-8103
      * CVE-2015-0255

== Changes in 2.7.7 ==
  * All changes in 2.7.6 plus:
  * app:
    * xcursorgen 1.0.6
    * xrandr 1.4.3
    * xscope 1.4.1
    * xterm 309
  * lib:
    * cairo 1.12.16
    * libICE 1.0.9
    * libxcb 1.11
    * libXext 1.3.3
    * libXft 2.3.2
    * libXi 1.7.4
    * pixman 0.32.6
    * xcb-util-renderutil 0.3.9
  * proto:
    * glproto 1.4.17
    * inputproto 2.3.1
    * xcb-proto 1.11
  * server:
    * xorg-server 1.15.2 plus other patches
      * Fixes multimonitor support on Mavericks (#832, #1876)
      * Fix Xephyr "failed to create root window" bug (#822)
      * Fix a crash resulting from a rare race condition in fd handoff (#869)

== Changes in 2.7.6 ==
  * All changes in 2.7.5 plus:
  * app:
    * xauth 1.0.9
    * xbacklight 1.2.1
    * xrandr 1.4.2
    * xterm 303
  * proto:
    * presentproto 1.0
    * dri3proto 1.0
    * xcb-proto 1.10
    * xextproto 7.3.0
    * xproto 7.0.26
  * lib:
    * fontconfig 2.11.1
    * freetype 2.5.3
      * CVE-2014-2240
    * libFS 1.0.6
    * libpng 1.2.51
    * libpng 1.4.13
    * libpng 1.5.18
    * libxcb 1.10
    * libXfont 1.4.8
      * CVE-2013-6462
      * CVE-2014-0209
      * CVE-2014-0210
      * CVE-2014-0211
    * libxshmfence 1.1
    * pixman 0.32.4
    * xcb-util-cursor 0.1.1
    * xcb-util-wm 0.4.1
    * xtrans 1.3.4
  * misc:
    * util-macros 1.19.0
  * server:
    * xorg-server 1.14.6 plus other patches
      * Fix the deletion of display lock files (#823)

== Changes in 2.7.5 ==
  * All changes in 2.7.4 plus:
  * app:
    * appres 1.0.4
    * bitmap 1.0.7
    * iceauth 1.0.6
    * makedepend 1.0.5
    * mkfontscale 1.1.1
    * twm 1.0.8
    * xauth 1.0.8
    * xclipboard 1.1.3
    * xconsole 1.0.6
    * xclock 1.0.7
    * xdpyinfo 1.3.1
    * xfd 1.1.2
    * xfontsel 1.0.5
    * xfs 1.1.3
    * xhost 1.0.6
    * xinit 1.3.3
    * xinput 1.6.1
    * xkill 1.0.4
    * xload 1.1.2
    * xlsclients 1.1.3
    * xman 1.1.3
    * xmodmap 1.0.8
    * xprop 1.2.2
    * xrandr 1.4.1
    * xrdb 1.1.0
    * xrefresh 1.0.5
    * xset 1.2.3
    * xterm 297
    * xwd 1.0.6
    * xwininfo 1.1.3
  * proto:
    * inputproto 2.3
    * videoproto 2.3.2
    * xproto 7.0.24
    * xcb-proto 1.8
  * lib:
    * cairo 1.12.14
    * fontconfig 2.11.0
    * freeglut 2.8.1
    * freetype 2.5.0.1
    * libdmx 1.1.3
      * CVE-2013-1992
    * libfontenc 1.1.2
      * CVE-2013-19
    * libFS 1.0.5
      * CVE-2013-1996
    * libpng 1.5.17
    * libSM 1.2.2
    * libX11 1.6.2
      * CVE-2013-1981
      * CVE-2013-1997
      * CVE-2013-1981
      * CVE-2013-2004
    * libXau 1.0.8
    * libXaw 1.0.12
    * libxcb 1.9.1
      * CVE-2013-2064
      * Fixes a deadlock in wine (#696)
    * libXcursor 1.1.14
      * CVE-2013-2003
    * libXext 1.3.2
      * CVE-2013-1982
    * libXfixes 5.0.1
      * CVE-2013-1983
    * libXfont 1.4.6
    * libXi 1.7.2
      * CVE-2013-1984
      * CVE-2013-1995
      * CVE-2013-1998
    * libXinerama 1.1.3
      * CVE-2013-1985
    * libXmu 1.1.2
    * libXp 1.0.2
      * CVE-2013-2062
    * libXpm 3.5.11
    * libXrandr 1.4.2
      * CVE-2013-1986
    * libXrender 0.9.8
      * CVE-2013-1987
    * libXres 1.0.7
      * CVE-2013-1988
    * libXt 1.1.4
      * CVE-2013-2002
      * CVE-2013-2005
    * libXtst 1.1.2
      * CVE-2013-3063
    * libXv 1.0.10
    * libXxf86dga 1.1.4
      * CVE-2013-1991
      * CVE-2013-2000
    * libXxf86vm 1.1.3
      * CVE-2013-2001
    * libXv 1.0.8
      * CVE-2013-1989
      * CVE-2013-2066
    * libXvMC 1.0.8
      * CVE-2013-1999
    * pixman 0.30.2
  * misc:
    * util-macros 1.17.1
  * server:
    * xf86-video-dummy 0.3.7
    * xorg-server 1.14.4 plus other patches
      * Don't force discreet graphics (#654)
      * Removed support for 15bit visuals which no longer work in Mountain Lion (#633)
      * Fix a rendering regression seen in pixman by reverting to old rendering code paths (#525)
      * CVE-2013-4396

== Changes in 2.7.4 ==
  * All changes in 2.7.3 plus:
  * app:
    * xinit
      * Address a possible startup bug if a user is named "0" on the system (#637).
  * lib:
    * fontconfig 2.10.1
    * mesa 8.0.4
      * Fix an issue with GLX pixmaps (#536) plaguing wine
  * server:
    * xf86-video-dummy 0.3.6
    * xorg-server 1.13.0 plus other patches
      * Workaround for a deadlock issue plaguing wine on OS X 10.7.5 and 10.8.2 (wine bug #31751, #649)

== Changes in 2.7.3 ==
  * All changes in 2.7.2 plus:
  * app:
    * xinit
      * Fixed an issue with the dpi preference (#600)
    * xterm 281
  * proto:
    * dri2proto 2.8
    * glproto 1.4.16
    * randrproto 1.4.0
  * lib:
    * libpng 1.2.50
    * libpng 1.4.11
    * libpng 1.5.10
    * libX11 1.5.0
    * libXaw 1.0.11
    * libXft 2.3.1
    * libXplugin
      * Work around menu bar bug on Mountain Lion (#607)
      * Don't accidentally switch spaces on Mountain Lion (#610)
    * pixman 0.26.2
    * xcb-util 0.3.9
    * xcb-util-image 0.3.9
    * xcb-util-keyyms 0.3.9
    * xcb-util-wm 0.3.9
  * misc:
    * xorg-docs 1.7
    * xorg-sgml-doctools 1.11
  * pkg:
    * Set XAuthLocation in /etc/ssh_config and /etc/sshd_config, so ssh can find xauth (#619)
  * server:
    * Xvfb should once again work on Snow Leopard (#588)
    * xorg-server 1.12.4 plus other patches

== Changes in 2.7.2 ==
  * All changes in 2.7.1 plus:
  * app:
    * bitmap 1.0.6
    * fslsfonts 1.0.4
    * fstobdf 1.0.5
    * listres 1.0.3
    * luit 1.1.1
    * setxkbmap 1.3.0
    * quartz-wm 1.3.1
      * Plus a fix for a crash when minimizing windows without titles
    * xauth 1.0.7
    * xcmsdb 1.0.4
    * xcompmgr 1.1.6
    * xcursor 1.0.5
    * xev 1.2.0
    * xfd 1.1.1
    * xfs 1.1.2
    * xhost 1.0.5
    * xinput 1.6.0
    * xkbcomp 1.2.4
    * xfontsel 1.0.4
    * xgamma 1.0.5
    * xkbevd 1.1.3
    * xload 1.1.1
    * xlogo 1.0.4
    * xlsatoms 1.1.1
    * xlsfonts 1.0.4
    * xmodmap 1.0.7
    * xpr 1.0.4
    * xscope 1.3.1
    * xterm 278
    * xwd 1.0.5
    * xwud 1.0.4
  * lib:
    * cairo 1.12.2
    * freeglut 2.8.0
    * freetype 2.4.9
      * CVE-2012-1126
      * CVE-2012-1127
      * CVE-2012-1128
      * CVE-2012-1129
      * CVE-2012-1130
      * CVE-2012-1131
      * CVE-2012-1132
      * CVE-2012-1133
      * CVE-2012-1134
      * CVE-2012-1135
      * CVE-2012-1136
      * CVE-2012-1137
      * CVE-2012-1138
      * CVE-2012-1139
      * CVE-2012-1140
      * CVE-2012-1141
      * CVE-2012-1142
      * CVE-2012-1143
      * CVE-2012-1144
    * libdmx 1.1.2
    * libfontenc 1.1.1
    * libFS 1.0.4
    * libICE 1.0.8
    * libpng 1.2.49
    * libpng 1.4.11
    * libpng 1.5.10
      * CVE-2011-3026
      * CVE-2011-3045
      * CVE-2011-3048
    * libSM 1.2.1
    * libX11 1.4.99.901
    * libXau 1.0.7
    * libXaw 1.0.10
    * libXaw3d 1.6.2
    * libXcursor 1.1.13
    * libxcb 1.8.1
      * Plus a fix for xcb_connect incorrectly trying tcp on failure
    * libXdmcp 1.1.1
    * libXext 1.3.1
    * libXfont 1.4.5
    * libXft 2.3.0
      * Plus a fix for a bold font regression
    * libXi 1.6.1
    * libXinerama 1.1.2
    * libxkbfile 1.0.8
    * libXmu 1.1.1
    * libXpm 3.5.10
    * libXrender 0.9.7
    * libXres 1.0.6
    * libXScrnSaver 1.2.2
    * libXt 1.1.3
    * libXtst 1.2.1
    * libXv 1.0.7
    * libXvMC 1.0.7
    * libXxf86dga 1.1.3
    * libXxf86vm 1.1.2
    * mesa 8.0.3
      * Including fixes for two crashes, a memory leak, and regressions (#512, #575)
    * xpyb 1.3.1
    * xtrans 1.2.7
  * misc:
    * font-util 1.3.0
    * lndir 1.0.3
    * makedepend 1.0.4
    * util-macros 1.17
    * xorg-docs 1.6.99.901
    * xorg-sgml-doctools 1.10.99.901
  * proto:
    * bigreqsproto 1.1.2
    * fontsproto 2.1.2
    * kbproto 1.0.6
    * inputproto 2.2
    * recordproto 1.14.2
    * scrnsaverproto 1.2.2
    * xcb-proto 1.7.1
    * xcmiscproto 1.2.2
    * xextproto 7.2.1
    * xproto 7.0.23
  * pkg:
    * The installer and executables are now signed with an Apple DeveloperID for increased security.
      * You should be able to install it with Gatekeeper set to "Mac App Store and identified developers"
  * server:
    * xf86-input-void 1.4.0
    * xf86-video-dummy 0.3.5
    * xorg-server 1.12.2 plus other patches
      * Xfake, Xvfb, Xfake are now using the same server version as XQuartz
      * Xephyr is still using 1.6.5-apple3
      * Xorg binary is now installed as well, for use with the dummy, nested, or vnc drivers (experts only, not yet fully supported)
      * Improved support for Xi2 including sub-pixel resolution of valuators and smooth scrolling
      * Workaround a wine bug in mouse input
      * Address a race condition at startup that affects tablets and VMWare users (#579)

== Changes in 2.7.1 ==
  * All changes in 2.7.0 plus:
  * app:
    * mkfontdir 1.0.7
    * mkfontscale 1.1.0
    * oclock 1.0.3
    * quartz-wm 1.3.0
      * Fixes a possible crash when restoring from the dock (#538)
    * xclipboard 1.1.2
    * xclock 1.0.6
    * xinit 1.3.2
      * Fixed setting of $DISPLAY (Bug #523)
    * xinput 1.4.5
  * lib:
    * freetype 2.4.8
      * CVE-2011-3439
    * libpng-1.5.8
    * libXi 1.5.0
    * mesa 7.11.2
    * pixman 0.24.4
  * misc:
    * util-macros 1.16.1
  * proto:
    * glproto 1.4.15
    * inputproto 2.1
  * pkg
    * The installer should now allow downgrading to this release (Bug #532)
      * If you need to downgrade to 2.7.0, you should manually delete XQuartz.app first.
  * server:
    * xorg-server 1.11.4 plus other patches
      * While in fullscreen mode, hiding by using CMD-H now causes you to leave fullscreen mode first, as if by cmd-opt-a (Bug #478)
      * Release all mouse buttons when switching applications (Bug #486)

== Changes in 2.7.0 ==
  * All changes in 2.6.3 plus:
  * app:
    * mkfontscale 1.0.9
    * quartz-wm 1.2.99.901 (although it reports v 1.2.0)
      * Improved logging
      * Removed legacy pbproxy support
    * sessreg 1.0.7
    * smproxy 1.0.5
    * twm 1.0.7
    * x11perf 1.5.4
    * xdpyinfo 1.3.0
    * xinit 1.3.1
      * Improved logging for startx LaunchAgent and privileged_startx LaunchDaemon
    * xkbcomp 1.2.3
    * xlsclients 1.1.2
    * xman 1.1.2
    * xrandr 1.3.5
    * xprop 1.2.1
    * xset 1.2.2
    * xterm 276
    * xwininfo 1.1.2
  * lib:
    * freetype 2.4.7
      * CVE-2011-3256
    * libpng 1.5.5
      * CVE-2011-3328
    * libX11 1.4.4
    * libXext 1.3.0
    * libXfont 1.4.4
      * CVE-2011-2895
    * libXrandr 1.3.2
    * libXcursor 1.1.2
    * libXi 1.4.3
    * mesa 7.11
      * rewritten dispatch to use glapi, should be much more reliable and more consistent with other platforms
    * pixman 0.23.6
    * xcb-util 0.3.8
    * xcb-util-image 0.3.8
    * xcb-util-kysyms 0.3.8
    * xcb-util-renderutils 0.3.8
    * xcb-util-wm 0.3.8
  * misc:
    * util-macros 1.15.0
    * xorg-sgml-doctools 1.10
  * proto:
    * dri2proto 2.6
    * glproto 1.4.14
    * inputproto 2.0.2
    * resourceproto 1.2.0
    * xproto 7.0.22
  * server:
    * xorg-server 1.11.2 plus other patches
      * Initial support for GCD in the server to increase performance on multi-core systems
      * Improved logging
      * CVE-2011-4028
      * CVE-2011-4029
      * Fixed server side bug sending the AppleDRICreatePixmap request (#508)

== Changes in 2.6.3 ==
  * All changes in 2.6.2 plus:
  * app:
    * iceauth 1.0.5
      * Addresses an issue with home directories on AFP mount-points
    * quartz-wm 1.2.1
      * Improved initial placement of windows (#481)
      * Window sizes are bounded to the current display size rather than the initial display size (should improve fullscreen games at native resolution)
    * xauth 1.0.6
      * Addresses an issue with home directories on AFP mount-points
  * lib:
    * libpng-1.2.46
    * libpng-1.4.8
    * libpng-1.5.4
      * CVE-2011-2690
      * CVE-2011-2691
      * CVE-2011-2692
  * server:
    * xorg-server 1.10.3 plus other patches
      * Fixed a crash in RandR when resizing while displays are asleep (#463)
      * Fixed a crash in RandR when launching X11 while displays are asleep
      * Fixed a crash in rootless when resizing to a larger display
      * Fixed a possible race crash at shutdown

== Changes in 2.6.2 ==
  * All changes in 2.6.1 plus:
  * app:
    * quartz-wm 1.2.0
      * Window decoration / behavior code extensively rewritten
      * Fixed the handler for SIGTERM and SIGINT to not call non-reentrant functions
    * xrdb 1.0.9
      * CVE-2011-0465
  * lib:
    * libAppleWM 1.4.1
    * libX11 1.4.3
  * misc:
    * xorg-sgml-doctools 1.7
  * proto:
    * applewmproto 1.4.2
    * xproto 7.0.21
  * server:
    * xorg-server 1.10.1 plus other patches
      * Fixed an issue which could cause incorrect data to be proxied by pbproxy (#476)
      * Initial applications should have proper xrdb resources (#416)
      * Fixed a crash/corruption bug resulting from an incorrect offset in RootlessGlyphs

== Changes in 2.6.1 ==
  * All changes in 2.6.0 plus:
  * app:
    * twm 1.0.6
    * x11perf 1.5.3
    * xkbcomp 1.2.1
    * xrdb 1.0.8
    * xterm 269
  * lib:
    * cairo 1.10.2
      * enabled support for tee and XML surfaces
    * libpng 1.5.1
      * SDKs from previous releases are not provided, but binaries remain for ABI compatibility
    * libX11 1.4.2
      * Fixes some error handler issues with xcb (#469)
    * libXaw 1.0.9
    * libXfixes 5.0
    * libXi 1.4.1
    * libXp 1.0.1
    * libXt 1.1.1
    * pixman 0.20.2
  * misc:
    * util-macros 1.13.0
  * proto:
    * dmxproto 2.3.1
    * eviext 1.1.1
    * fixesproto 5.0
    * printproto 1.0.5
    * xf86driproto 2.1.1
    * xf86vidmodeproto 2.3.1
    * xineramaproto 1.2.1
  * server:
    * xorg-server 1.9.5 plus other patches
    * fixed monitor hot-swapping regression (#460)
    * Windows have the correct color profile when first created (#425)
    * Localization updates

== Changes in 2.6.0 ==
  * All changes in 2.5.3 plus:
  * app:
    * appres 1.0.3
    * bdftopcf 1.0.3
    * bitmap 1.0.5
    * editres 1.0.5
    * fslsfonts 1.0.3
    * fstobdf 1.0.4
    * iceauth 1.0.4
    * ico 1.0.3
    * lndir 1.0.2
    * luit 1.1.0
    * mkfontdir 1.0.6
    * mkfontscale 1.0.8
    * oclock 1.0.2
    * rgb 1.0.4
    * setxkbmap 1.2.0
    * showfont 1.0.3
    * smproxy 1.0.4
    * twm 1.0.5
    * viewres 1.0.3
    * x11perf 1.5.2
    * xauth 1.0.5
    * xbacklight 1.1.2
    * xcalc 1.0.4.1
    * xclipboard 1.1.1
    * xclock 1.0.5
    * xcmsdb 1.0.3
    * xconsole 1.0.4
    * xcursorgen 1.0.4
    * xdpyinfo 1.2.0
    * xedit 1.2.0
    * xev 1.1.0
    * xeyes 1.1.1
    * xfontsel 1.0.3
    * xfd 1.1.0
    * xfs 1.1.1
    * xfsinfo 1.0.3
    * xgamma 1.0.4
    * xgc 1.0.3
    * xhost 1.0.0
    * xinit 1.3.0
    * xinput 1.5.3
    * xkbcomp 1.2.0
    * xkbevd 1.1.2
    * xkbutils 1.0.3
    * xkill 1.0.3
    * xlogo 1.0.3
    * xlsclients 1.1.1
    * xload 1.1.0
    * xmag 1.0.4
    * xman 1.1.1
    * xmh 1.0.2
    * xmodmap 1.0.5
    * xprop 1.2.0
    * xrandr 1.3.4
    * xrdb 1.0.7
    * xrefresh 1.0.4
    * xscope 1.3
    * xset 1.2.1
    * xsetroot 1.1.0
    * xsm 1.0.2
    * xstdcmap 1.0.2
    * xterm 267
    * xvinfo 1.1.1
    * xwd 1.0.4
    * xwud 1.0.3
    * xwininfo 1.1.1
  * font:
    * encodings 1.0.4
    * font-adobe-100dpi 1.0.3
    * font-adobe-75dpi 1.0.3
    * font-adobe-utopia-100dpi 1.0.4
    * font-adobe-utopia-75dpi 1.0.4
    * font-adobe-utopia-type1 1.0.4
    * font-alias 1.0.3
    * font-arabic-misc 1.0.3
    * font-bh-100dpi 1.0.3
    * font-bh-75dpi 1.0.3
    * font-bh-lucidatypewriter-100dpi 1.0.3
    * font-bh-lucidatypewriter-75dpi 1.0.3
    * font-bh-ttf 1.0.3
    * font-bh-type1 1.0.3
    * font-bitstream-100dpi 1.0.3
    * font-bitstream-75dpi 1.0.3
    * font-bitstream-type1 1.0.3
    * font-cronyx-cyrillic 1.0.3
    * font-cursor-misc 1.0.3
    * font-daewoo-misc 1.0.3
    * font-dec-misc 1.0.3
    * font-ibm-type1 1.0.3
    * font-isas-misc 1.0.3
    * font-jis-misc 1.0.3
    * font-micro-misc 1.0.3
    * font-misc-cyrillic 1.0.3
    * font-misc-ethiopic 1.0.3
    * font-misc-meltho 1.0.3
    * font-misc-misc 1.1.2
    * font-mutt-misc 1.0.3
    * font-schumacher-misc 1.1.2
    * font-screen-cyrillic 1.0.4
    * font-sony-misc 1.0.3
    * font-sun-misc 1.0.3
    * font-winitzki-cyrillic 1.0.3
    * font-xfree86-type1 1.0.4
  * lib:
    * cairo 1.10.0
    * fontconfig 2.8.0
    * freetype 2.4.4
      * Addresses some font rendering regressions introduced by the freetype included in 2.5.2
      * CVE-2010-3814
      * CVE-2010-3855
    * libdmx 1.1.1
    * libfontenc 1.1.0
    * libkbfile 1.0.7
    * libFS 1.0.3
    * libICE 1.0.7
    * libpng 1.4.5
    * libSM 1.2.0
    * libX11 1.4.0
    * libXaw 1.0.8
    * libxcb 1.7
    * libXcomposite 0.4.3
    * libXcursor 1.1.11
    * libXdmcp 1.1.0
    * libXext 1.2.0
    * libXevie 1.0.3
    * libXfont 1.4.3
    * libXft 2.2.0
    * libXi 1.4.0
    * libXinerama 1.1.1
    * libXmu 1.1.0
    * libXpm 3.5.9
    * libXrandr 1.3.1
    * libXres 1.0.5
    * libXScrnSaver 1.2.1
    * libXt 1.0.9
    * libXtst 1.2.0
    * libXv 1.0.6
    * libXvMC 1.0.6
    * libXxf86dga 1.1.2
    * libXxf86misc 1.0.3
    * libXxf86vm 1.1.1
    * pixman 0.20.0
    * xtrans 1.2.6
  * misc:
    * makedepend 1.0.3
    * font-util 1.2.0
    * util-macros 1.11.0
    * xbitmaps 1.1.1
    * xkeyboard-config 2.0
    * xorg-docs 1.6
    * xorg-sgml-doctools 1.6
  * proto:
    * bigreqsproto 1.1.1
    * compositeproto 0.4.2
    * damageproto 1.2.1
    * fixesproto 4.1.2
    * fontsproto 2.1.1
    * inputproto 2.0.1
    * randrproto 1.3.2
    * recordproto 1.14.1
    * resourcesproto 1.1.1
    * scrnsaverproto 1.2.1
    * xproto 7.0.20
    * xcmiscproto 1.2.1
  * server:
    * xorg-server 1.9.3 plus other patches
      * Initial RandR support (#6)
      * Fullscreen mode disables the Mac OS screensaver
      * Localization Updates
      * CoreAudio path for XBell() removed in favor of always using NSBell()

== Changes in 2.5.3 ==
  * All changes in 2.5.2 plus:
  * app:
    * quartz-wm 1.1.2
      * Addresses an issue where quartz-wm would not release the KB if there were no meta keys in the modmap (#427)
    * xditview 1.0.2
    * xmore 1.0.2
    * xrandr 1.3.3
    * xset 1.2.0
  * lib:
    * freetype 2.4.2
      * CVE-2010-1797
      * CVE-2010-2805
      * CVE-2010-2806
      * CVE-2010-2807
      * CVE-2010-2808
    * libX11 1.3.5
    * libXi 1.3.2
  * proto:
    * kbproto 1.0.5
    * glproto 1.4.12
    * renderproto 0.11.1
    * videoproto 2.3.1
    * xproto 7.0.18
    * xextproto 7.1.2
  * server:
    * xorg-server 1.8.2 plus other patches
      * Finish cleanup of /tmp on server quit (#421)
      * Address an indirect GLX regressions introduced in 2.5.1 (#423, #426)

== Changes in 2.5.2 ==
  * All changes in 2.5.1 plus:
  * lib:
    * freetype 2.4.1
      * CVE-2010-2497
      * CVE-2010-2498
      * CVE-2010-2499
      * CVE-2010-2500
      * CVE-2010-2519
      * CVE-2010-2520
    * libXau 1.0.6
    * mesa 7.8.2
  * server:
    * xorg-server 1.8.2 plus other patches
      * Fixed possible memory errors with cursor on ppc (#415)
      * Fixed a crash that can occur when changing to a higher resolution while in fullscreen

== Changes in 2.5.1 ==
  * All changes in 2.5.0 plus:
  * app:
    * luit
      * includes changes from Thomas Dickey's luit-20100601
    * quartz-wm 1.1.1
      * Fixed an issue with focus loss (#370)
      * Fixed an issue dragging windows to other spaces (#375)
    * sessreg 1.0.6
    * xinit
      * Fixed startx to be POSIX compliant for users of non-bash /bin/sh (#399)
    * xinput 1.5.2
    * xlsatoms 1.1.0
    * xlsclients 1.1.0
    * xlsfonts 1.0.3
    * xscope
      * Fixed a wedge by forcing TCP connections
    * xterm 261
  * lib:
    * cairo 1.8.10
    * libpng 1.2.44
      * CVE-2010-1205
    * libpng 1.4.3
      * CVE-2010-1205
    * libX11 1.3.4
      * Now built --with-xcb
    * libXcomposite 0.4.2
    * libXdamage 1.1.3
    * libXext 1.1.2
    * libXfixes 4.0.5
    * libXfont 1.4.2
    * libXrender 0.9.6
    * libxcb 1.6
      * Fixed $DISPLAY parsing (#390)
    * mesa 7.8.1
    * pixman 0.18.2
  * misc:
    * pkg-config 0.25
    * util-macros 1.10.0
    * xkeyboard-config 1.9
    * xorg-sgml-doctools 1.5
  * proto:
    * xproto 7.0.17
  * server:
    * xorg-server 1.8.2 plus other patches
      * Move to the 1.8 branch
      * Fixed shift-arrow keys sending math symbols in wine (#295)
      * Added a preference to toggle between Alt_L, Alt_R and Mode_switch (#374)
      * Fixed possible errors with GLX pixel formats  Bugzilla #27654
      * Worked around another instance of the graphics context clipping bug that was causing border render errors (#290)
      * Fix some misreported pointer coordinates with middle click and scrolling (#389)

== Changes in 2.5.0 ==
  * All changes in 2.4.0 plus:
  * app:
    * bdftopcf 1.0.2
    * bitmap 1.0.4
    * editres 1.0.4
    * font_cache
      * Ensure that only one instance of font_cache can run at a time
    * iceauth 1.0.3
    * listres 1.0.2
    * luit 1.0.5
    * makedepend 1.0.2
    * mkfontscale 1.0.7
    * mkfontdir 1.0.5
    * quartz-wm 1.1.0
      * Fixed a bug (#329) where windows could get lost behind the dock
    * sessreg 1.0.5
    * viewres 1.0.2
    * x11perf 1.5.1
    * xauth 1.0.4
    * xcalc 1.0.3
    * xclipboard 1.1.0
    * xclock 1.0.4
    * xcursorgen 1.0.3
    * xdm 1.1.9
    * xdpyinfo 1.1.0
    * xev 1.0.4
    * xgc 1.0.2
    * xhost 1.0.3
    * xinit 1.2.1
    * xinput 1.5.1
    * xkbcomp 1.1.1
    * xkbevd 1.1.0
    * xkbprint 1.0.2
    * xkbutils 1.0.2
    * xkill 1.0.2
    * xlogo 1.0.2
    * xlsatoms 1.0.2
    * xlsclients 1.0.2
    * xman 1.1.0
    * xmessage 1.0.3
    * xmodmap 1.0.4
    * xpr 1.0.3
    * xprop 1.1.0
    * xrandr 1.3.2
    * xrdb 1.0.6
    * xrefresh 1.0.3
    * xscope 1.2
    * xset 1.1.0
    * xsetroot 1.0.3
    * xterm 256
    * xvinfo 1.1.0
    * xwd 1.0.3
    * xwininfo 1.0.5
    * xwud 1.0.2
  * font:
    * encodings 1.0.3
    * font-adobe-100dpi 1.0.1
    * font-adobe-75dpi 1.0.1
    * font-adobe-utopia-100dpi 1.0.2
    * font-adobe-utopia-75dpi 1.0.2
    * font-adobe-utopia-type1 1.0.2
    * font-alias 1.0.2
    * font-arabic-misc 1.0.1
    * font-bh-100dpi 1.0.1
    * font-bh-75dpi 1.0.1
    * font-bh-lucidatypewriter-100dpi 1.0.1
    * font-bh-lucidatypewriter-75dpi 1.0.1
    * font-bh-ttf 1.0.1
    * font-bh-type1 1.0.1
    * font-bitstream-100dpi 1.0.1
    * font-bitstream-75dpi 1.0.1
    * font-bitstream-speedo 1.0.1
    * font-bitstream-type1 1.0.1
    * font-cronyx-cyrillic 1.0.1
    * font-cursor-misc 1.0.1
    * font-daewoo-misc 1.0.1
    * font-dec-misc 1.0.1
    * font-ibm-type1 1.0.1
    * font-isas-misc 1.0.1
    * font-jis-misc 1.0.1
    * font-micro-misc 1.0.1
    * font-misc-cyrillic 1.0.1
    * font-misc-ethiopic 1.0.1
    * font-misc-meltho 1.0.1
    * font-misc-misc 1.1.0
    * font-mutt-misc 1.0.1
    * font-schumacher-misc 1.1.0
    * font-screen-cyrillic 1.0.2
    * font-sony-misc 1.0.1
    * font-sun-misc 1.0.1
    * font-winitzki-cyrillic 1.0.1
    * font-xfree86-type1 1.0.2
  * lib:
    * fontconfig 2.7.3
    * freetype 2.3.12
    * libAppleWM 1.4.0
    * libICE 1.0.6
    * libdmx 1.1.0
    * libfontenc 1.0.5
    * libpng 1.2.43
    * libX11 1.3.3
    * libXau 1.0.5
    * libXaw 1.0.7
    * libxcb 1.5
    * libXcomposite 0.4.1
    * libXcursor 1.1.10
    * libXdamage 1.1.2
    * libXdmcp 1.0.3
    * libXext 1.1.1
    * libXfixes 4.0.4
    * libXfont 1.4.1
    * libXfontcache 1.0.5
    * libXft 2.1.14
    * libxkbfile 1.0.6
    * libXi 1.3
    * libXinerama 1.1
    * libXmu 1.0.5
    * libXplugin
      * Performance fix for ATI cards in DRI (SnowLeopard)
      * Fix drawing of the window growbox (SnowLeopard)
      * Help quartz-wm claim ownership of existing windows
      * Send notification of display change on display wake
    * libXpm 3.5.8
    * libXrender 0.9.5
    * libXres 1.0.4
    * libXv 1.0.5
    * libXvMC 1.0.5
    * libXScrnSaver 1.2.0
    * libXxf86dga 1.1.1
    * libXxf86misc 1.0.2
    * libXxf86vm 1.1.0
    * libXt 1.0.8
    * libXtst 1.1.0
    * mesa 7.7
      * libGL:
        * Rebased code off of mesa_7_7_branch
        * Fixed ABI for some extensions
    * pixman 0.16.6
    * xcb-util 0.3.6
    * xpyb 1.2
    * xtrans 1.2.5
  * misc:
    * font-util 1.1.1
    * util-macros 1.6.1
    * xbitmaps 1.1.0
    * xorg-sgml-doctools 1.3
    * xkeyboard-config 1.8
  * proto:
    * applewmproto 1.4.1
    * bigreqsproto 1.1.0
    * compositeproto 0.4.1
    * damageproto 1.2.0
    * dmxproto 2.3
    * dri2proto 2.3
    * evieext 1.1.0
    * fixesproto 4.1.1
    * fontcacheproto 0.1.3
    * fontsproto 2.1.0
    * glproto 1.4.11
    * inputproto 2.0
    * kbproto 1.0.4
    * randrproto 1.3.1
    * recordproto 1.14
    * resourceproto 1.1.0
    * scrnsaverproto 1.2.0
    * videoproto 2.3.0
    * xcb-proto 1.6
    * xcmiscproto 1.2.0
    * xextproto 7.1.1
    * xf86bigfontproto 1.2.0
    * xf86dgaproto 2.1
    * xf86driproto 1.2.0
    * xf86miscproto 0.9.3
    * xf86vidmodeproto 2.3
    * xineramaproto 1.2
    * xproto 7.0.16
  * server:
    * xorg-server 1.7.6 plus other patches
      * Move to the 1.7 branch
      * 64bit fixes for pbproxy
      * Add support for side-by-side installation with system X11 (SnowLeopard Only)
      * Allow 16bit accumulation buffers
      * Properly set the key repeat rates in the server rather than relying on xinitrc
      * Partially fixed the "borders don't show up" bug (#290)
      * Fixed the rare stuck mouse pointer bug (#64)

== Changes in 2.4.0 ==
  * All changes in 2.3.3.2 plus:
  * app:
    * font-util 1.0.2
    * quartz-wm 1.0.4
      * Added an option to quit X11 when no more windows are being managed by quartz-wm
        * defaults write org.x.X11 wm_auto_quit -bool true
        * defaults write org.x.X11 wm_auto_quit_timeout -int 3
      * fixed an input bug with fullscreen windows
      * maximizing a window that is partially offscreen will no longer cause it to be behind the Dock
    * setxkbmap 1.1.0
    * Xephyr, Xnest, Xfake, Xvfb 1.6.3
    * xfs 1.1.0
    * xkbcomp 1.1.0
    * xmag 1.0.3
    * xrandr 1.3.1
    * xrx 1.0.3
    * xterm 245
  * lib:
    * cairo 1.8.8
    * fontconfig 2.7.1
    * freetype
      * no longer built --with-old-mac-fonts in order to prevent linking against CoreFoundation. See #280
    * libAppleWM 1.3.0
    * libFS 1.0.2
    * liblbxutil removed
    * liboldX removed
    * libpng 1.2.37
    * libSM 1.1.1
    * libX11 1.2.2
    * libxcb 1.4
    * libXaw 1.0.6
    * libXplugin
      * Fix a possible deadlock when using 8bit visuals
      * Added API for attaching transient windows
    * libXprintAppUtil removed
    * libXprintUtil removed
    * libXt 1.0.6
    * mesa 7.4.4
      * libGLU, libglut, and OSMesa
        * Fixed linking problems with libOSMesa
    * xcb-util 0.3.5
    * xtrans 1.2.4
  * proto:
    * applewmproto 1.3.0
    * dri2proto 2.1
    * fixesproto 4.1
    * glproto 1.4.10
    * inputproto 1.5.1
    * renderproto 0.11
    * xcb-proto 1.5
    * xextproto 7.1.0
  * server:
    * Xquartz fixes from xorg-server-1.5.3-apple14
      * xserver codebase updated to 1.5 branch
      * rewritten AIGLX dispatch code
      * Localization updates
      * Don't zombie "jumpstart" process at launch
      * GLXFBConfigs and GLXVisuals don't contain duplicates when using multiple monitors
      * Automatic updates using Sparkle

== Changes in 2.3.3.2 ==
  * All changes in 2.3.3.1 plus:
  * lib:
    * libXplugin
      * Fixed a bug in the interaction between X11 and Spaces

== Changes in 2.3.3.1 ==
  * All changes in 2.3.3 plus:
  * apps:
    * xinput 1.4.2
  * lib:
    * libXplugin
      * Fixed a possible crash when closing windows
  * proto:
    * dri2proto 2.0

== Changes in 2.3.3 ==
  * All changes in 2.3.2.1 plus:
  * apps:
    * quartz-wm
      * Properly re-enable the close widget when modal windows are destroyed
      * Fixed a bug when the window was told to unmaximize when it was already not maximized.
    * xinput 1.4.1
    * xrandr 1.3.0
    * xterm 243b
    * Xephyr, Xnest, Xfake, Xvfb 1.6.0
  * proto:
    * applewmproto 1.2.0
    * dri2proto 1.99.3
    * randrproto 1.3.0
    * xproto 7.0.15
    * xextproto 7.0.5
    * xcb-proto 1.4
    * xf86rushproto 1.1.2
  * lib:
    * AppleSGLX 57
      * Support the same version of OpenGL as OpenGL.framework (2.1)
        * GLSL and other features now supported
        * Many extensions from OpenGL.framework are now available
      * rewrite of libGL now has support for GLX-1.4
        * GLXPixmap
        * GLXPbuffer
      * Threading support should be more stable
    * fontconfig
      * Avoid rebuilding font caches when switching between archs
    * freetype 2.3.9
    * libAppleWM 1.2.0
    * libICE 1.0.5
    * libpng 1.2.35
      * CVE-2009-0040
    * libxcb 1.2
    * libX11 1.2
    * libXau
      * Avoid lock failures with AFP home directories
    * libXext 1.0.5
    * libXfont 1.4.0
    * libXi 1.2.1
    * libXrandr 1.3.0
    * pixman 0.14.0
    * xtrans 1.2.3
  * server:
    * Xquartz fixes from xorg-server-1.4.2-apple42
      * DRI Updates for new libGL
      * Fix CapsLock
      * Fixed mouse tracking for games like Quake2, Halflife, etc in wine.
      * Fixed the annoying spaces bug resulting from accessing menus in a window that you moved to another space
      * When configured for fullscreen mode, initial apps don't start rootless.
      * Update window levels when changing rootless status
      * Fixed window levels to work with applications that create a desktop (nautilus, etc)
      * Properly send tablet proximity events
      * Localization Updates

== Changes in 2.3.2.1 ==
  * All changes in 2.3.2 plus:
  * lib:
    * fontconfig 2.6.0
      * fixed configuration directory to be /usr/X11/lib/X11/fontconfig

== Changes in 2.3.2 ==
  * All changes in 2.3.1 plus:
  * app:
    * mkfontscale 1.0.6
    * quartz-wm
      * Cleaned up parenting of dialog and utility windows
      * Respond to new AppleWMReloadPreferences notification rather than just SIGHUP
      * space-change shortcuts and dragging work to move windows to other spaces
      * Fixed bug with --no-pasteboard option that didn't completely disable it (it still grabbed PRIMARY in activate/deactivate)
      * defaults to --no-pasteboard when the server uses version 1.1 and greater of applewmproto
      * Cleaned up some memory leaks
      * Support added for window gravity in WM size hints
      * Support added for WM fullscreen hints
    * xedit 1.1.2
    * xinit 1.1.1
    * xterm 238
        * Addresses CVE-2008-2383
  * lib:
    * cairo 1.8.6
    * fontconfig 2.6.0
    * freetype 2.3.7
    * libpng 1.2.33
      * Note that our previous version was 1.2.26 and was NOT affected by CVE-2008-3964.
    * libxcb 1.1
      * Fixed potential problems with xcb using the launchd socket
    * libXau 1.0.4
    * libXaw 1.0.5
      * libXaw.8.dylib is still provided from libXaw-1.0.4 for compatability
    * libXfont 1.3.4
    * libXi 1.2.0
    * libX11 1.1.5
    * mesa-7.2
      * For libGLU, libglut, glxgears, glxinfo
    * pixman 0.12.0
    * Xplugin
      * Cleaned up parenting of dialog and utility windows
    * xcb-util 0.3.2
    * xtrans 1.2.2
  * misc:
    * util-macros 1.2.1
  * proto:
    * applewmproto 1.1.1
      * AppleWMReloadPreferences notification
    * inputproto 1.5.0
    * xextproto 7.0.4
    * xproto 7.0.14
  * server:
    * Xquartz fixes from xorg-server-1.4.2-apple31
      * Send out AppleWMReloadPreferences notification to tell quartz-wm and xpbproxy to reload preferences
      * Fix a crash in RootlessNativeWindowMoved when compiled for 64bit
      * Fix a possible crash on startup due to TSM not being thread safe
      * Added new preferences UI for xpbproxy options
      * Disabled 8bit visuals while in TrueColor mode since they don't work yet
      * Tablet support improved for GDK-based applications (Gimp, Inkscape, etc)
      * Many updates to GLX support
        * Stereo GLX support detected
        * Accum buffers supported
        * More visuals supported
        * Multisampling now supported
      * Fixed levels for CGWindows
      * Fullscreen-rooted support (same behavior as tiger)
        * Added an option for getting access to the OSX menu bar while in fullscreen
      * Correctly follow system keyboard layout when enabled
      * Tooltips won't display from X11 apps "behind" native apps.
        * Apps like xeyes only get events when the mouse is actually over an X11 window now
      * Default dpi reported is now 96 instead of 75
      * Fixed possible (rare) deadlock in event processing
      * Massive update of proxying between OSX pasteboard and X11 clipboard/primary buffers
        * Image support
        * Unicode support
        * Preference options available in the X11 Preferences window
      * X11.app should exit properly when using another WM
      * Improved support for running X11 without launchd
      * Improved support for running multiple X11 servers
      * Fixed dead-acute with the Czech and Greek layouts
      * Fixed working directory of the initial xterm to be $HOME
      * Ensured that /usr/X11/bin was in the PATH of the initial xterm
      * Added a defaults option to enable DEC-XTRAP, RENDER, and XTEST extensions
        * defaults write org.x.X11 enable_test_extensions -boolean true
      * Fixed the white-rectangles bug
      * Fixed stuck keys when switching to another OSX application
      * Honor system key repeat rate

== Changes in 2.3.1 ==
  * All changes in 2.3.0 plus:
  * app:
    * xedit 1.1.1
    * quartz-wm
      * Added --no-pasteboard command line option
  * lib:
    * mesa 7.1-rc4
      * For libGLU, libglut, glxgears, glxinfo
    * pixman 0.11.8
    * Xplugin
      * Added API for detecting if a Carbon EventRef corresponds to a Mac OSX key-equivalent action
    * xpyb 0.9
    * xtrans 1.2.1-git-2008.08.05
  * proto:
    * randrproto 1.2.2
    * xextproto 7.0.3
    * xproto 7.0.13
  * server:
    * Xquartz fixes from xorg-server-1.4.2-apple17
      * building with mesa 7.0.4
      * X11.app now properly notices button clicks with tablets
      * partially fixed xinitrc / launchd-first-client race condition
      * Re-added old fallback keyboard map detection fallback with extra debugging
      * Capslock "press ignored" bug is fixed.
      * Fixed stuck modifier key bug
      * Fixed 3-button mouse emulation
      * The list of modifiers allowed in the fake_button{2,3} defaults has been expanded:
        * fn,{l,r,}{command,alt,shift,control}
      * Expanded handling of key equivalents beyond just the menu when enabled (such as the input menu, etc)
        * Also added appkit_modifiers defaults option which users can set to certain modifier keys to always be for Appkit in case this is insufficient
      * Added window_item_modifiers defaults item (and option to localization) to change the modifier keys used for the windows menu.
        * Set it to an empty string to disable key equivalents for changing windows.
      * Fixed a possible crash in SwitchCoreKeyboard resulting from the use of tablets (or anything sending NSTabletPoint events)
      * Fixed s possible crash in NewCurrentScreen
      * Fixed a possible crash in RootlessNativeWindowMoved
      * Updated the Xquartz man page
      * Don't warp the pointer on startup
      * Made fd handoff from stub to server more robust
      * Added 256 color mode option to the server (8bit visuals in TrueColor mode are still broken though)

== Changes in 2.3.0 ==
  * All changes in 2.2.3 plus:
  * app:
    * fonttosfnt 1.0.4
    * fslsfonts 1.0.2
    * fstobdf 1.0.3
    * mkfontscale 1.0.5
    * rgb 1.0.3
    * sessreg 1.0.4
    * showfont 1.0.2
    * xdm 1.1.8
    * xdpyinfo 1.0.3
    * xfs 1.0.8
    * xfsinfo 1.0.2
    * xinit 1.0.9
    * xkbcomp 1.0.5
    * xkeyboard-config 1.3
      * replaces old xkbdata
    * xrx 1.0.2
    * xwd 1.0.2
    * xwininfo 1.0.4
  * lib:
    * libFS 1.0.1
    * libSM 1.1.0
    * libXfont 1.3.3
    * libXft 2.1.13
    * libXrandr 1.2.3
    * libXxf86vm 1.0.2
    * xtrans 1.2.1
  * proto:
    * randrproto 1.2.2
    * xextproto 7.0.3
    * xproto 7.0.13
  * server:
    * Xquartz fixes from xorg-server-1.4.2-apple5
      * xserver codebase updated to 1.4 branch
      * Support for tablets
      * Threading is more robust
      * Support for new startup model
        * support for adding new $DISPLAY sockets after the server is running
        * server bits are in the bundle now
        * /usr/X11/bin/Xquartz is just a stub that will "do the right thing"

== Changes in 2.2.3 ==
  * All changes in 2.2.2 plus:
  * lib:
    * freetype 2.3.6
      * Note from freetype developers: "A bunch of potential security problems have been found [and fixed] in this release"
    * pixman 0.11.4

== Changes in 2.2.2 ==
  * All changes in 2.2.1 plus:
  * server:
    * Xquartz fixes from xorg-server-1.3.0-apple21
      * Support monitor hotplugging
      * CVE-2008-1377
      * CVE-2008-1379
      * CVE-2008-2360
      * CVE-2008-2361
      * CVE-2008-2362

== Changes in 2.2.1 ==
  * All changes in 2.2.0.1 plus:
  * All packages updated to versions intended to ship as part of X11R7.4 (as of 2008.04.21):
  * app:
    * setxkbmap 1.0.4
    * xinit 1.0.8-git-2008.04.26
      * Use CFProcessPath instead of argv[0] trick
    * xkbcomp 1.0.4
    * xkbdata 1.0.1
    * xkbevd 1.0.2
    * xkbprint 1.0.1
    * xkbutils 1.0.1
    * xterm 235
  * lib:
    * cairo 1.6.4
    * mesa 7.0.3
      * for libGLU, libglut, libOSMesa, Xfake, and Xephyr
    * libxkbfile 1.0.5
    * libXv 1.0.4
    * pixman 0.10.0
  * proto:
    * dri2proto 1.1
    * xf86driproto 2.0.4
  * quartz-wm:
    * Fixed "closing X11 window swaps spaces" bug
  * server:
    * xorg-server-1.3.0-apple20
      * Fixed multiple crash-causing bugs
      * Fixed cmd-tab to properly move all windows forward when entering X11.app

== Changes in 2.2.0.1 ==
  * All changes in 2.2.0 plus:
    * Updated /usr/X11/lib/X11/xinit/privileged_startx.d/10-tmpdirs to address a potential security risk (privilege escalation):
      * A user could create a symbolic link from /tmp/.X11-unix to /usr/X11/lib/X11/xinit/privileged_startx.d and execute privileged_startx to give himself write permission to /usr/X11/lib/X11/xinit/privileged_startx.d

== Changes in 2.2.0 ==
  * All changes in 2.1.4 plus:
  * All packages updated to versions intended to ship as part of X11R7.4 (as of 2008.03.14):
  * app:
    * bitmap 1.0.3
    * bdftopcf 1.0.1
    * editres 1.0.3
    * iceauth 1.0.2
    * ico 1.0.2
    * luit 1.0.3
      * Also added Martin's secure tty patch
    * mkfontdir 1.0.4
    * mkfontscale 1.0.4
    * setxkbmap 1.0.4
    * ttmkfdir 3.0.9
    * sessreg 1.0.3
    * twm 1.0.4
    * x11perf 1.5
    * xauth 1.0.3
    * xbacklight 1.1
    * xcalc 1.0.2
    * xclock 1.0.3
    * xconsole 1.0.3
    * xcursorgen 1.0.2
    * xdm 1.1.7
    * xdpyinfo 1.0.2
    * xdriinfo 1.0.2
    * xev 1.0.3
    * xfontsel 1.0.2
    * xfs 1.0.6
    * xgamma 1.0.2
    * xhost 1.0.2
    * xinit 1.0.8-git-2008.04.08
      * Moved font caching logic to startx rather than xinitrc
      * Added support for xinitrc.d directory, so fink, macports, et al won't clobber our xinitrc
      * Moved some stuff out of xinitrc into the xinitrc.d directory
      * Fixed startup to work correctly even with broken .bashrc and .profile ('set <blah>' bug)
      * Fixed "post-crash titlebar missing" bug
      * Fixed /tmp/.X11-unix permission
      * Now cache system font directories at X11.app startup rather than system startup
      * Renamed startx LaunchAgent org.x.startx from org.x.X11
      * System xinitrc now works for users with spaces in $HOME
    * xload 1.0.2
    * xlsfonts 1.0.2
    * xmag 1.0.2
    * xman 1.0.3
    * xmessage 1.0.2
    * xpr 1.0.2
    * xmodmap 1.0.3
    * xprop 1.0.4
    * xrandr 1.2.3
    * xrdb 1.0.5
    * xset 1.0.4
    * xsetpointer 1.0.1
    * xsetroot 1.0.2
    * xvinfo 1.0.2
    * xwininfo 1.0.3
  * font:
    * font-xfree86-type1 1.0.1
  * lib:
    * cairo 1.4.14
    * libICE 1.0.4
    * libSM 1.0.3
    * libX11 1.1.4
    * libXaw 1.0.4
    * libXcomposite 0.4.0
    * libXcursor 1.1.9
    * libXdamage 1.1
    * libXext 1.0.4
    * libXfont 1.3.2
    * libXi 1.1.3
    * libXinerama 1.0.3
    * libXmu 1.0.4
    * libXpm 3.5.7
    * libXrandr 1.2.2
    * libXrender 0.9.4
    * libXt 1.0.5
    * libXtst 1.0.3
    * libXxf86dga 1.0.2
    * libpng 1.2.26
      * Includes fix for CVE-2008-1382
    * xcb 1.1
    * xtrans 1.1
  * proto:
    * inputproto 1.4.3
    * printproto 1.0.4
    * xproto 7.0.12
    * xcb-proto 1.1
  * util:
    * makedepend 1.0.1
    * util-macros 1.1.6
  * quartz-wm:
    * Restores minimized windows when the server crashes
    * Added preference to control moving X11.app into the foreground when a new X11 window is created
    * Added preference to toggle shading of windows
  * server:
    * xorg-server-1.3.0-apple15
      * Added informational output when falling through to failsafe startup in X11.app
      * Unsetenv(DISPLAY) when falling through to failsafe startup in X11.app
      * Fixed "confirm on exit"
      * Exposé now works as expected
      * Disabled rlAccel (suspected of causing some crashes, might not be fixed since plans are to support COMPOSITE)
      * X11 works better with spaces

== Changes in 2.1.4 ==
  * All changes in 2.1.3 plus:
  * app:
    * fontconfig 2.5.0
      * fixes a bunch of compatability issues (including Trolltech QT4)
    * ttmkfdir 3.0.9
      * app was missing
    * xinput 1.3.0
      * app was missing
    * xterm 232
      * fixes tek with wide chars
    * xinit git 2008.02.10
      * fixes fontpath to avoid "big fonts" issue commonly seen in xemacs
      * fix xinitrc to properly process .Xresources if dev tools are not installed
      * update FC cache on X11 start
    * Xvfb, Xnest, Xephyr, Xfake
      * built using xorg-server-1.4-apple (2008.02.14)
    * quartz-wm
      * Updated to use org.x.X11 instead of com.apple.x11 for defaults
  * fonts:
    * made font caching more "automatic"
  * server:
    * xorg-server-1.3.0-apple10
      * Fixed Window menu to conform to OSX UI Guidelines
      * Fixed command-~ to reverse cycle through windows
      * Added option to preferences for quartz-wm click-through
      * Fixed UI layout problems when resizing Applications->Customize window
      * Updated render and fb code from 1.4 branch
        * We are now using pixman for our fbBlah function calls, and this code has been heavily refactored in the integration with pixman, so this should clear up many of those crashes

== Changes in 2.1.3 ==
  * All changes in 2.1.2 plus:
  * lib:
    * libXfont git 2008.01.14
      * CVE-2008-0006
  * server:
    * xorg-server-1.3.0-apple9
      * fixed 'login_shell' defaults key usage when launching from the Applications menu.
      * CVE-2007-5958
      * CVE-2007-6427
      * CVE-2007-6428
      * CVE-2007-6429
      * CVE-2008-0006

== Changes in 2.1.2 ==
  * All changes in 2.1.1 plus:
  * app:
    * xinit git 2008.01.09
      * Updated xinit to support launchd
      * Now using xinit to start the server rather than running X11.app directly
        * X11.app is relocatable now
      * Fixed fast-user-switching X11 regression
      * Properly honor xauth and tcp/ip preferences
    * xauth git 2008.01.11
      * fixed duplicate entry crash during xauth remove
  * lib:
    * pixman 0.9.6
  * proto:
    * compositeproto 0.4
    * glproto 1.4.9
    * inputproto-1.4.2.1
    * renderproto-0.9.3
  * server:
    * Xquartz fixes from xorg-server-1.2-apple (Up to Xquartz-1.3.0-apple7)
      * XQuartz comes to the foreground later in the startup process to not cause 'XQuartz -version' to flash a dock icon
      * Fixed -depth command line argument to work properly (still no 8-bit support)
      * added 'startx_script' defaults option which defaults to /usr/X11/bin/startx.
      * This is used when launchd support is disabled and the user uses X11.app to start the server (such as with Tiger).
      * added localization from Leopard's shipped X11.
      * added 'login_shell' key to org.x.X11 plist which defaults to /bin/sh and is used for launching from the Applications menu.  tcsh users will probably want to change this to /bin/tcsh.

== Changes in 2.1.1 ==
  * All changes in 2.1.0.1 plus:
  * Updated versions of packages:
    * app:
      * lndir git 2007.12.08
        * Properly ignore .DS_Store
      * xinit git 2007.12.10
        * Added package.
      * xterm 229
        * Replace antiquated version (207) with new version from upstream source.
        * Better UTF8 support among other bugfixes
    * proto:
      * x11proto git 2007.12.10
        * Changed references of __DARWIN__ to __APPLE__
  * fc-cache is run during post-install
  * Xquartz fixes from xorg-server-1.2-apple (Up to Xquartz-1.3.0-apple5)
    * Crash and stability fixes
    * Fixed startup to check preferences set in org.x.X11 instead of com.apple.X11
    * Multiple dock-icons bug fixed
    * XDMCP now works
    * Fixed Alt to work right with [wiki:KeyboardMapping#AltvsMode_switch ~/.Xmodmap
    * Added workaround to support Fink until they update their packages
    * Small updates to Xquartz.man page (still needs a good edit, if you can help, please contact the xquartz-dev mailing list)

== Changes in 2.1.0.1 ==
  * All changes in 2.1.0 plus
  * Fixed package post-install to not error on machines without Xcode.

== Changes in 2.1.0 ==
  * New versions of packages from x.org:
    * app:
      * xfs 1.0.5
        * Fixes CVE-2007-4568
        * Fixes CVE-2007-4990
    * lib:
      * libX11 1.1.3
        * Fixes gtk and related crashes
    * proto:
      * damageproto 1.1.0
      * randrproto 1.2.1
  * Xquartz fixes from xorg-server-1.2-apple (Up to Xquartz-1.3.0-apple2)
    * xserver codebase updated from 1.2.0 to 1.3 branch
      * Fixes CVE-2007-1003
    * Fixed support for multiple displays (Xinerama)
    * Fixed yellow cursor issue on Intel machines
    * Fixed broken 3-button mouse emulation (i.e. option-click to paste)
    * Fixed missing support for Japanese JIS-layout keyboards
    * Improved compatibility with Spaces
    * Fixed the "Xquartz chews up 100% CPU when I run xauth / ssh / xdpyinfo" bug
    * Fixed support for customized Applications items
    * Fixed performance problems (slow drawing in Gimp, etc)
    * Fixed focus issues
    * Fixed stuck modifier key issues
    * Big fix to rootless code, which should eliminate some Xquartz crashes -- big thanks to Ken Thomases of CodeWeavers
    * Motion events are now given to background windows (like xeyes), like they were in Tiger
    * Fixed condition where quickly-exiting programs could cause Xquartz to chew CPU
    * "Fake RandR" support -- Tiger's X11.app didn't actually support the RandR extension (which allows display configuration to be changed while the server is running), but it did copy some code that does part of that. I'd like to actually implement support for RandR, but in the mean time I've copied the "fake" code into Xquartz. I haven't yet managed to scrounge up the hardware to test this, so I would appreciate hearing reports about whether this does or does not work.
    * Fixed spurious "Are you sure you want to quit?" message. This message is supposed to be suppressed if you do not have any X client apps running, but it could show up if you had started the server manually and not started any client (uninitialized variable). BTW, this warning can be disabled entirely with the command "defaults write org.x.X11 no_quit_alert true"
    * Adds support for horizontal scroll-wheels on mice
    * Fixed crashes in Damage code due to Rootless conflict
    * Fixed crashes in QueryFontReply
    * Fixed support for JIS (Japanees keyboards now work)
    * Redraw speed fix for apps such as the Gimp and rdesktop
    * Fixed a SafeAlphaComposite bug that caused some GTK apps to crash with a BadMatch error in 24-bit mode
    * Alt is now mapped to Mod_switch by default (back to Tiger's X11 default)
      * If you want it to be mapped to Alt_L and Alt_R, use ~/.Xmodmap
  * Include Xephyr, Xfake, Xvfb, and Xnest
  * Include missing man pages for Xquartz and other Xservers
  * Updated /usr/X11/include/X11/Xtranssock.c
    * Fix for incorrect processing of recycled launchd socket
  * Updated /A/U/X11.app/C/M/X11 from xorg-server-1.2-apple
    * Fixes proper env setting and command line arguments in app_to_run
  * Updated xauth to work with launchd sockets
  * Unicode support in xterm
  * xfs and fontconfig now include fonts from {,/System}/Library/Fonts
  * Added LaunchAgent (org.x.fontconfig) to run fc-cache on startup

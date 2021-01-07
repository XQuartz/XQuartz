dnl Copyright (c) 2016 Apple Inc. All Rights Reserved.
dnl
dnl @APPLE_LICENSE_HEADER_START@
dnl
dnl This file contains Original Code and/or Modifications of Original Code
dnl as defined in and that are subject to the Apple Public Source License
dnl Version 2.0 (the 'License'). You may not use this file except in
dnl compliance with the License. Please obtain a copy of the License at
dnl http://www.opensource.apple.com/apsl/ and read it before using this
dnl file.
dnl
dnl The Original Code and all software distributed under the License are
dnl distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
dnl EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
dnl INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
dnl FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
dnl Please see the License for the specific language governing rights and
dnl limitations under the License.
dnl
dnl @APPLE_LICENSE_HEADER_END@

AC_PREREQ([2.61])
AC_INIT(libXt7-stub, [1.0.0], [https://www.xquartz.org], libXt7-stub)
AC_CONFIG_MACRO_DIRS([m4])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([foreign dist-bzip2 dist-xz])
AM_MAINTAINER_MODE

LT_INIT([disable-static])

AC_PROG_CC
AC_PROG_INSTALL

# Checks for pkg-config packages
PKG_CHECK_MODULES(XT, [xt >= 1.1.5])
AC_SUBST(XT_LIBS)

AC_OUTPUT([Makefile])

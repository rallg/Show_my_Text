#!/bin/sh
# Installation file 'installsmy.sh' for Show-my-Text.

# On Linux systems, you will need superuser permission to install.
# On Termux, you already have the necessary permissions.

# This script will build and install executable 'showmytext'.
# And, it installs a desktop file, for use with application Menu.
# The program is small. If you have the build system and dependencies,
# it finishes in less than a minute.

# Rationale for the size class:
# Most software was historically developed at a time when screens were
# expected to have about 96pdi density. Unfortunately, the density was
# hard-coded into the software. Then, fonts and images appear too small,
# when viewed on modern HDPI screens with density 192 or more.
# On the other hand, recent software, and re-written older software,
# may recognize HDPI. Then the adjustment is automatic.
# A given system may have some software that adjusts, others not.
# So, this software does not know whether adjustment is needed.
# If wrong guess, the other classes let you tweak it.

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
	echo "Need help? Please read the INSTALL file."
	echo "Repository: https://github.com/rallg/Show-my-Text"
	exit
fi

arg="$(echo $@ | sed 's/-*//g')"
export here="$PWD"


# Detect Termux or Linux. Test if sudo is needed for installation on Linux:
dosudo="no"
case "$here" in
	/data/data/com.termux*) t="yes" ;;
	*) t="no" ;;
esac

if [ "$t" = "no" ] ; then
	mkdir -p "/usr/local/bin" 2>/dev/null || dosudo="yes"
	mkdir -p "/usr/local/share/applications" 2>/dev/null || dosudo="yes"
	[ -w "/usr/local/bin" ] || dosudo="yes"
	[ -w "/usr/local/share/applications" ] || dosudo="yes"
fi


# Ensure that components are available:
linb="$here/resource/meson.linux"
terb="$here/resource/meson.termux"
sushi="$here/resource/src/sushi-font-widget.c"
if [ ! -w "$sushi" ] ; then
	printf "\033[92mError.\033[0m Source code is not writeable.\n"
	echo "This script re-writes one of the source code files,"
	echo "so that it includes your display text. But the source code"
	echo "does not have write permission. Usually, this can be fixed"
	echo "by moving all of Show-my-Text to your home directory."
	exit 2
fi
ok="yes"
[ "$t" = "no" ] && [ ! -f "$linb" ] && ok="no"
[ "$t" = "yes" ] && [ ! -f "$terb" ] && ok="no"
[ ! -f "$sushi" ] && ok="no"
if [ "$ok" = "no" ] ; then
	printf "\033[92mError.\033[0m Cannot find some Show-my-Text files.\n"
	echo "Run ./installsmt.sh from its directory, not /path/to/installsmt.sh."
	exit 3
fi


# Minimal check for compiler:
gotm="$(command -v meson 2>/dev/null)"
if [ -z "$gotm" ] ; then
	printf "\033[91mError.\033[0m Did not find meson compiler.\n"
	exit 2
fi
gotn="$(command -v ninja 2>/dev/null)"
if [ -z "$gotn" ] ; then
	printf "\033[91mError.\033[0m Did not find ninja compiler.\n"
	exit 2
fi


# Dialog:
echo "Displayed text will be scaled according to your screen density (dpi)."
echo "Some systems adjust for dpi. Others do not."
echo "This installer assumes you have an HPDI screen, not adjusted."
echo "If the installed program displays text too large or too small,"
echo "Then re-run this installer with another choice of size."
echo "Available sizes are 1 (small) to 7 (large). Default 3."
printf "\033[1mChoose a size [1|2|3|4|5|6|7|x] : \033[0m" ; read r
case "$r" in
	1) sed -i 's/.*alpha_size =.*/  \*alpha_size = 18;/' "$sushi" ;;
	2) sed -i 's/.*alpha_size =.*/  \*alpha_size = 27;/' "$sushi" ;;
	3) sed -i 's/.*alpha_size =.*/  \*alpha_size = 36;/' "$sushi" ;;
	4) sed -i 's/.*alpha_size =.*/  \*alpha_size = 45;/' "$sushi" ;;
	5) sed -i 's/.*alpha_size =.*/  \*alpha_size = 54;/' "$sushi" ;;
	6) sed -i 's/.*alpha_size =.*/  \*alpha_size = 63;/' "$sushi" ;;
	7) sed -i 's/.*alpha_size =.*/  \*alpha_size = 72;/' "$sushi" ;;
	x|X) echo "Exit at your request. Nothing done." && exit ;;
	*) sed -i 's/.*alpha_size =.*/  \*alpha_size = 36;/' "$sushi" ;;
esac


# Set prefix for Termux or Linux:
cd "$here/resource"
if [ "$t" = "no" ] ; then
	cp meson.linux meson.build
else
	cp meson.termux meson.build
fi
rm -r -f build
mkdir -p build


# Now build:
cd "$here/resource/build"
if [ "$dosudo" = "yes" ] ; then
	meson && meson compile
	if [ "$?" -eq 0 ] ; then
		echo "Successful build. Installation may require sudo password."
		sudo meson install
	fi
else
	meson && meson compile && meson install
fi


# Cleanup:
rm -f "$here/resource/meson.build"
rm -r -f "$here/resource/build"
rm -r -f "$tdir"
exit
##

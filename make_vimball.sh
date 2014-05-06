#!/bin/sh
version=`awk '/Version:/ { gsub("\r", ""); print $3 }' plugin/twitvim.vim`
vmbname="twitvim-${version}.vmb"
vim -e -N -i NONE -u NORC "+set rtp^=." "+/^FILES:/+1,\$MkVimball! ${vmbname}" +quit $0
exit 0

FILES:
plugin/twitvim.vim
autoload/twitvim.vim
doc/twitvim.txt

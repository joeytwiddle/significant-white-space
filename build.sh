#!/bin/sh

export PS4="[$0] "

# set -e
# set -x

## We can compile to various languages, if we don't use neko File I/O.
# haxe -main org/neuralyte/sws/Root.hx -js sws.js
# haxe -main org/neuralyte/sws/Root.hx -swf9 sws.swf
# haxe -main org/neuralyte/sws/Root.hx -cpp sws.cpp
# haxelib run hxjava sws.hxp

# sws.stable sync org > sync.log
sws sync org > sync.log

if [ ! "$?" = 0 ]
then
	cat sync.log
	# exit 120
fi

haxe -main org/neuralyte/sws/Root.hx -neko sws.n > haxe.log

if [ ! "$?" = 0 ]
then cat sync.log haxe.log ; exit 120
else
	cat haxe.log
	exit 123
fi

# nekotools boot sws.n
if ! nekotools boot sws.n
then errcode="$?" ; echo "Problem with nekotools" ; exit "$errcode"
fi

echo "Build successful."


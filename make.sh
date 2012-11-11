#!/bin/sh

transformLog=sws.log
haxeLog=haxe.log

export PS4="[$0] "

# set -e
# set -x

## We can compile to various languages, if we don't use neko File I/O.
# haxe -main src/sws/Root.hx -js sws.js
# haxe -main src/sws/Root.hx -swf9 sws.swf
# haxe -main src/sws/Root.hx -cpp sws.cpp
# haxelib run hxjava sws.hxp

# sws.stable sync org > $transformLog 2>&1
# sws sync org > $transformLog 2>&1

root=src/sws/Root.hx

d=`date +%Y%m%d-%H%M%S`
cp -n "$root" "/tmp/Root.hx.$d"
cp -n "$root.sws" "/tmp/Root.hx.sws.$d"

## I usually work on the .hx.sws files:
# sws.stable curl $root.sws $root > $transformLog 2>&1
sws.stable sync src > $transformLog 2>&1

if [ ! "$?" = 0 ]
then
	cat $transformLog
	# exit 120
fi

haxe -cp src -main sws/Root.hx -neko build/sws.n > $haxeLog 2>&1

if [ ! "$?" = 0 ]
then cat $transformLog $haxeLog ; exit 120
else cat $haxeLog
fi

# nekotools boot sws.n
if ! nekotools boot build/sws.n
then errcode="$?" ; echo "Problem with nekotools" ; exit "$errcode"
fi

# ctags org/**/*.hx /usr/share/haxe/**/*.hx

echo "Build successful."


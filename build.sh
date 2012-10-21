set -e

export PS4=""
set -x

## We can compile to various languages, if we don't use neko File I/O.
# haxe -main org/neuralyte/sws/Root.hx -js sws.js
# haxe -main org/neuralyte/sws/Root.hx -swf9 sws.swf
# haxe -main org/neuralyte/sws/Root.hx -cpp sws.cpp
# haxelib run hxjava sws.hxp

haxe -main org/neuralyte/sws/Root.hx -neko sws.n

nekotools boot sws.n


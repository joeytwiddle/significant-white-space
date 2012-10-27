# set -e

env > /tmp/x.env.zsh
set > /tmp/x.set.zsh

if [ -n "$ZSH_NAME" ]
then export PS4="(%?)%L%{`cursegreen`$}%c%{`cursemagenta`%}[%{`cursered``cursebold`%}%1N:%i%{`cursemagenta`%}]%{`curseyellow`%}%_%{`cursenorm`%}% # "
elif [ -n "$BASH" ]
then export PS4="+[\[`cursered;cursebold`\]\s\[`cursenorm`\]]\[`cursegreen`\]\W\[`cursenorm`\]\$ "
else export PS4="[sh $0] "
fi
# set -x

## We can compile to various languages, if we don't use neko File I/O.
# haxe -main org/neuralyte/sws/Root.hx -js sws.js
# haxe -main org/neuralyte/sws/Root.hx -swf9 sws.swf
# haxe -main org/neuralyte/sws/Root.hx -cpp sws.cpp
# haxelib run hxjava sws.hxp

sws.stable sync org > sync.log

if [ "$?" != 0 ]
then
	cat sync.log
	exit 120
fi

haxe -main org/neuralyte/sws/Root.hx -neko sws.n > haxe.log

if [ "$?" = 0 ]
then cat sync.log haxe.log
else
	cat haxe.log
	exit 123
fi

# nekotools boot sws.n
if ! nekotools boot sws.n
then errcode="$?" ; echo "Problem with nekotools" ; exit "$errcode"
fi


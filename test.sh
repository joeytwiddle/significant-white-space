#!/bin/sh

export PS4="[$0] "

set -e

./make.sh
# echo "Build successful."

mkdir -p data

if [ -n "$ZSH_NAME" ]
then export PS4="(%?)%L%{`cursegreen`$}%c%{`cursemagenta`%}[%{`cursered``cursebold`%}%1N:%i%{`cursemagenta`%}]%{`curseyellow`%}%_%{`cursenorm`%}% # "
elif [ -n "$BASH" ]
then export PS4="+[\[`cursered;cursebold`\]\s\[`cursenorm`\]]\[`cursegreen`\]\W\[`cursenorm`\]\$ "
else export PS4="[sh $0] "
fi
set -x

## TODO: This test is stupid.  We want a set of a few known files, with known results.
## Then we should check that processing with the new build gives the same results as that.
## (If the differences is an *improvement*, we replace the target results with the new results.)

## Another thing it could do is test that it can build after processing.
## Although we could simply check that the processed source of a recent version matches its target.

src="./org/neuralyte/sws/Root.hx"

## WARNING: safe-curl/decurl currently touch the original file.  This could be moved to sync.

./sws curl "$src.sws" data/Root.hx
./sws decurl "$src" data/Root.hx.sws
exit

cp -f data/Root.hx.sws data/Root.hx.sws.1
./sws curl data/Root.hx.sws data/Root.hx
./sws decurl data/Root.hx data/Root.hx.sws
cp -f data/Root.hx.sws data/Root.hx.sws.2

if ! cmp data/Root.hx.sws.1 data/Root.hx.sws.2
then
	echo "STABILITY TEST FAILED!  Second generation does not match first!"
	echo "  vimdiff org/neuralyte/sws/Root.hx data/Root.hx"
	echo "  vimdiff data/Root.hx.sws.1 data/Root.hx.sws.2"
	exit 17
fi

## OK so we often encounter minor changes when decurling code for the first time.
## If we want to see how we are performing on less-friendly code, we could compare the post-sync restuls against those of the last run, to indicate if we have made anything better or worse.
## We should have a folder full of test files.

# diff --side-by-side ./org/neuralyte/sws/Root.hx data/Root.hx

# diff --side-by-side data/Root.hx.sws.1 data/Root.hx.sws.2

# vimdiff ./org/neuralyte/sws/Root.hx data/Root.hx

# You can test sws sync on the source folder, e.g.:
#   % sws sync org/
# However if you start editing the Root.hx.sws file, be aware that sync will
# overwrite the original Root.hx file when it is next called!
# Maybe better to test sync on some code of your own that you have a backup of.


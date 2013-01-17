#!/bin/sh

# In case you have exported one which is too tough for /bin/sh
export PS4="[$0] "

set -e

./make.sh
# echo "Build successful."

mkdir -p data

mkdir -p _testing

cp -a data/* _testing/



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

cd _testing

# The binary we are evaluating is:
sws="../build/sws"
safe=""
# safe="safe-"

test_curl() {
	tip="$1"
	$sws "$safe"curl "$tip.sws" "$tip.curled"
	do_compare "$tip" "$tip.curled"
	# Do not drop these cmps.  They trigger the set -e and *are* the warning atm.
}

test_decurl() {
	tip="$1"
	$sws "$safe"decurl "$tip" "$tip.decurled"
	do_compare "$tip.sws" "$tip.decurled"
}

do_compare() {
	orig="$1"
	new="$2"
	if ! cmp "$1" "$2"
	then
		echo "[Test FAILED.] $new differs from $orig"
		diff "$orig" "$new"
		exit 2
	else
		if [ -z "$safe" ]
		then echo "Succeeded: $new === $orig"
		fi
	fi
}



# The test set:
set +x


test_curl   Root.hx
test_decurl Root.hx

test_curl   auto_scroll_keys.user.js
test_decurl auto_scroll_keys.user.js


echo "All tests completed successfully."
exit 0



## Old stuff:

## WARNING: safe-curl/decurl currently touch the original file.  This could be moved to sync.

# src="./src/sws/Root.hx"
# cp "$src" data/Root.hx

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


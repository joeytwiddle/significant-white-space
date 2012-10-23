#!/bin/sh

set -e

./build.sh
echo "Build successful."

mkdir -p data
cp -f ./org/neuralyte/sws/Root.hx data/

./sws decurl data/Root.hx data/Root.hx.sws
cp -f data/Root.hx.sws data/Root.hx.sws.1
./sws curl data/Root.hx.sws data/Root.hx
./sws decurl data/Root.hx data/Root.hx.sws
cp -f data/Root.hx.sws data/Root.hx.sws.2

if ! cmp data/Root.hx.sws.1 data/Root.hx.sws.2
then
	echo "Error: Something went WRONG!  data/Root.hx.sws.[12] do not match!"
fi

# diff --side-by-side ./org/neuralyte/sws/Root.hx data/Root.hx

# diff --side-by-side data/Root.hx.sws.1 data/Root.hx.sws.2

# vimdiff ./org/neuralyte/sws/Root.hx data/Root.hx

# You can test sws sync on the source folder, e.g.:
#   % sws sync org/
# However if you start editing the Root.hx.sws file, be aware that sync will
# overwrite the original Root.hx file when it is next called!
# Maybe better to test sync on some code of your own that you have a backup of.


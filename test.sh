#!/bin/sh

set -e

./build.sh
echo "Build successful."

mkdir -p data
cp -f ./org/neuralyte/sws/Root.hx data/

./sws decurl data/Root.hx
cp -f data/Root.hx.sws data/Root.hx.sws.1
./sws curl data/Root.hx
./sws decurl data/Root.hx
cp -f data/Root.hx.sws data/Root.hx.sws.2

# diff --side-by-side ./org/neuralyte/sws/Root.hx data/Root.hx

# diff --side-by-side data/Root.hx.sws.1 data/Root.hx.sws.2

# vimdiff ./org/neuralyte/sws/Root.hx data/Root.hx


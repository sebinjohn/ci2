#!/bin/bash -u

# Test framework
. ./wvtest.sh

. ./lib-ci

MYTMPDIR=$( Mktemp_Portable dir ${PWD} )
cd $MYTMPDIR

echo "1.0.0" > VERSION

versionOrig=$(cat VERSION)
# Check command works
WVPASS ../setup-version.sh
# Check command modifies version
WVPASSNE "$(cat VERSION)" "$versionOrig"
# Check command fails properly
rm VERSION
WVFAIL ../setup-version.sh

cd ..
rm -rf $MYTMPDIR

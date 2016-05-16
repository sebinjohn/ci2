#!/bin/bash -u

# Test framework
. ./wvtest.sh

ORIG_PWD=$PWD
cd tests/test-bump-versions/docker

WVPASS ../../../bump-docker-version.sh host.com:80/group/test 2
WVPASS grep "host.com:80/group/test:2" Dockerfile

WVPASS ../../../bump-docker-version.sh test 2
WVPASS grep "test:2" test/Dockerfile

cd $ORIG_PWD

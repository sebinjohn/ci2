#!/bin/bash -u

# Test framework
. ./wvtest.sh

ORIG_PWD=$PWD
cd tests/test-bump-versions/scala

# project/build.scala
WVPASS ../../../bump-scala-version-val.sh "edgeVersion" "2.0"
WVPASS grep '  val edgeVersion        = "2.0"' project/build.scala

# project/plugins.sbt
WVPASS ../../../bump-scala-version-val.sh "uniformVersion" "2.0"
WVPASS grep 'val uniformVersion = "2.0"' project/plugins.sbt

cd $ORIG_PWD

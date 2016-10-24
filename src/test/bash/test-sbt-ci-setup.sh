#!/bin/bash -u
# Test the sbt-ci-setup script.

# Test framework
. ${TEST_PATH}/wvtest.sh
. ${MAIN_PATH}/lib-ci

#----------------------------------------------------
# Setup Fake environment
#----------------------------------------------------

TMPDIR=$( Mktemp_Portable dir )
cd $TMPDIR

#----------------------------------------------------
# Run tests
#----------------------------------------------------

# Check script succeeds
WVPASS ${MAIN_PATH}/sbt-ci-setup.sh

# Check credentials file
if [[ ! -e ci/ivy.credentials ]]; then
  echoerr "ivy.credentials not created."
  exit 1
fi

# Check that a helpful error message is printed when ARTIFACTORY_USERNAME is not set
unset CI_TEST_RUNNING
WVFAIL bash -c "${MAIN_PATH}/sbt-ci-setup.sh 2>stderr.log"
WVPASS grep -q "^ERROR: Artifactory credentials were not injected into this build" stderr.log

#----------------------------------------------------
# Cleanup
#----------------------------------------------------

cd ..
rm -rf $TMPDIR

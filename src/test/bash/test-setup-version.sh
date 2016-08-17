#!/bin/bash -u

# Test framework
. ${TEST_PATH}/wvtest.sh
. ${MAIN_PATH}/lib-ci

MYTMPDIR=$( Mktemp_Portable dir ${PWD} )
cd $MYTMPDIR

CI_SYSTEM=$(CI_Env_Get)

CI_Env_Adapt $(CI_Env_Get)

echo "1.0.0" > VERSION

versionOrig=$(cat VERSION)


# Check command works
WVPASS ${MAIN_PATH}/setup-version.sh
# Check command modifies version
WVPASSNE "$(cat VERSION)" "$versionOrig"
# Check that version file is created
WVPASS [ -f $CI_VERSION_FILE ]

# Check command fails properly
rm VERSION
rm $CI_VERSION_FILE
WVFAIL ${MAIN_PATH}/setup-version.sh

echo "1.0.0" > VERSION

# Check that command can't be run twice
WVPASS ${MAIN_PATH}/setup-version.sh
WVFAIL ${MAIN_PATH}/setup-version.sh
rm $CI_VERSION_FILE

# get_version tests
export ${CI_SYSTEM}_COMMIT=adc83b19e793491b1c6ea0fd8b46cd9f32e592fc
export ${CI_SYSTEM}_BRANCH=master
export ${CI_SYSTEM}_PULL_REQUEST=false
WVPASS ${MAIN_PATH}/setup-version.sh
echo "NEW_VERSION=$(Version_Get)"
WVPASS grep -oE "1.0.0-[0-9]{14}-adc83b1" $CI_VERSION_FILE
rm $CI_VERSION_FILE

# On a branch with a / in the name
export ${CI_SYSTEM}_BRANCH=test/branch
export ${CI_SYSTEM}_PULL_REQUEST=false
WVPASS ${MAIN_PATH}/setup-version.sh
echo "NEW_VERSION=$(Version_Get)"
WVPASS grep -oE "1.0.0-[0-9]{14}-adc83b1-test_branch" $CI_VERSION_FILE
rm $CI_VERSION_FILE

# On a branch
export ${CI_SYSTEM}_BRANCH=testbranch
export ${CI_SYSTEM}_PULL_REQUEST=false
WVPASS ${MAIN_PATH}/setup-version.sh
echo "NEW_VERSION=$(Version_Get)"
WVPASS grep -oE "1.0.0-[0-9]{14}-adc83b1-testbranch" $CI_VERSION_FILE
rm $CI_VERSION_FILE

# With a pull request
export ${CI_SYSTEM}_PULL_REQUEST=1234
WVPASS ${MAIN_PATH}/setup-version.sh
echo "NEW_VERSION=$(Version_Get)"
WVPASS grep -oE "1.0.0-[0-9]{14}-adc83b1-PR1234" $CI_VERSION_FILE
rm $CI_VERSION_FILE

rm -rf $MYTMPDIR

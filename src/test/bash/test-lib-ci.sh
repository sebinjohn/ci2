#!/bin/bash -u
# Test the lib-version library

# Test framework
. ${TEST_PATH}/wvtest.sh
. ${MAIN_PATH}/lib-ci

MYTMPDIR=$( Mktemp_Portable dir ${PWD} )

WVPASSEQ "$?" "0"

# get_CI_env tests
CI_SYSTEM=$(CI_Env_Get)
WVPASSNE $CI_SYSTEM ""

# adapt_CI_env tests
CI_Env_Adapt $CI_SYSTEM
# Broadly we just check that most of the env vars get populated
WVPASS [ ! -z $CI_NAME ]
WVPASS [ ! -z $CI_REPO ]
WVPASS [ ! -z $CI_BRANCH ]
WVPASS [ ! -z $CI_COMMIT ]

cd $MYTMPDIR

# is_release tests
# On master
export ${CI_SYSTEM}_BRANCH=master
export ${CI_SYSTEM}_PULL_REQUEST=false
echo "IS_RELEASE=$(Is_Release)"
WVPASS [ $(Is_Release) == 0 ]

# On another branch specified as release branch
export ${CI_SYSTEM}_BRANCH=testbranch
export ${CI_SYSTEM}_PULL_REQUEST=false
export RELEASE_BRANCHES="other testbranch"
echo "IS_RELEASE=$(Is_Release)"
WVPASS [ $(Is_Release) == 0 ]

# On master and with specified release branches
export ${CI_SYSTEM}_BRANCH=master
export ${CI_SYSTEM}_PULL_REQUEST=false
export RELEASE_BRANCHES="testbranch"
echo "IS_RELEASE=$(Is_Release)"
WVPASS [ $(Is_Release) == 0 ]

# On master and with specified release branches
export ${CI_SYSTEM}_BRANCH=branch
export ${CI_SYSTEM}_PULL_REQUEST=false
export RELEASE_BRANCHES="testbranch branch-master"
echo "IS_RELEASE=$(Is_Release)"
WVPASS [ $(Is_Release) == 1 ]

# Not on a release branch
export ${CI_SYSTEM}_BRANCH=testbranch
export ${CI_SYSTEM}_PULL_REQUEST=false
unset RELEASE_BRANCHES
echo "IS_RELEASE=$(Is_Release)"
WVPASS [ $(Is_Release) == 1 ]

# Pull request to a release branch
export ${CI_SYSTEM}_BRANCH=master
export ${CI_SYSTEM}_PULL_REQUEST=true
echo "IS_RELEASE=$(Is_Release)"
WVPASS [ $(Is_Release) == 1 ]

# Local CI should be enabled when we enable the flag
export ENABLE_LOCAL_CI=yes
WVPASS CI_Env_Adapt "LOCAL"
export ENABLE_LOCAL_CI=

# Test Hostname_From_Url
WVPASS [ $(Hostname_From_Url "http://test/some/args?hello") = "test" ]
WVPASS [ $(Hostname_From_Url "http://test.example.com/some/args?hello") = "test.example.com" ]
WVPASS [ $(Hostname_From_Url "https://test2.ports.com:443/some/args?hello") = "test2.ports.com:443" ]

# Test atexit
cat << EOF > .test_lib_ci_atexit.sh
#!/bin/bash -x
. ${MAIN_PATH}/lib-ci
trap "atexit_commands; exit 0" INT TERM EXIT
echo "In test script"
atexit echo "Produced by atexit hook"
atexit touch .made_by_atexit
EOF
chmod +x .test_lib_ci_atexit.sh
WVPASS ./.test_lib_ci_atexit.sh
WVPASS [ -e .made_by_atexit ]
rm .made_by_atexit
rm .test_lib_ci_atexit.sh

# Check the atexit commands don't propagate
cat << EOF > .test_lib_ci_atexit_fail.sh
#!/bin/bash -x
. ${MAIN_PATH}/lib-ci
trap "atexit_commands; exit 0" INT TERM EXIT
EOF
chmod +x .test_lib_ci_atexit_fail.sh
WVPASS ./.test_lib_ci_atexit_fail.sh
WVPASS [ ! -e .made_by_atexit ]
rm .test_lib_ci_atexit_fail.sh

##
# Test which_sbt function
##

# Check that which_sbt prints deprecation message
WVPASS echo $(which_sbt 2>&1) | grep DEPRECATION\ WARNING

# Check that which_sbt prints compatibility warning message
WVPASS echo $(which_sbt 2>&1) | grep COMPATIBILITY\ WARNING

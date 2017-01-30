#!/bin/bash -u
# Test the ci-push-branch script. This is not comprehensive, but checks the
# logic of when it should push to the branch.

# Test framework
. ${TEST_PATH}/wvtest.sh
. ${MAIN_PATH}/lib-ci

ORIG_PATH=$PATH
TMPDIR=$( Mktemp_Portable dir )
TMPPATH=$( Mktemp_Portable dir )

#----------------------------------------------------
# Setup Fake environment
#----------------------------------------------------

cd $TMPDIR
export CI_DIR=$TMPDIR
export PATH=$TMPPATH:$PATH

# Setup fake binaries
cat << EOF | tee $TMPPATH/ssh-agent $TMPPATH/ssh-add $TMPPATH/git >> /dev/null
#!/bin/bash
# This is a fake binary for testing purposes. It always succeeds.
echo "fake-\$(basename "\$0") \$@"
exit 0
EOF
chmod +x $TMPPATH/ssh-agent $TMPPATH/ssh-add $TMPPATH/git

# Setup fake keyfile
mkdir .ci
touch .ci/deploy-key.pem

#----------------------------------------------------
# Run tests
#----------------------------------------------------

# Check we enforce the branch argument
WVFAIL ${MAIN_PATH}/ci-push-branch.sh

# Check we enforce the keyfile
mv .ci/deploy-key.pem .ci/deploy-key2.pem
WVFAIL ${MAIN_PATH}/ci-push-branch.sh somebranch
mv .ci/deploy-key2.pem .ci/deploy-key.pem

# Happy path
WVPASS ${MAIN_PATH}/ci-push-branch.sh somebranch

#----------------------------------------------------
# Cleanup
#----------------------------------------------------

cd ..
rm -rf $TMPDIR $TMPPATH
export PATH=$ORIG_PATH

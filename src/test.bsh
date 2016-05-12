#!/bin/bash

. ./lib-ci

function init() {
  # Always show the CI env
  echo ":: [$0] Dumping CI environment..."
  CI_Env_Dump
}

function cleanup() {
  # 
  # all tests create .tmp-blah directories
  # we remote them here for purity
  #
  echo ":: [$0] cleanup temp dirs"
  find . -name '_tmp-*' | xargs -L1 -Ixx sh -c 'echo "rm -rf xx"  && rm -rf xx'
}

function run_tests() {
  # Run the tests
  for i in $(find tests -mindepth 1 -name 'test-*' -type f -print | sort); do
      echo ":: [$0] $i"
      bash $i
      if [ $? != 0 ]; then
          echo ":: [$0] previous test [$i] failed - not continuing"
          cleanup
          exit 1
      fi
  done
  echo ":: [$0] All tests complete."
}

#
# main()
#
init
run_tests
cleanup



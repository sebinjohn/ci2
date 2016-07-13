#!/bin/bash
#   Copyright 2016 Commonwealth Bank of Australia
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   Pushes the given branch of the currently checked out git repository.
#
#   Usage:
#   ./ci-push-branch <branch>
#
#   Example:
#   ./ci-push-branch gh-pages
#
#   Important:
#   You need to place the deployment key at .ci/deploy-key.pem in order to
#   authenticate with git.

set -u

# Library import helper
function import() {
    IMPORT_PATH="${BASH_SOURCE%/*}"
    if [[ ! -d "$IMPORT_PATH" ]]; then IMPORT_PATH="$PWD"; fi
    . $IMPORT_PATH/$1
    [ $? != 0 ] && echo "$1 import error" 1>&2 && exit 1
}

import lib-ci

CI_Env_Adapt $(CI_Env_Get)

# Gather the required parameters
branch=$1
keyFile=.ci/deploy-key.pem

if [ -z "$branch" ]; then
    echoerr "No branch specified. Exiting with error."
    exit 1
fi

if [ ! -e $keyFile ]; then
    echoerr "$keyFile does not exist. Exiting with error."
    exit 1
fi

if [ "$(Is_Release)" = "0" ] || [ ! -z $FORCE_PUBLISH ]; then
    # Initialise SSH agent with CI key
    eval "$(ssh-agent -s)"
    chmod 600 $keyFile
    ssh-add $keyFile

    echo "Pushing $branch ..."
    git push --quiet git@github.com:$CI_REPO.git $branch
else
    echo "Not on master. Not pushing $branch."
fi

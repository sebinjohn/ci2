#!/bin/bash -x
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
#   Usage:
#   ./ci/sbt-ci-build-doc.sh <documentation root URL> \
#       <documentation source code URL base>
#
#   Example:
#   ./ci/sbt-ci-build-doc.sh https://commbank.github.io/ \
#       https://github.com/CommBank/maestro/ \
#
#   Important:
#   The second parameter is a template string which is fed into unidoc to build
#   documentation. If you don't know what this is, then just copy the above
#   example and change the project name for your project.
#
#   How it works:
#   Notice in do_build_doc we play some games with the GIT_WORK_TREE. This is
#   is done so we can checkout the gh_pages branch to a subdirectory, and update
#   it without needing to pull it remotely.

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

SBT=$(which_sbt) || exit 1

# Document URL root
docUrlRoot="$1"
[ -z "$docUrlRoot" ] && echoerr "Must specify a document URL root!" && exit 1

# Document Source URL Template
docSourceUrlTemplate="$2"
[ -z "$docSourceUrlTemplate" ] && echoerr "Must specify a document source template!" && exit 1

version=$(Version_Get)

if [ ! -e src/site/_config.yml ]; then
    echo "src/site/_config.yml does not exist. Aborting."
    exit 1
fi

echo "" >> src/site/_config.yml
sed -i '/^releaseVersion: .*/d' src/site/_config.yml
echo "releaseVersion: $version" >> src/site/_config.yml

# Builds documentation.
function do_build_doc() {
    mkdir -p target/site

    echo "Creating documentation..."
    $SBT -Dsbt.global.base=$CI_BUILD_DIR \
        "set uniform.docRootUrl := \"$docUrlRoot\"" \
        "set uniform.docSourceUrl := \"$docSourceUrlTemplate\"" \
        make-site
    if [ $? != 0 ]; then
        echoerr "Error building documentation"
        exit 1
    fi
}

# Should documentation be built?
do_build_doc

# Should documentation be published?
if [ $CI_BRANCH = "master" ] || [ ! -z $FORCE_PUBLISH ]; then
    Publish_Subdirectory_To_Branch gh-pages target/site "CI automatic documentation ($CI_BUILD_URL)"
else
    echoerr "This is not the master branch so documentation is not being published."
fi

exit 0

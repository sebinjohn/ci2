#!/bin/bash
#   Copyright 2014 Commonwealth Bank of Australia
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
# IMPORTANT: USE THIS SCRIPT AND ONLY THIS SCRIPT TO SET UP THE VERSION NUMBER.
# THIS NEEDS TO BE DONE AT THE BEGINNING OF THE BUILD AND CAN ONLY BE DONE ONCE.
#

# Sets up an Omnia compliant version number from a VERSION file in the current
# working directory.
# Supports bot sbt and txt mode.

set -u

# Library import helper
function import() {
    IMPORT_PATH="${BASH_SOURCE%/*}"
    if [[ ! -d "$IMPORT_PATH" ]]; then IMPORT_PATH="$PWD"; fi
    . $IMPORT_PATH/$1
    [ $? != 0 ] && echo "$1 import error" 1>&2 && exit 1
}

import lib-ci

set -o errexit

CI_Env_Adapt $(CI_Env_Get)

if [[ -f $CI_VERSION_FILE ]]; then
   echoerr ".VERSION has already been set"
   echoerr ".VERSION should only be set once"
   exit 1
fi

# Get a version number based on the Omnia standard:
# major.minor.path-commish-timestamp for master branch
# major.minor.path-commish-timestamp-PRNN for pull request NN
# major.minor.path-commish-timestamp-branchname for branch branchname.
# Expects the source version number to be input.
function Version_Setup() {
    CI_Env_Adapt $(CI_Env_Get)

    local source_version=$(echo "$1" | grep -E -o "[0-9]+\.[0-9]+\.[0-9]+")
    if [ -z $source_version ]; then
        echo "Bad semantic version number. Version contents: $1" 1>&2
        exit 1
    fi

    local branch=${CI_BRANCH//[^[:alnum:]_.-]/_}
    local ts=$(date "+%Y%m%d%H%M%S")
    local commitish=${CI_COMMIT:0:7}
    local version="$source_version-$ts-$commitish"

    local new_version=""
    if [ "$CI_PULL_REQUEST" != "false" ] && [ ! -z $CI_PULL_REQUEST ]; then
        new_version="$version-PR$CI_PULL_REQUEST"
    elif [ $CI_BRANCH == "master" ]; then
        new_version="$version"
    else
        new_version="$version-$branch"
    fi

    echo $new_version > $CI_VERSION_FILE
    echo $new_version
}


mode=${1:-"txt"}
if [[ ${mode} == "sbt" ]]; then
    if [ ! -f "version.sbt" ]; then
        echo "version.sbt file not found." 1>&2
        exit 1
    fi

    new_version=$(Version_Setup "$(cat version.sbt)")
    if [ -z $new_version ]; then
        exit 1
    fi

    VERSION=$new_version
    echo "version in ThisBuild := \"$new_version\"" > version.sbt

elif [[ ${mode} == "txt" ]]; then
    file=""
    if [[ -f ${PWD}/VERSION ]]; then
        file=${PWD}/VERSION
    elif [[ -f ${PWD}/VERSION.txt ]]; then
        file=${PWD}/VERSION.txt
    else
        echoerr "Couldn't find a VERSION or VERSION.txt file"
        exit 1
    fi

    new_version=$(Version_Setup "$(cat $file)")
    VERSION=$new_version
    echo $new_version > $file
else
    echoerr "Can't set up version in $mode. $mode is not a supported mode."
    exit 1
fi

exit 0

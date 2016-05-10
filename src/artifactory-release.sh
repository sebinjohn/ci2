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

set -e

REPO_PATH=$1
ARTIFACT=$2
METADATA=$3

ARTIFACTORY_URL=${ARTIFACTORY_URL:-"https://commbank.artifactoryonline.com/commbank"}

if [ -z "$REPO_PATH" ] || [ -z "$ARTIFACT" ]; then
    echo "Upload an artifact to an Artifactory repository."
    echo "usage: $0 repo/path /local/path/to/artifact [meta1=val;meta2=val]"
    exit 1
fi

if [ -z "$ARTIFACTORY_API_KEY" ]; then
    echo "Error: ARTIFACTORY_API_KEY environment variable is not set"
    exit 1
fi

set -u

ARTIFACTORY_AUTH="X-JFrog-Art-Api: $ARTIFACTORY_API_KEY"
ARTIFACT_NAME=$(basename "$ARTIFACT")

status=$(curl --silent --output /dev/null --write-out "%{http_code}" \
        -H "$ARTIFACTORY_AUTH" \
        "$ARTIFACTORY_URL/api/storage/$REPO_PATH/$ARTIFACT_NAME")

if [ "$status" = "404" ]; then

    if [ "$TRAVIS_PULL_REQUEST" = "false" ] && [ "$TRAVIS_BRANCH" = "master" ]; then
        echo "Uploading '$ARTIFACT_NAME':"
        curl --silent --fail \
            -H "$ARTIFACTORY_AUTH" \
            -T "$ARTIFACT" \
            "$ARTIFACTORY_URL/$REPO_PATH/$ARTIFACT_NAME;$METADATA"
    else
        echo "Not on master. Nothing to deploy"
    fi

elif [ "$status" = "200" ]; then
    echo "Error: Artifact named '$ARTIFACT_NAME' already exists!"
    exit 1
else
    echo "Error: Failed to determine artifact status of '$ARTIFACT_NAME'"
    exit 1
fi


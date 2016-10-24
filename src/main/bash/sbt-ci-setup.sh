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
#   Creates the credential file to allow access to artifactory online.

# Artifactory credentials aren't required when testing
if [ -z "$CI_TEST_RUNNING" ]; then
    if [ -z "$ARTIFACTORY_USERNAME" ]; then
	cat >&2 <<-EOF
		ERROR: Artifactory credentials were not injected into this build
		Possible causes:
		1. This is a pull request originating from a fork of the repo.
		   Sorry, this scenario is not supported. Please close the PR, push your branch
		   to the target repo, and raise a new PR from there.
		2. Encrypted artifactory credentials have not been configured for this Travis build.
		   Refer to the README at https://github.com/CommBank/ci2 for further instructions.
	EOF
	exit 1
    fi
    set -u
fi

mkdir -p ci

cat > ci/ivy.credentials <<EOF
realm=Artifactory Realm
host=commbank.artifactoryonline.com
user=$ARTIFACTORY_USERNAME
password=$ARTIFACTORY_PASSWORD
EOF

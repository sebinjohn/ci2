# ci2

[![Build Status](https://travis-ci.org/CommBank/ci2.svg?branch=master)](https://travis-ci.org/CommBank/ci2)
[![Coverage Status](https://coveralls.io/repos/github/CommBank/ci2/badge.svg?branch=master)](https://coveralls.io/github/CommBank/ci2?branch=master)

Scripts used for Continuous Integration

## Overview

ci2 is a "set" of CI helper scripts. To assist with pushing, and publishing versions of code.

To depend on this REPO add the following to your ``.travis.yml`` / ``.drone.yml``

```
curl https://commbank.artifactoryonline.com/commbank/binaries/ci/ci-<VERSION>.tar.gz | tar xz
```

Latest releases can be found here [ci2 releases](https://commbank.artifactoryonline.com/commbank/binaries/ci/)

## Disclaimer

This module is intended to be "pulled" in using curl or wget, as an external dependency. 
This is the only supported approach.

If you don't use a versioned approach for pulling in these scripts, there is no guarantee of your build succeeding, as ci2 may be updated at any time.

## Scripts 

* ``lib-ci`` - Common BASH functions used by all the scripts
* ``artifactory-release.sh`` - Release a file (binary, archive, etc) to an artifactory server
* ``bump-docker-version.sh`` - Support script to set a version of Dockerfile, before building
* ``bump-scala-version.sh`` - Support script to set a versions in scala builds, before building
* ``bump-scala-version-depend.sh`` - Support script to set a versions in scala builds, before building
* ``bump-scala-version-val.sh`` - Support script to set a versions in scala builds, before building
* ``ci-nonrelease.sh`` - Perform an action, only if the branch/PR is a NON-release branch
* ``ci-release.sh`` - Perform the action, only if the branch/PR is a release branch
* ``ci-publish-site.sh`` - Commit a site's directory as the sole content of a given branch
* ``ci-push-branch.sh`` - Push a branch to the github repo
* ``dockermake.sh`` - Build all ``Dockerfile`` images in the repo
* ``docker-support.sh`` - ``setup`` and ``publish`` docker images (implies a build step between each)
* ``gh-commit-comment.sh`` - Uses the GitHub API to create a comment against a specific git commit-sha
* ``sbt-ci-build-doc.sh`` - Uses sbt to build documentation for the project and commit to ``gh-pages`` branch
* ``sbt-ci-deploy.sh`` - Uses sbt to deploy your artifact
* ``sbt-ci-setup.sh`` - Creates the SBT credentials file
* ``sbt-ci-setup-version.sh`` - Sets up the correct "CI" version for the SBT project
* ``setup-version.sh`` - Replaces the VERSION file with a common ``ver-date-commish``

## Writing New Scripts

If you find a use case that does not match the above provided list, then please look at 

* existing scripts; and
* the matching ``src/tests/`` folder for examples of how to write tests for your new script

### Testing

The Tests can be executed locally, (i.e. SANS a CI environment).

```
cd src/tests/bash
ENABLE_LOCAL_CI=1 ./run-tests.sh
```

## Principles

These are some underlying principles for how we do CI and in particular how we design and utilise 
these scripts.

* In build configurations the building and unit testing of the code should not require any CI 
  scripts and be expressed in a similar way that a user would run locally.
* Our standard versioning approach is semantic version plus the build time stamp plus the commish.
* We predominantly utilise our CI scripts to customise the deployment and publication process. This 
  is custom to our environments and there is no expectation that the user will do a publish manually.
* We use CI scripts to set up custom version for builds in a way that is transparent to the build
  tooling. Users provide the semantic version in a way that is suitable for their particular tooling
  and the CI scripts append the time stamp and commish at the beginning of the build.
  e.g. ``(file) VERSION: 2.0.3`` --> ``ci-2.0.3-20160517230553-92fd78d``

## Usage

### For Travis

1. Create a `.travis.yml` file in the top level directory of the project. Use some of the other projects' `.travis.yml`
   file as a template.
2. Install the travis client. Instructions are available at https://github.com/travis-ci/travis.rb. **Please be aware that the installation and usage of the travis client often result in network and SSL Errors from within the office network (including wifi). Tethering to  a 4G device is one workaround for this.**
3. Login. `travis login --pro` or `travis login --org`.
4. From project folder (same directory as `.travis.yml`), enable your project with Travis CI by running the command:
   `travis enable --pro` or `travis enable --org`.
5. Add the encrypted artifactory username and password by running these commands in the same directory as `.travis.yml`:
   - `travis encrypt ARTIFACTORY_USERNAME=... --add env.global`
   - `travis encrypt ARTIFACTORY_PASSWORD=... --add env.global`
6. [Optional to publish SBT project]:
   1. `install` steps:
      1. `ci/sbt-ci-setup.sh` to create the artifactory credentials file
      1. `ci/sbt-ci-setup-version.sh` to generate version with date + commish
   1. `script` steps:
      1. `sbt -Dsbt.global.base=$TRAVIS_BUILD_DIR/ci '; test; package'` to test and package artifacts
      1. `ci/sbt-ci-deploy.sh <type> <url> <repo>` to publish artifacts
7. [Optional to publish documentation] **For public repos only** Create a branch called `gh-pages` for the project and push it to github. Then add the private key for omnia-bamboo as an encrypted file.
   1. Get the private key (ask on Gitter and someone will help)
   1. Create a folder in the repo `.ci`
   1. `travis encrypt-file <path-private-key> .ci/deploy-key.enc -w .ci/deploy-key.pem --add`
   1. For sbt builds add `ci/sbt-build-doc.sh <url-root> <url-template> && ci/ci-push-branch.sh gh-pages` to the build commands.

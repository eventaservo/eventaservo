#!/bin/bash

docker run \
  -it \
  --rm \
  -v "$(pwd)":/usr/local/src/your-app \
  githubchangeloggenerator/github-changelog-generator \
  --no-unreleased \
  --user eventaservo \
  --project eventaservo \
  -t $GITHUB_CHANGELOG_GENERATOR_TOKEN

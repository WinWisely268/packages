#!/usr/bin/env bash

GITHUB_SHA=$(git log --max-count=1 --pretty=format:"%H")
GITHUB_REF=$(git rev-parse --abbrev-ref HEAD)
IMAGE="maintemplate"
PROJECT="maintemplate"
REGISTRY_HOSTNAME="localhost:5000"
DEPLOYMENT_NAME="maintemplate"
RELEASE_CHANNEL="ci"
FLUTTER_CHANNEL="beta"
URL="getcouragenow.org"
LOCALES=[\"en\",\"fr\",\"es\",\"it\",\"de\",\"ur\"]

perl -i -pe 's/\\?version\=#\{ref\}/version\='$GITHUB_SHA'/g' flutter/web/index.html
perl -i -pe 's/#\{channel_url\}/'$PROJECT.$RELEASE_CHANNEL.$URL'/g' flutter/web/assets/assets/env.json
perl -i -pe 's/#\{channel_url_native\}/grpc.'$PROJECT.$RELEASE_CHANNEL.$URL'/g' flutter/web/assets/assets/env.json
perl -i -pe 's/#\{channel_githash\}/'$GITHUB_SHA'@g' flutter/web/assets/assets/env.json
perl -i -pe 's/#\{flutter_channel\}/'$FLUTTER_CHANNEL'/g' flutter/web/assets/assets/env.json
perl -i -pe 's/\"#\{locales\}\"/'$LOCALES'/g' flutter/web/assets/assets/env.json
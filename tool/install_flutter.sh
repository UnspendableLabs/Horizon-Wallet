#!/usr/bin/env bash
set -euo pipefail

readonly FLUTTER_VERSION=3.35.4

if [[ -d flutter/.git ]]; then
  git -C flutter fetch --depth 1 origin "refs/tags/${FLUTTER_VERSION}"
  git -C flutter checkout --detach FETCH_HEAD
else
  git clone \
    --depth 1 \
    --branch "${FLUTTER_VERSION}" \
    https://github.com/flutter/flutter.git \
    flutter
fi

flutter/bin/flutter config --enable-web
flutter/bin/flutter pub get


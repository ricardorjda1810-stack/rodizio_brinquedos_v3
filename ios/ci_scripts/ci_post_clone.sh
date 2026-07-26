#!/bin/sh
set -eu

: "${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is required}"

PROJECT_ROOT="$CI_PRIMARY_REPOSITORY_PATH"
FLUTTER_VERSION="3.41.5"
FLUTTER_SDK_PATH="$PROJECT_ROOT/.xcode-cloud/flutter"
PODFILE_LOCK="$PROJECT_ROOT/ios/Podfile.lock"

cd "$PROJECT_ROOT"

echo "Preparing Flutter $FLUTTER_VERSION for Xcode Cloud."

if [ ! -x "$FLUTTER_SDK_PATH/bin/flutter" ]; then
  mkdir -p "$(dirname "$FLUTTER_SDK_PATH")"
  git clone \
    --depth 1 \
    --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git \
    "$FLUTTER_SDK_PATH"
fi

export PATH="$FLUTTER_SDK_PATH/bin:$PATH"

flutter --version | grep -F "Flutter $FLUTTER_VERSION "
flutter config --no-analytics
flutter precache --ios
flutter pub get

GENERATED_XCCONFIG="$PROJECT_ROOT/ios/Flutter/Generated.xcconfig"
if [ ! -f "$GENERATED_XCCONFIG" ]; then
  echo "error: Flutter did not generate $GENERATED_XCCONFIG" >&2
  exit 1
fi

if ! command -v pod >/dev/null 2>&1; then
  COCOAPODS_VERSION="$(awk '/^COCOAPODS: / { print $2 }' "$PODFILE_LOCK")"
  if [ -z "$COCOAPODS_VERSION" ]; then
    echo "error: CocoaPods version not found in $PODFILE_LOCK" >&2
    exit 1
  fi

  echo "Installing CocoaPods $COCOAPODS_VERSION."
  gem install \
    --user-install \
    cocoapods \
    --version "$COCOAPODS_VERSION" \
    --no-document
  GEM_USER_BIN="$(ruby -e 'print Gem.user_dir')/bin"
  export PATH="$GEM_USER_BIN:$PATH"
fi

pod --version

cd "$PROJECT_ROOT/ios"
pod install --deployment

PODS_RUNNER_SUPPORT="$PROJECT_ROOT/ios/Pods/Target Support Files/Pods-Runner"
for xcfilelist in \
  "$PODS_RUNNER_SUPPORT/Pods-Runner-frameworks-Release-input-files.xcfilelist" \
  "$PODS_RUNNER_SUPPORT/Pods-Runner-frameworks-Release-output-files.xcfilelist"
do
  if [ ! -f "$xcfilelist" ]; then
    echo "error: CocoaPods did not generate $xcfilelist" >&2
    exit 1
  fi
done

echo "Flutter and CocoaPods dependencies are ready for Archive - iOS."

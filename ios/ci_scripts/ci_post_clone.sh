#!/bin/sh
set -eu

: "${CI_PRIMARY_REPOSITORY_PATH:?CI_PRIMARY_REPOSITORY_PATH is required}"

PROJECT_ROOT="$CI_PRIMARY_REPOSITORY_PATH"
FLUTTER_VERSION="3.41.5"
FLUTTER_SDK_PATH="$PROJECT_ROOT/.xcode-cloud/flutter"
BUNDLER_VERSION="2.4.22"
IOS_ROOT="$PROJECT_ROOT/ios"
GEMFILE="$IOS_ROOT/Gemfile"

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

cd "$IOS_ROOT"

ORIGINAL_RUBYOPT="${RUBYOPT:-}"
RUBYOPT=""
for ruby_option in $ORIGINAL_RUBYOPT
do
  case "$ruby_option" in
    -rbundler/setup|-rlogger) ;;
    *) RUBYOPT="${RUBYOPT:+$RUBYOPT }$ruby_option" ;;
  esac
done
export RUBYOPT

GEM_USER_BIN="$(ruby -e 'print Gem.user_dir')/bin"
export PATH="$GEM_USER_BIN:$PATH"

if ! bundle "_${BUNDLER_VERSION}_" --version >/dev/null 2>&1; then
  echo "Installing Bundler $BUNDLER_VERSION."
  gem install \
    --user-install \
    bundler \
    --version "$BUNDLER_VERSION" \
    --no-document
fi

BUNDLER_OUTPUT="$(bundle "_${BUNDLER_VERSION}_" --version)"
if [ "$BUNDLER_OUTPUT" != "Bundler version $BUNDLER_VERSION" ]; then
  echo "error: Expected Bundler $BUNDLER_VERSION, got $BUNDLER_OUTPUT" >&2
  exit 1
fi

RUBY_DEPS_ROOT="${CI_DERIVED_DATA_PATH:-$PROJECT_ROOT/.xcode-cloud}/bundle"
export BUNDLE_GEMFILE="$GEMFILE"
export BUNDLE_PATH="$RUBY_DEPS_ROOT"
export BUNDLE_DEPLOYMENT="true"
export BUNDLE_DISABLE_SHARED_GEMS="true"
export BUNDLE_JOBS="4"
export BUNDLE_RETRY="3"

bundle "_${BUNDLER_VERSION}_" check ||
  bundle "_${BUNDLER_VERSION}_" install

# ActiveSupport 6.1 needs Logger, but Bundler must select the locked version first.
normalize_rubyopt() {
  normalized_rubyopt=""
  for ruby_option in ${RUBYOPT:-}
  do
    case "$ruby_option" in
      -rbundler/setup|-rlogger) ;;
      *) normalized_rubyopt="${normalized_rubyopt:+$normalized_rubyopt }$ruby_option" ;;
    esac
  done
  RUBYOPT="${normalized_rubyopt:+$normalized_rubyopt }-rbundler/setup -rlogger"
  export RUBYOPT
}

RUBYOPT="$ORIGINAL_RUBYOPT"
normalize_rubyopt

POD_VERSION="$(bundle "_${BUNDLER_VERSION}_" exec pod --version)"
if [ "$POD_VERSION" != "1.16.2" ]; then
  echo "error: Expected CocoaPods 1.16.2, got $POD_VERSION" >&2
  exit 1
fi

bundle "_${BUNDLER_VERSION}_" exec ruby \
  -e 'require "nkf"; require "xcodeproj"; puts Xcodeproj::VERSION'

bundle "_${BUNDLER_VERSION}_" exec pod install --deployment

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

#!/bin/sh

set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
ios_dir="$(CDPATH= cd -- "$script_dir/.." && pwd)"
bundle_id="com.rodiziobrinquedos.v3"

case "${FIREBASE_ENV:-}" in
  staging)
    source_plist="$ios_dir/Firebase/Staging/GoogleService-Info.plist"
    expected_project_id="rodizio-de-brinquedos-staging"
    expected_app_id="1:346014753075:ios:a014794eac1aa24cf51e46"
    expected_sender_id="346014753075"
    ;;
  production)
    source_plist="$ios_dir/Runner/GoogleService-Info.plist"
    expected_project_id="rodizio-de-brinquedos"
    expected_app_id="1:713670498412:ios:a73ec27898054ea1f2e049"
    expected_sender_id="713670498412"
    ;;
  *)
    echo "error: FIREBASE_ENV must be explicitly set to staging or production." >&2
    exit 1
    ;;
esac

if [ ! -f "$source_plist" ]; then
  echo "error: Firebase plist is missing for FIREBASE_ENV=$FIREBASE_ENV." >&2
  exit 1
fi

if ! /usr/bin/plutil -lint "$source_plist" >/dev/null; then
  echo "error: Firebase plist is not syntactically valid for FIREBASE_ENV=$FIREBASE_ENV." >&2
  exit 1
fi

read_plist_value() {
  /usr/libexec/PlistBuddy -c "Print :$1" "$source_plist" 2>/dev/null || true
}

actual_project_id="$(read_plist_value PROJECT_ID)"
actual_app_id="$(read_plist_value GOOGLE_APP_ID)"
actual_sender_id="$(read_plist_value GCM_SENDER_ID)"
actual_bundle_id="$(read_plist_value BUNDLE_ID)"

if [ "$actual_project_id" != "$expected_project_id" ]; then
  echo "error: Firebase PROJECT_ID does not match FIREBASE_ENV=$FIREBASE_ENV." >&2
  exit 1
fi

if [ "$actual_app_id" != "$expected_app_id" ]; then
  echo "error: Firebase GOOGLE_APP_ID does not match FIREBASE_ENV=$FIREBASE_ENV." >&2
  exit 1
fi

if [ "$actual_sender_id" != "$expected_sender_id" ]; then
  echo "error: Firebase GCM_SENDER_ID does not match FIREBASE_ENV=$FIREBASE_ENV." >&2
  exit 1
fi

if [ "$actual_bundle_id" != "$bundle_id" ]; then
  echo "error: Firebase BUNDLE_ID does not match the protected app identifier." >&2
  exit 1
fi

if [ "${1:-}" = "--validate-only" ]; then
  echo "Firebase configuration validated for FIREBASE_ENV=$FIREBASE_ENV."
  exit 0
fi

if [ -z "${TARGET_BUILD_DIR:-}" ] || [ -z "${UNLOCALIZED_RESOURCES_FOLDER_PATH:-}" ]; then
  echo "error: Xcode bundle output paths are unavailable." >&2
  exit 1
fi

resources_dir="$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH"
destination_plist="$resources_dir/GoogleService-Info.plist"

if [ "$resources_dir" = "/" ]; then
  echo "error: Refusing to copy the Firebase plist to an invalid bundle path." >&2
  exit 1
fi

/bin/mkdir -p "$resources_dir"
/bin/cp "$source_plist" "$destination_plist"

bundled_plist_count="$(
  /usr/bin/find "$resources_dir" -maxdepth 1 -type f \
    -name 'GoogleService-Info.plist' -print | /usr/bin/wc -l | /usr/bin/tr -d ' '
)"

if [ "$bundled_plist_count" != "1" ]; then
  echo "error: Expected exactly one GoogleService-Info.plist in the app bundle." >&2
  exit 1
fi

echo "Firebase configuration selected for FIREBASE_ENV=$FIREBASE_ENV."

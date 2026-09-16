#!/usr/bin/env bash
# Read-only macOS toolchain inventory. This script does not install, update,
# authenticate, build, test, access Keychain, or modify Git/project files.

set -u

print_found() {
  local label="$1"
  shift

  if command -v "$1" >/dev/null 2>&1; then
    printf 'FOUND   %-12s ' "$label"
    "$@" 2>&1 | head -n 1
  else
    printf 'MISSING %-12s command not found\n' "$label"
  fi
}

print_xcode() {
  if command -v xcodebuild >/dev/null 2>&1; then
    printf 'FOUND   %-12s ' 'Xcode'
    xcodebuild -version 2>&1 | head -n 1
  else
    printf 'MISSING %-12s xcodebuild command not found\n' 'Xcode'
  fi
}

print_flutter() {
  local flutter_path

  if flutter_path="$(command -v flutter 2>/dev/null)"; then
    printf 'FOUND   %-12s %s\n' 'Flutter' "$flutter_path"
    printf '%s\n' '        version not executed to avoid creating or updating the Flutter cache'
  else
    printf 'MISSING %-12s command not found\n' 'Flutter'
  fi
}

print_dart() {
  local dart_path

  if dart_path="$(command -v dart 2>/dev/null)"; then
    printf 'FOUND   %-12s %s\n' 'Dart' "$dart_path"
    printf '%s\n' '        version not executed because Dart may use the Flutter cache wrapper'
  else
    printf 'MISSING %-12s command not found\n' 'Dart'
  fi
}

printf '%s\n' '== macOS development toolchain (read-only) =='
print_found 'Git' git --version
print_found 'GitHub CLI' gh --version
print_flutter
print_dart
print_xcode
print_found 'CocoaPods' pod --version
print_found 'Ruby' ruby --version
print_found 'Java' java -version

printf '%s\n' 'No installation, authentication, build, test, Pod, Keychain, or repository changes were performed.'

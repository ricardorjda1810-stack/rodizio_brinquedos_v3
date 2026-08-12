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

printf '%s\n' '== macOS development toolchain (read-only) =='
print_found 'Git' git --version
print_found 'GitHub CLI' gh --version
print_found 'Flutter' flutter --version
print_found 'Dart' dart --version
print_xcode
print_found 'CocoaPods' pod --version
print_found 'Ruby' ruby --version
print_found 'Java' java -version

printf '%s\n' 'No installation, authentication, build, test, Pod, Keychain, or repository changes were performed.'

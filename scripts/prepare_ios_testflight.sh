#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "== Rodizio Brinquedos - preparo iOS/TestFlight =="
echo

echo "== Git =="
current_branch="$(git branch --show-current)"
version_line="$(grep "^version:" pubspec.yaml)"
echo "Branch: $current_branch"
echo "Ultimo commit: $(git log -1 --oneline)"
echo "Versao atual: $version_line"
echo

if [[ "$current_branch" != "main" ]]; then
  echo "ATENCAO: branch atual nao e main."
  echo "Branch atual: $current_branch"
  echo
fi

echo "== Status =="
git status
echo

if git status --short --branch | head -n 1 | grep -q "ahead"; then
  echo "ATENCAO: existem commits locais ainda nao enviados para origin/main."
  echo "Envie os commits antes de arquivar uma build para TestFlight."
  echo
fi

unexpected_status="$(
  git status --short | awk '
    {
      path = substr($0, 4)
      if (path != ".flutter-plugins-dependencies" &&
          path != "ios/Podfile.lock") {
        print $0
      }
    }
  '
)"

if [[ -n "$unexpected_status" ]]; then
  echo "ATENCAO: existem alteracoes locais fora dos arquivos esperados:"
  echo "$unexpected_status"
  echo
  echo "O script nao vai apagar nem commitar nada automaticamente."
  echo "Revise essas alteracoes antes de arquivar/enviar para TestFlight."
  echo
else
  echo "Status local contem apenas arquivos esperados ou esta limpo."
  echo
fi

echo "== Flutter analyze =="
flutter analyze
echo

echo "== Flutter clean =="
flutter clean
echo

echo "== Flutter pub get =="
flutter pub get
echo

echo "== CocoaPods =="
cd ios
pod install --repo-update
cd "$PROJECT_ROOT"
echo

if [[ ! -d "ios/Runner.xcworkspace" ]]; then
  echo "ERRO: ios/Runner.xcworkspace nao encontrado."
  exit 1
fi

echo "Workspace confirmado: ios/Runner.xcworkspace"
echo

echo "== Abrindo Xcode =="
open ios/Runner.xcworkspace
echo

echo "Pronto para Archive no Xcode"
echo "No Xcode, confira Version/Build, selecione Any iOS Device (arm64), depois Product > Archive."

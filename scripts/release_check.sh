#!/usr/bin/env bash
set -euo pipefail

echo "==> flutter analyze"
flutter analyze

echo "==> flutter test"
flutter test

echo "==> flutter build apk --release"
flutter build apk --release

echo "==> listo: build/app/outputs/flutter-apk/app-release.apk"

#!/usr/bin/env bash
# Tek komutla repo'yu güncel sürüme çek ve clean build yap.
# Kullanım:  bash setup.sh

set -e

cd "$(dirname "$0")"

echo "── 1/6 ── Branch'i en güne çek..."
git fetch origin
git checkout claude/gallant-bardeen-gl3t70
git reset --hard origin/claude/gallant-bardeen-gl3t70

echo "── 2/6 ── Eski Kotlin DSL gradle dosyaları varsa sil (Flutter Groovy'yi kullanacak)..."
rm -f android/app/build.gradle.kts
rm -f android/build.gradle.kts
rm -f android/settings.gradle.kts

echo "── 3/6 ── Flutter build cache temizle..."
flutter clean

echo "── 4/6 ── Gradle build cache temizle..."
if [ -f android/gradlew ]; then
  (cd android && ./gradlew clean) || true
fi

echo "── 5/6 ── Bağımlılıkları indir (http, hijri vb)..."
flutter pub get

echo "── 6/6 ── Build başlat..."
flutter run

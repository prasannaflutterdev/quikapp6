#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ Android AAB build failed on line $LINENO"; exit 1' ERR

#flutter clean
#flutter pub get

echo "📦 Building AppBundle..."
#--target=lib/main.dart
flutter build appbundle --release \
  --dart-define=WEB_URL="$WEB_URL" \
  --dart-define=PUSH_NOTIFY="$PUSH_NOTIFY" \
  --dart-define=PKG_NAME="$PKG_NAME" \
  --dart-define=APP_NAME="$APP_NAME" \
  --dart-define=ORG_NAME="$ORG_NAME" \
  --dart-define=VERSION_NAME="$VERSION_NAME" \
  --dart-define=VERSION_CODE="$VERSION_CODE" \
  --dart-define=EMAIL_ID="$EMAIL_ID" \
  --dart-define=IS_SPLASH="$IS_SPLASH" \
  --dart-define=SPLASH="$SPLASH" \
  --dart-define=SPLASH_BG="$SPLASH_BG" \
  --dart-define=SPLASH_ANIMATION="$SPLASH_ANIMATION" \
  --dart-define=SPLASH_BG_COLOR="$SPLASH_BG_COLOR" \
  --dart-define=SPLASH_TAGLINE="$SPLASH_TAGLINE" \
  --dart-define=SPLASH_TAGLINE_COLOR="$SPLASH_TAGLINE_COLOR" \
  --dart-define=SPLASH_DURATION="$SPLASH_DURATION" \
  --dart-define=IS_PULLDOWN="$IS_PULLDOWN" \
  --dart-define=LOGO_URL="$LOGO_URL" \
  --dart-define=IS_BOTTOMMENU="$IS_BOTTOMMENU" \
  --dart-define=BOTTOMMENU_ITEMS="$BOTTOMMENU_ITEMS" \
  --dart-define=BOTTOMMENU_BG_COLOR="$BOTTOMMENU_BG_COLOR" \
  --dart-define=BOTTOMMENU_ICON_COLOR="$BOTTOMMENU_ICON_COLOR" \
  --dart-define=BOTTOMMENU_TEXT_COLOR="$BOTTOMMENU_TEXT_COLOR" \
  --dart-define=BOTTOMMENU_FONT="$BOTTOMMENU_FONT" \
  --dart-define=BOTTOMMENU_FONT_SIZE="$BOTTOMMENU_FONT_SIZE" \
  --dart-define=BOTTOMMENU_FONT_BOLD="$BOTTOMMENU_FONT_BOLD" \
  --dart-define=BOTTOMMENU_FONT_ITALIC="$BOTTOMMENU_FONT_ITALIC" \
  --dart-define=BOTTOMMENU_ACTIVE_TAB_COLOR="$BOTTOMMENU_ACTIVE_TAB_COLOR" \
  --dart-define=BOTTOMMENU_ICON_POSITION="$BOTTOMMENU_ICON_POSITION" \
  --dart-define=BOTTOMMENU_VISIBLE_ON="$BOTTOMMENU_VISIBLE_ON" \
  --dart-define=IS_DEEPLINK="$IS_DEEPLINK" \
  --dart-define=IS_LOAD_IND="$IS_LOAD_IND" \
  --dart-define=IS_CAMERA="$IS_CAMERA" \
  --dart-define=IS_LOCATION="$IS_LOCATION" \
  --dart-define=IS_BIOMETRIC="$IS_BIOMETRIC" \
  --dart-define=IS_MIC="$IS_MIC" \
  --dart-define=IS_CONTACT="$IS_CONTACT" \
  --dart-define=IS_CALENDAR="$IS_CALENDAR" \
  --dart-define=IS_NOTIFICATION="$IS_NOTIFICATION" \
  --dart-define=IS_STORAGE="$IS_STORAGE" \
  --dart-define=firebase_config_android="$firebase_config_android" \
  --dart-define=KEY_STORE="$KEY_STORE" \
  --dart-define=CM_KEYSTORE_PASSWORD="$CM_KEYSTORE_PASSWORD" \
  --dart-define=CM_KEY_ALIAS="$CM_KEY_ALIAS" \
  --dart-define=CM_KEY_PASSWORD="$CM_KEY_PASSWORD"

echo "✅ AAB build completed."

echo "🔍 Searching for AAB output..."
AAB_PATH=$(find build/app/outputs -type f -name "*.aab" | head -n 1)

if [[ -f "$AAB_PATH" ]]; then
  echo "🎉 AAB is ready: $AAB_PATH"
else
  echo "❌ AAB not found!"
  ls -R build/app/outputs/
  exit 1
fi

##!/usr/bin/env bash
#
#set -euo pipefail
#trap 'echo "❌ Android AAB build failed on line $LINENO"; exit 1' ERR
#
## Added setup commands
#flutter clean
#flutter pub get
#
## The source command is no longer needed
## source "$(dirname "$0")/android_build.sh"
#
#echo "📦 Building AppBundle..."
#
## Use the explicit, multi-line build command for AAB --verbose
#flutter build appbundle --release --target=lib/main.dart \
#    --dart-define=WEB_URL="$WEB_URL" \
#    --dart-define=PUSH_NOTIFY="$PUSH_NOTIFY" \
#    --dart-define=PKG_NAME="$PKG_NAME" \
#    --dart-define=APP_NAME="$APP_NAME" \
#    --dart-define=ORG_NAME="$ORG_NAME" \
#    --dart-define=VERSION_NAME="$VERSION_NAME" \
#    --dart-define=VERSION_CODE="$VERSION_CODE" \
#    --dart-define=EMAIL_ID="$EMAIL_ID" \
#    --dart-define=IS_SPLASH="$IS_SPLASH" \
#    --dart-define=SPLASH="$SPLASH" \
#    --dart-define=SPLASH_BG="$SPLASH_BG" \
#    --dart-define=SPLASH_ANIMATION="$SPLASH_ANIMATION" \
#    --dart-define=SPLASH_BG_COLOR="$SPLASH_BG_COLOR" \
#    --dart-define=SPLASH_TAGLINE="$SPLASH_TAGLINE" \
#    --dart-define=SPLASH_TAGLINE_COLOR="$SPLASH_TAGLINE_COLOR" \
#    --dart-define=SPLASH_DURATION="$SPLASH_DURATION" \
#    --dart-define=IS_PULLDOWN="$IS_PULLDOWN" \
#    --dart-define=LOGO_URL="$LOGO_URL" \
#    --dart-define=IS_BOTTOMMENU="$IS_BOTTOMMENU" \
#    --dart-define=BOTTOMMENU_ITEMS="$BOTTOMMENU_ITEMS" \
#    --dart-define=BOTTOMMENU_BG_COLOR="$BOTTOMMENU_BG_COLOR" \
#    --dart-define=BOTTOMMENU_ICON_COLOR="$BOTTOMMENU_ICON_COLOR" \
#    --dart-define=BOTTOMMENU_TEXT_COLOR="$BOTTOMMENU_TEXT_COLOR" \
#    --dart-define=BOTTOMMENU_FONT="$BOTTOMMENU_FONT" \
#    --dart-define=BOTTOMMENU_FONT_SIZE="$BOTTOMMENU_FONT_SIZE" \
#    --dart-define=BOTTOMMENU_FONT_BOLD="$BOTTOMMENU_FONT_BOLD" \
#    --dart-define=BOTTOMMENU_FONT_ITALIC="$BOTTOMMENU_FONT_ITALIC" \
#    --dart-define=BOTTOMMENU_ACTIVE_TAB_COLOR="$BOTTOMMENU_ACTIVE_TAB_COLOR" \
#    --dart-define=BOTTOMMENU_ICON_POSITION="$BOTTOMMENU_ICON_POSITION" \
#    --dart-define=BOTTOMMENU_VISIBLE_ON="$BOTTOMMENU_VISIBLE_ON" \
#    --dart-define=IS_DEEPLINK="$IS_DEEPLINK" \
#    --dart-define=IS_LOAD_IND="$IS_LOAD_IND" \
#    --dart-define=IS_CAMERA="$IS_CAMERA" \
#    --dart-define=IS_LOCATION="$IS_LOCATION" \
#    --dart-define=IS_BIOMETRIC="$IS_BIOMETRIC" \
#    --dart-define=IS_MIC="$IS_MIC" \
#    --dart-define=IS_CONTACT="$IS_CONTACT" \
#    --dart-define=IS_CALENDAR="$IS_CALENDAR" \
#    --dart-define=IS_NOTIFICATION="$IS_NOTIFICATION" \
#    --dart-define=IS_STORAGE="$IS_STORAGE" \
#    --dart-define=firebase_config_android="$firebase_config_android" \
#    --dart-define=KEY_STORE="$KEY_STORE" \
#    --dart-define=CM_KEYSTORE_PASSWORD="$CM_KEYSTORE_PASSWORD" \
#    --dart-define=CM_KEY_ALIAS="$CM_KEY_ALIAS" \
#    --dart-define=CM_KEY_PASSWORD="$CM_KEY_PASSWORD"
#
#echo "✅ AppBundle build completed successfully."
#
#AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
#echo "🎉 AAB is ready at: $AAB_PATH"
###!/usr/bin/env bash
##
##set -euo pipefail
##trap 'echo "❌ Android AAB build failed on line $LINENO"; exit 1' ERR
##
### Source the common pre-build script
##source "$(dirname "$0")/_pre_build.sh"
##
##echo "📦 Building AppBundle..."
##flutter build appbundle --release --target=lib/main.dart $DART_DEFINES --verbose
##echo "✅ AppBundle build completed."
##
##AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
##
##echo "📂 Checking output..."
##if [[ -f "$AAB_PATH" ]]; then
##  echo "🎉 AAB is ready:"
##  echo "  ✅ AAB: $AAB_PATH"
##else
##  echo "❌ Build output is missing!"
##  echo "Missing: $AAB_PATH"
##  exit 1
##fi
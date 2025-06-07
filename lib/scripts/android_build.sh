#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ Android build failed on line $LINENO"; exit 1' ERR

echo "🧹 Running flutter clean..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔍 Debugging Environment Variables..."
env | grep -E '^(WEB_URL|PUSH_NOTIFY|PKG_NAME|APP_NAME|ORG_NAME|VERSION_NAME|VERSION_CODE|EMAIL_ID|IS_|LOGO_URL|BOTTOMMENU_|SPLASH|CERT_|KEY_STORE|CM_|PROFILE_URL|APPLE_TEAM_ID|APNS_|BUNDLE_ID|firebase_config)' | sort

# 🔧 Sanitizing only critical known variables (no iconv/tr used)
clean_known_vars() {
  echo "⚠️ Cleaning variables known to contain invisible Unicode (safe fallback)..."

  BOTTOMMENU_FONT=$(echo "$BOTTOMMENU_FONT" | awk '{gsub(/[^[:print:]]/, ""); print}')
  APP_NAME=$(echo "$APP_NAME" | awk '{gsub(/[^[:print:]]/, ""); print}')
  ORG_NAME=$(echo "$ORG_NAME" | awk '{gsub(/[^[:print:]]/, ""); print}')
  export BOTTOMMENU_FONT APP_NAME ORG_NAME
}

clean_known_vars

# ✅ Dart defines generator
get_dart_defines() {
cat <<EOF
--dart-define=WEB_URL="${WEB_URL}"
--dart-define=PUSH_NOTIFY="${PUSH_NOTIFY}"
--dart-define=PKG_NAME="${PKG_NAME}"
--dart-define=APP_NAME="${APP_NAME}"
--dart-define=ORG_NAME="${ORG_NAME}"
--dart-define=VERSION_NAME="${VERSION_NAME}"
--dart-define=VERSION_CODE="${VERSION_CODE}"
--dart-define=EMAIL_ID="${EMAIL_ID}"

--dart-define=IS_SPLASH="${IS_SPLASH}"
--dart-define=SPLASH="${SPLASH}"
--dart-define=SPLASH_BG="${SPLASH_BG}"
--dart-define=SPLASH_ANIMATION="${SPLASH_ANIMATION}"
--dart-define=SPLASH_BG_COLOR="${SPLASH_BG_COLOR}"
--dart-define=SPLASH_TAGLINE="${SPLASH_TAGLINE}"
--dart-define=SPLASH_TAGLINE_COLOR="${SPLASH_TAGLINE_COLOR}"
--dart-define=SPLASH_DURATION="${SPLASH_DURATION}"

--dart-define=IS_PULLDOWN="${IS_PULLDOWN}"
--dart-define=LOGO_URL="${LOGO_URL}"

--dart-define=IS_BOTTOMMENU="${IS_BOTTOMMENU}"
--dart-define=BOTTOMMENU_ITEMS='${BOTTOMMENU_ITEMS}'
--dart-define=BOTTOMMENU_BG_COLOR="${BOTTOMMENU_BG_COLOR}"
--dart-define=BOTTOMMENU_ICON_COLOR="${BOTTOMMENU_ICON_COLOR}"
--dart-define=BOTTOMMENU_TEXT_COLOR="${BOTTOMMENU_TEXT_COLOR}"
--dart-define=BOTTOMMENU_FONT="${BOTTOMMENU_FONT}"
--dart-define=BOTTOMMENU_FONT_SIZE="${BOTTOMMENU_FONT_SIZE}"
--dart-define=BOTTOMMENU_FONT_BOLD="${BOTTOMMENU_FONT_BOLD}"
--dart-define=BOTTOMMENU_FONT_ITALIC="${BOTTOMMENU_FONT_ITALIC}"
--dart-define=BOTTOMMENU_ACTIVE_TAB_COLOR="${BOTTOMMENU_ACTIVE_TAB_COLOR}"
--dart-define=BOTTOMMENU_ICON_POSITION="${BOTTOMMENU_ICON_POSITION}"
--dart-define=BOTTOMMENU_VISIBLE_ON="${BOTTOMMENU_VISIBLE_ON}"

--dart-define=IS_DEEPLINK="${IS_DEEPLINK}"
--dart-define=IS_LOAD_IND="${IS_LOAD_IND}"
--dart-define=IS_CHATBOT="${IS_CHATBOT}"
--dart-define=IS_CAMERA="${IS_CAMERA}"
--dart-define=IS_LOCATION="${IS_LOCATION}"
--dart-define=IS_BIOMETRIC="${IS_BIOMETRIC}"
--dart-define=IS_MIC="${IS_MIC}"
--dart-define=IS_CONTACT="${IS_CONTACT}"
--dart-define=IS_CALENDAR="${IS_CALENDAR}"
--dart-define=IS_NOTIFICATION="${IS_NOTIFICATION}"
--dart-define=IS_STORAGE="${IS_STORAGE}"

--dart-define=KEY_STORE="${KEY_STORE}"
--dart-define=CM_KEYSTORE_PASSWORD="${CM_KEYSTORE_PASSWORD}"
--dart-define=CM_KEY_ALIAS="${CM_KEY_ALIAS}"
--dart-define=CM_KEY_PASSWORD="${CM_KEY_PASSWORD}"
EOF
}

dart_defines=$(get_dart_defines | xargs)

echo "📦 Building APK..."
flutter build apk --release --target=lib/main.dart $dart_defines --verbose
echo "✅ APK build completed."

echo "📦 Building AppBundle..."
flutter build appbundle --release --target=lib/main.dart $dart_defines --verbose
echo "✅ AppBundle build completed."

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
AAB_PATH="build/app/outputs/bundle/release/app-release.aab"

echo "📂 Checking outputs..."
if [[ -f "$APK_PATH" && -f "$AAB_PATH" ]]; then
  echo "🎉 APK and AAB are ready:"
  echo "  ✅ APK: $APK_PATH"
  echo "  ✅ AAB: $AAB_PATH"
else
  echo "❌ One or both build outputs are missing!"
  [[ ! -f "$APK_PATH" ]] && echo "Missing: $APK_PATH"
  [[ ! -f "$AAB_PATH" ]] && echo "Missing: $AAB_PATH"
  exit 1
fi

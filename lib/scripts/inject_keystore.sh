#!/usr/bin/env bash

set -e
echo "🔐 Starting keystore injection..."

# --- START: SECURE DEBUGGING BLOCK ---
# This block will print the status of the variables received from the API.
echo "-------------------------------------------------"
echo "🔍 Verifying received signing credentials..."
echo "   - KEY_STORE URL: ${KEY_STORE}"
echo "   - CM_KEY_ALIAS: ${CM_KEY_ALIAS}"
echo "   - CM_KEYSTORE_PASSWORD length: ${#CM_KEYSTORE_PASSWORD}"
echo "   - CM_KEY_PASSWORD length: ${#CM_KEY_PASSWORD}"
echo "-------------------------------------------------"
# --- END: SECURE DEBUGGING BLOCK ---

: "${KEY_STORE:?Missing KEY_STORE}"
: "${CM_KEYSTORE_PASSWORD:?Missing CM_KEYSTORE_PASSWORD}"
: "${CM_KEY_ALIAS:?Missing CM_KEY_ALIAS}"
: "${CM_KEY_PASSWORD:?Missing CM_KEY_PASSWORD}"

# Ensure folder structure
mkdir -p android android/app

# 🔽 Download keystore
echo "📥 Downloading keystore to android/keystore.jks..."
curl -fsSL -o android/keystore.jks "$KEY_STORE" || {
  echo "❌ Failed to download keystore from $KEY_STORE"
  exit 1
}
[[ -f android/keystore.jks ]] && echo "✅ keystore.jks is present"

# 📝 Write key.properties
echo "📝 Writing key.properties..."
cat <<EOF > android/key.properties
storeFile=keystore.jks
storePassword=$CM_KEYSTORE_PASSWORD
keyAlias=$CM_KEY_ALIAS
keyPassword=$CM_KEY_PASSWORD
EOF
[[ -f android/key.properties ]] && echo "✅ key.properties written"
##!/usr/bin/env bash
#
#set -e
#echo "🔐 Starting keystore injection..."
#
## --- START: ADD THESE DEBUGGING LINES ---
#echo "✅ CM_KEY_ALIAS: ${CM_KEY_ALIAS}"
#echo "✅ CM_KEYSTORE_PASSWORD length: ${#CM_KEYSTORE_PASSWORD}"
#echo "✅ CM_KEY_PASSWORD length: ${#CM_KEY_PASSWORD}"
## --- END: ADD THESE DEBUGGING LINES ---
#
#: "${KEY_STORE:?Missing KEY_STORE}"
#: "${CM_KEYSTORE_PASSWORD:?Missing CM_KEYSTORE_PASSWORD}"
#: "${CM_KEY_ALIAS:?Missing CM_KEY_ALIAS}"
#: "${CM_KEY_PASSWORD:?Missing CM_KEY_PASSWORD}"
#
## Ensure folder structure
#mkdir -p android android/app
#
## 🔽 Download keystore
#echo "📥 Downloading keystore to android/keystore.jks..."
#curl -fsSL -o android/keystore.jks "$KEY_STORE" || {
#  echo "❌ Failed to download keystore from $KEY_STORE"
#  exit 1
#}
#[[ -f android/keystore.jks ]] && echo "✅ keystore.jks is present"
#
## 📝 Write key.properties
#echo "📝 Writing android/key.properties..."
#cat <<EOF > android/key.properties
#storeFile=keystore.jks
#storePassword=$CM_KEYSTORE_PASSWORD
#keyAlias=$CM_KEY_ALIAS
#keyPassword=$CM_KEY_PASSWORD
#EOF
#[[ -f android/key.properties ]] && echo "✅ key.properties written"

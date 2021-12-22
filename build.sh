#! /bin/bash

set -exo pipefail

yarnpkg install

mkdir -p android/app/src/main/assets
touch android/app/src/main/assets/index.android
yarnpkg exec -- react-native bundle --platform android --dev false --entry-file index.js \
    --bundle-output android/app/src/main/assets/index.android.bundle \
    --assets-dest android/app/src/main/res

cd android

cat > gradle.properties <<EOF
#android.enableAapt2=false
android.useAndroidX=true
android.enableJetifier=true
FLIPPER_VERSION=0.51.0
VERSIONCODE=${GITHUB_RUN_NUMBER:-1}
APPLICATION_ID=chat.rocket.reactnative
BugsnagAPIKey=
EOF

#keystore_path=\?/.android/debug.keystore
#if [[ ! -f "$keystore_path" ]]; then
#    keytool -genkey -v -keystore "$keystore_path" -storepass android -alias androiddebugkey \
#        -keypass android -keyalg RSA -keysize 2048 -validity 10000 \
#        -dname "cn=Unknown, ou=Unknown, o=Unknown, c=Unknown"
#fi

./gradlew clean assembleDebug


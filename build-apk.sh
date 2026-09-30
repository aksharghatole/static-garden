#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/android"

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$HOME/android-sdk"

echo "JAVA: $(java -version 2>&1 | head -1)"
echo "ANDROID_HOME: $ANDROID_HOME"
echo "PWD: $(pwd)"
echo "---"

./gradlew assembleDebug --no-daemon -Pexport_package_name=com.example.staticgarden

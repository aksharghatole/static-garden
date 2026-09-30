#!/usr/bin/env bash
set -euo pipefail
GODOT_VERSION="4.2.2"
GODOT_DIR="$HOME/godot"
ANDROID_SDK_ROOT="$HOME/android-sdk"
CMDLINE_TOOLS_VERSION="11076708"
mkdir -p "$GODOT_DIR" "$ANDROID_SDK_ROOT/cmdline-tools"

if [ ! -f "$GODOT_DIR/godot" ]; then
  echo "Downloading Godot $GODOT_VERSION..."
  wget -q "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" -O /tmp/godot.zip
  unzip -o /tmp/godot.zip -d "$GODOT_DIR"
  mv "$GODOT_DIR/Godot_v${GODOT_VERSION}-stable_linux.x86_64" "$GODOT_DIR/godot"
  chmod +x "$GODOT_DIR/godot"
fi

TEMPLATES_DIR="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.stable"
if [ ! -d "$TEMPLATES_DIR" ]; then
  echo "Downloading export templates..."
  mkdir -p "$TEMPLATES_DIR"
  wget -q "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_export_templates.tpz" -O /tmp/templates.tpz
  mkdir -p /tmp/godot_templates
  unzip -o /tmp/templates.tpz -d /tmp/godot_templates
  mv /tmp/godot_templates/templates/* "$TEMPLATES_DIR/"
fi

if [ ! -d "$ANDROID_SDK_ROOT/cmdline-tools/latest" ]; then
  echo "Installing Android cmdline tools..."
  wget -q "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip" -O /tmp/cmdline-tools.zip
  unzip -o /tmp/cmdline-tools.zip -d "$ANDROID_SDK_ROOT/cmdline-tools"
  mv "$ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools" "$ANDROID_SDK_ROOT/cmdline-tools/latest"
fi

yes | "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1 || true
"$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0" >/dev/null

KEYSTORE="$HOME/.android/debug.keystore"
if [ ! -f "$KEYSTORE" ]; then
  mkdir -p "$HOME/.android"
  keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore "$KEYSTORE" -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12
fi

PROFILE_LINE='export PATH="$HOME/godot:$HOME/android-sdk/platform-tools:$HOME/android-sdk/cmdline-tools/latest/bin:$PATH"'
grep -qxF "$PROFILE_LINE" "$HOME/.bashrc" || echo "$PROFILE_LINE" >> "$HOME/.bashrc"
BUILD_ALIAS='alias build="bash scripts/export-android.sh"'
grep -qxF "$BUILD_ALIAS" "$HOME/.bashrc" || echo "$BUILD_ALIAS" >> "$HOME/.bashrc"
echo "Setup complete. Run: source ~/.bashrc ; then: build"

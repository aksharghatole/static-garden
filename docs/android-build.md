# Android development

Static Garden uses Godot 4.2.2 and the prebuilt Android export template (ARM64). No generated Android Gradle project is required for this preset.

On Ubuntu 22.04 or Codespaces, install OpenJDK 17, Python 3, curl and unzip, then run:

```sh
bash scripts/setup-codespace.sh
bash build-apk.sh
```

The build script imports the project, launches a short headless smoke test, exports a signed debug APK, checks its ZIP integrity and verifies its signature. Output: `build/static-garden-debug.apk`. It fails on Godot errors rather than silently continuing. Environment variables ANDROID_SDK_ROOT, JAVA_HOME and GODOT_BIN can override defaults.

GitHub Actions builds the APK for pull requests and pushes to main. Download the static-garden-debug artifact from a successful run and extract the APK before installing. Android may require permission to install unknown apps. The debug key may differ between CI runs; an existing installation signed with another key must be uninstalled before installing (this deletes its local data). These are debug builds, not Play Store releases.

The old PCK/Gradle pipeline is unnecessary while the Android preset has Gradle disabled. The project currently needs no custom Android plugins. For local development, open project.godot with Godot 4.2.2.

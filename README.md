# Static Garden

A cozy, offline garden puzzle game about growing plants guided by signals from a dying satellite. Tune your antenna, advance time, harvest plants and spend fragments to unlock new seeds.

## Hybrid breeding

Harvest a mature base plant beside another mature base plant for a 25% chance to discover one new hybrid. The six hybrids can be planted like ordinary seeds and are recorded in the journal. Only horizontal and vertical neighbors count; normal harvest rewards are retained.

## Soundscape

An original looping ambient synthesizer and six short interaction sounds are generated locally from PCM samples, with no external audio files or network access. Master, ambient and effects volumes are independently adjustable and saved between sessions.

## Controls

Use the garden Menu button, Android system Back, or Escape on desktop to open the pause overlay. Resume returns to the garden, or choose Main menu / Save and quit. Back from the journal or settings returns to the main menu; Back on the main menu saves and exits.

## Play on Android

1. Open [GitHub Actions](https://github.com/aksharghatole/static-garden/actions).
2. Select a successful **Android APK** run on the main branch.
3. Download the `static-garden-debug` artifact and extract the APK.
4. Open the APK on an ARM64 Android device and allow installation from the selected app if prompted.

These are debug builds. GitHub sign-in may be required for artifact downloads. Debug signing keys can differ between builds; uninstalling an existing app to replace it with a differently signed APK deletes its local saves.

## Build from source

Requires Godot 4.2.2, OpenJDK 17, Python 3, curl, unzip, and the Android SDK. On Ubuntu or GitHub Codespaces:

```bash
bash scripts/setup-codespace.sh
bash build-apk.sh
```

Output: `build/static-garden-debug.apk`. The script imports resources, runs startup and gameplay tests, exports the APK and verifies its signature. No generated Gradle project needs to be checked in. See [Android build details](docs/android-build.md).

For editor development, open `project.godot` with Godot 4.2.2 and run the main scene. Run the gameplay regression tests with:

```bash
godot --headless --path . res://tests/gameplay.tscn
```

Use a disposable user data directory when running tests to avoid modifying personal saves.

## Project structure

| Path | Purpose |
| --- | --- |
| `autoload/` | Game model, signals, save management and audio |
| `scenes/` | Garden, main menu, journal and settings |
| `components/` | Reusable antenna and signal controls |
| `data/` | Plant definitions |
| `ui/`, `shaders/` | Interface and visual resources |
| `scripts/` | Build environment setup and export helpers |
| `tests/` | Headless gameplay regression tests |

## Current limitations

- Android debug APKs target ARM64; physical-device testing is still needed.
- Extended progression is planned.
- Further visual polish is tracked in [issues](https://github.com/aksharghatole/static-garden/issues).

Built with [Godot](https://godotengine.org/). See [LICENSE](LICENSE) for licensing.

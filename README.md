# Flutter Offline Music

[![CI](https://github.com/giatkt1598/flutter_offline_music/actions/workflows/ci.yml/badge.svg)](https://github.com/giatkt1598/flutter_offline_music/actions/workflows/ci.yml)
[![Latest Release](https://img.shields.io/github/v/release/giatkt1598/flutter_offline_music)](https://github.com/giatkt1598/flutter_offline_music/releases)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/github/license/giatkt1598/flutter_offline_music)](LICENSE)

Offline music player built with Flutter, focused on smooth local playback, practical library management, and reliable background audio.

## Table of Contents

- [Highlights](#highlights)
- [Tech Stack](#tech-stack)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Build and Release](#build-and-release)
- [Project Structure](#project-structure)
- [Available Scripts](#available-scripts)
- [Contributing](#contributing)
- [Notes](#notes)

## Highlights

- Offline playback from local files.
- Mini player + full player with multiple UI styles.
- Full controls: play/pause, seek, next/previous, shuffle, loop.
- Dynamic playlist with reorder support.
- Library organization by list and folder.
- Search, favorites, recent, and most-played sections.
- Listening-time tracking with played-count threshold.
- Sleep timer and optional skip-silence mode.
- Background playback with notification controls.
- Optional YouTube thumbnail fetching.

## Tech Stack

- Flutter + Dart
- `just_audio`, `audio_service`, `just_audio_background`
- `provider`
- `sqflite`, `shared_preferences`
- GitHub Actions (tag-based CI release pipeline)

## Requirements

- Flutter SDK (stable channel recommended)
- Dart SDK (see `pubspec.yaml`)
- Android SDK + Java 17 (for APK builds)
- Node.js (for build/release scripts)

## Quick Start

```bash
flutter pub get
flutter run
```

Run checks:

```bash
flutter analyze
flutter test
```

## Build and Release

### Local APK build

```bash
npm run build
```

### Release workflow

CI is triggered on pushed tags matching `v*` (example: `v1.0.27`).

On successful pipeline:

- The release APK is built.
- APK is uploaded to GitHub Release assets.
- Release notes are generated from commit messages since the previous release.

Create a release manually:

```bash
git tag v1.0.27
git push origin v1.0.27
```

Or use the project automation:

```bash
npm run deploy
```

## Project Structure

```text
lib/
  components/   reusable widgets
  i18n/         localization files
  models/       app data models
  pages/        app screens
  providers/    state management
  services/     audio, database, library, permissions, youtube
  utilities/    helper utilities
build-scripts/  versioning and publish scripts
.github/workflows/  CI/CD pipelines
```

## Available Scripts

- `npm run splash` generate splash screen
- `npm run icon` generate launcher icon
- `npm run build` build release APK and rename artifact
- `npm run deploy` bump app version, commit/tag, and push
- `npm run lint` apply `dart fix`

## Contributing

1. Create a feature branch.
2. Keep changes scoped and testable.
3. Run `flutter analyze` and `flutter test`.
4. Open a pull request with clear change notes.

## Notes

- Current release target is Android APK.
- Licensed under the MIT License.

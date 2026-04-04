# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**StudyFlow** — a Flutter productivity app (Android-focused, portrait-only) with a Pomodoro timer, to-do list, diary, music player, stats tracking, and settings. Supports English and Russian.

## Commands

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build APK
flutter build apk

# Lint
flutter analyze

# Tests
flutter test
flutter test test/widget_test.dart   # single test file

# Regenerate Hive adapters (after changing a model annotated with @HiveType)
dart run build_runner build --delete-conflicting-outputs

# Regenerate localization files (after editing lib/l10n/app_en.arb or app_ru.arb)
flutter gen-l10n
```

## Architecture

### State management
- **Provider** (`provider` package) — used for the two app-wide services: `TimerService` and `LocaleService`, both registered in `main.dart` via `MultiProvider`.
- **AudioService** is a singleton (`ChangeNotifier`) accessed directly via `AudioService()` factory, not through Provider. Widgets that need to react to audio state call `audio.addListener(...)` manually.

### Services (`lib/services/`)
- `TimerService` — Pomodoro logic. Persists running state across app restarts using `SharedPreferences` (stores start timestamp + remaining seconds so it can compute elapsed time on cold start). Writes completed session stats to Hive (`StatsModel`).
- `AudioService` — singleton wrapping `just_audio`. Manages a queue (`List<TrackModel>`), shuffle/loop, and exposes streams. Playlists and tracks are defined as `const` data directly in `MusicScreen`/`PlaylistDetailScreen`.
- `LocaleService` — persists selected locale in `SharedPreferences`.

### Data persistence (`lib/models/`)
Three Hive boxes, opened at startup in `main.dart`:
- `todos` → `TodoModel` (typeId: 0)
- `diary` → `DiaryModel` (typeId: 1) — stores diary entries; `content` field is a JSON string (flutter_quill Delta format)
- `stats` → `StatsModel` (typeId: 2) — one record per calendar day, accumulates `focusSeconds` and `sessionsCount`

After modifying any `@HiveType`/`@HiveField` annotation, regenerate the `.g.dart` adapter with `build_runner`.

### Navigation
`MainNavigation` (in `lib/widgets/bottom_nav.dart`) hosts a `PageView` with a **top** icon bar (not a bottom nav bar). Pages in order: Timer → Todo → Diary → Music → Stats → Settings. The mini-player appears as `bottomNavigationBar` only when `AudioService.hasTrack` is true.

### Theming
Single dark theme defined in `lib/theme/app_theme.dart`. All colors are in `AppColors` constants — use these rather than hardcoding color values. Font family is `ZenKakuGothicNew` (assets in `assets/fonts/`).

### Localization
ARB source files live in `lib/l10n/` (`app_en.arb`, `app_ru.arb`). Generated Dart classes (`AppLocalizations`) are committed alongside. After editing ARBs, run `flutter gen-l10n`. Access strings in widgets via `AppLocalizations.of(context)!`.

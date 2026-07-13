# CodeRecall

Offline-first skill refreshers and quizzes for senior and staff-level
developers. No login, no ads, no tracking — all progress lives on your device.

**Content lives in [coderecall-content](https://github.com/rwaqar960/coderecall-content)** —
this repo is the Flutter app that delivers it.

## Principles

- **Fully offline** after install (basics courses are bundled; advanced packs
  are a one-time download from GitHub Releases).
- **No accounts, no analytics.** Progress is stored locally (Drift/SQLite).
- **No ads, ever.** If CodeRecall helps you, sponsorship links are in the app.
- Free and open source under [MIT](LICENSE); content is CC BY-NC-SA.

## Architecture

```
lib/
  main.dart                     # app shell, theme, AppScope (DI)
  src/
    models/                     # Course / Chapter / Quiz (parsed from content JSON)
    data/
      content_repository.dart   # loads bundled packs from assets
      progress_db.dart          # Drift database: per-chapter read + quiz progress
      settings_controller.dart  # theme mode + onboarding state (persisted)
    ui/
      landing_screen.dart       # first-run onboarding
      course_list_screen.dart   # home: courses + progress bars + theme switcher
      chapter_list_screen.dart  # chapters with status and best scores
      chapter_screen.dart       # Markdown reader
      quiz_screen.dart          # quiz flow with explanations + results
assets/content/                 # bundled content packs (copied from coderecall-content)
```

## Development

```sh
flutter pub get
dart run build_runner build     # regenerate Drift code after schema changes
flutter run
```

Bundled content is copied from the `coderecall-content` repo via
`tool/sync-content.ps1` (reads `assets/content/packs.json` for which courses
to bundle). Run it after content changes, then rebuild.

## CI/CD

- **`.github/workflows/ci.yml`** — `flutter analyze` + a debug build on every
  push/PR to `main`.
- **`.github/workflows/release.yml`** — pushing a tag like `v1.0.0` builds a
  **signed** release APK and publishes it to a GitHub Release:
  ```sh
  git tag v1.0.0
  git push origin v1.0.0
  ```
  The workflow decodes the release keystore from repo secrets, builds, and
  verifies the APK is actually signed with the release key (not a silent
  debug-key fallback) before publishing.

### Release signing setup (one-time, already done for this repo)

Release builds sign with `android/key.properties` (git-ignored, never
committed), which references a keystore kept **outside this repo entirely**
— losing that keystore means the app can never be updated under the same
identity again, so it's backed up independently of git.

CI needs four repository secrets (Settings → Secrets and variables →
Actions): `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`. Without `key.properties`
present, `build.gradle.kts` falls back to debug signing so a fresh clone
still builds — only release tags require the real secrets.

## Roadmap

- [x] Course → chapter → quiz flow with local progress
- [x] Signed release APK CI/CD (tag push → GitHub Release)
- [ ] Downloadable content packs (GitHub Releases + manifest)
- [ ] Bookmarks and notes
- [ ] Spaced-repetition review of missed questions

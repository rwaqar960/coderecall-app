# CodeRecall

Offline-first skill refreshers and quizzes for senior and staff-level
developers. No login, no ads, no tracking — all progress lives on your device.

**Content lives in [coderecall-content](https://github.com/rwaqar/coderecall-content)** —
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
    ui/
      course_list_screen.dart   # home: courses + progress bars
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

Bundled content is copied from the `coderecall-content` repo into
`assets/content/`. When content changes, re-copy the course folder and rebuild.

## Roadmap

- [x] Course → chapter → quiz flow with local progress
- [ ] Downloadable content packs (GitHub Releases + manifest)
- [ ] Bookmarks and notes
- [ ] Spaced-repetition review of missed questions

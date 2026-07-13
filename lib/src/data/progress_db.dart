import 'dart:math' show max;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'progress_db.g.dart';

/// One row per chapter the user has interacted with. All progress lives
/// on-device — no accounts, no sync, no tracking.
class ChapterProgress extends Table {
  TextColumn get courseId => text()();
  TextColumn get chapterId => text()();
  DateTimeColumn get readAt => dateTime().nullable()();
  IntColumn get bestScore => integer().nullable()();
  IntColumn get quizTotal => integer().nullable()();
  DateTimeColumn get lastQuizAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {courseId, chapterId};
}

@DriftDatabase(tables: [ChapterProgress])
class ProgressDb extends _$ProgressDb {
  ProgressDb() : super(driftDatabase(name: 'coderecall'));

  @override
  int get schemaVersion => 1;

  Stream<List<ChapterProgressData>> watchCourse(String courseId) =>
      (select(chapterProgress)..where((t) => t.courseId.equals(courseId)))
          .watch();

  Future<ChapterProgressData?> _find(String courseId, String chapterId) =>
      (select(chapterProgress)
            ..where((t) =>
                t.courseId.equals(courseId) & t.chapterId.equals(chapterId)))
          .getSingleOrNull();

  Future<void> markRead(String courseId, String chapterId) async {
    final existing = await _find(courseId, chapterId);
    if (existing?.readAt != null) return;
    await into(chapterProgress).insertOnConflictUpdate(
      ChapterProgressCompanion(
        courseId: Value(courseId),
        chapterId: Value(chapterId),
        readAt: Value(DateTime.now()),
        bestScore: Value(existing?.bestScore),
        quizTotal: Value(existing?.quizTotal),
        lastQuizAt: Value(existing?.lastQuizAt),
      ),
    );
  }

  Future<void> saveQuizResult(
      String courseId, String chapterId, int score, int total) async {
    final existing = await _find(courseId, chapterId);
    final best =
        existing?.bestScore == null ? score : max(existing!.bestScore!, score);
    await into(chapterProgress).insertOnConflictUpdate(
      ChapterProgressCompanion(
        courseId: Value(courseId),
        chapterId: Value(chapterId),
        readAt: Value(existing?.readAt ?? DateTime.now()),
        bestScore: Value(best),
        quizTotal: Value(total),
        lastQuizAt: Value(DateTime.now()),
      ),
    );
  }
}

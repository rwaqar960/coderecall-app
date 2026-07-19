import '../data/progress_db.dart';
import '../models/course.dart';

/// The chapter a course's Start/Resume button should open: the first ready
/// chapter without a completed quiz, or the last ready chapter if every one
/// is already done (re-reading/review). Null if the course has no ready
/// chapters yet.
ChapterRef? resumeTarget(Course course, Map<String, ChapterProgressData> progress) {
  final ready = course.readyChapters;
  if (ready.isEmpty) return null;
  for (final chapter in ready) {
    if (progress[chapter.id]?.bestScore == null) return chapter;
  }
  return ready.last;
}

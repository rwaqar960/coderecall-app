import 'package:flutter/material.dart';

import '../../main.dart';
import '../data/progress_db.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';
import '../util/resume.dart';
import 'chapter_screen.dart';

/// Selecting a course lands here first: a brief overview, live progress, and
/// a Start/Resume shortcut into the right chapter — plus the full chapter
/// list below for browsing or re-reading any specific one.
class CourseOverviewScreen extends StatelessWidget {
  const CourseOverviewScreen({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final db = AppScope.of(context).db;
    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: StreamBuilder<List<ChapterProgressData>>(
        stream: db.watchCourse(course.id),
        builder: (context, snapshot) {
          final rows = snapshot.data ?? const <ChapterProgressData>[];
          final progress = {for (final row in rows) row.chapterId: row};
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _OverviewHeader(course: course, rows: rows, progress: progress),
              const SizedBox(height: 24),
              Text('Chapters', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              for (var i = 0; i < course.chapters.length; i++) ...[
                _ChapterTile(
                  course: course,
                  chapter: course.chapters[i],
                  index: i + 1,
                  progress: progress[course.chapters[i].id],
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.course, required this.rows, required this.progress});

  final Course course;
  final List<ChapterProgressData> rows;
  final Map<String, ChapterProgressData> progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ready = course.readyChapters.length;
    final done = rows.where((r) => r.bestScore != null).length;
    final started = rows.isNotEmpty;
    final target = resumeTarget(course, progress);
    final allDone = ready > 0 && done == ready;
    final buttonLabel = !started
        ? 'Start course'
        : allDone
            ? 'Review course'
            : 'Resume: ${target?.title ?? ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Monogram(courseId: course.id, size: 56),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      Pill(label: course.level),
                      Pill(label: course.primaryLanguage),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(course.description, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            ProgressRing(value: ready == 0 ? 0 : done / ready),
            const SizedBox(width: 12),
            Text(
              '$done of $ready chapters completed',
              style: theme.textTheme.labelMedium!
                  .copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        if (target != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChapterScreen(course: course, chapter: target),
              )),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.course,
    required this.chapter,
    required this.index,
    required this.progress,
  });

  final Course course;
  final ChapterRef chapter;
  final int index;
  final ChapterProgressData? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: theme.colorScheme.outlineVariant),
    );

    if (!chapter.isReady) {
      return Opacity(
        opacity: 0.55,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: shape,
          child: ListTile(
            enabled: false,
            leading: CircleAvatar(child: Text('$index')),
            title: Text(chapter.title),
            subtitle: const Text('Coming soon'),
          ),
        ),
      );
    }
    final read = progress?.readAt != null;
    final score = progress?.bestScore;
    final total = progress?.quizTotal;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: shape,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
        leading: CircleAvatar(
          backgroundColor:
              score != null ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          foregroundColor: score != null
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
          child: score != null ? const Icon(Icons.check, size: 18) : Text('$index'),
        ),
        title: Text(chapter.title, style: theme.textTheme.titleSmall),
        subtitle: Text(
          score != null
              ? 'Best quiz score: $score/$total'
              : read
                  ? 'Read · quiz not taken'
                  : 'Not started',
          style: theme.textTheme.bodySmall!
              .copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ChapterScreen(course: course, chapter: chapter),
        )),
      ),
    );
  }
}

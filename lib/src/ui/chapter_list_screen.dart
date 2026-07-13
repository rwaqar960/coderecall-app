import 'package:flutter/material.dart';

import '../../main.dart';
import '../data/progress_db.dart';
import '../models/course.dart';
import 'chapter_screen.dart';

class ChapterListScreen extends StatelessWidget {
  const ChapterListScreen({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final db = AppScope.of(context).db;
    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: StreamBuilder<List<ChapterProgressData>>(
        stream: db.watchCourse(course.id),
        builder: (context, snapshot) {
          final progress = {
            for (final row in snapshot.data ?? const <ChapterProgressData>[])
              row.chapterId: row
          };
          return ListView.separated(
            itemCount: course.chapters.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final chapter = course.chapters[i];
              return _ChapterTile(
                course: course,
                chapter: chapter,
                index: i + 1,
                progress: progress[chapter.id],
              );
            },
          );
        },
      ),
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
    if (!chapter.isReady) {
      return ListTile(
        enabled: false,
        leading: CircleAvatar(child: Text('$index')),
        title: Text(chapter.title),
        subtitle: const Text('Coming soon'),
      );
    }
    final read = progress?.readAt != null;
    final score = progress?.bestScore;
    final total = progress?.quizTotal;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            score != null ? theme.colorScheme.primary : null,
        foregroundColor: score != null ? theme.colorScheme.onPrimary : null,
        child: score != null ? const Icon(Icons.check) : Text('$index'),
      ),
      title: Text(chapter.title),
      subtitle: Text(
        score != null
            ? 'Best quiz score: $score/$total'
            : read
                ? 'Read · quiz not taken'
                : 'Not started',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChapterScreen(course: course, chapter: chapter),
      )),
    );
  }
}

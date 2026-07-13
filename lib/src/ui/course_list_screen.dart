import 'package:flutter/material.dart';

import '../../main.dart';
import '../data/progress_db.dart';
import '../models/course.dart';
import 'chapter_list_screen.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = AppScope.of(context).content;
    return Scaffold(
      appBar: AppBar(title: const Text('CodeRecall')),
      body: FutureBuilder<List<Course>>(
        future: content.loadCourses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load courses:\n${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final courses = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: courses.length,
            itemBuilder: (context, i) => _CourseCard(course: courses[i]),
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final db = AppScope.of(context).db;
    final theme = Theme.of(context);
    final ready = course.readyChapters.length;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ChapterListScreen(course: course),
        )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(course.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(course.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              StreamBuilder<List<ChapterProgressData>>(
                stream: db.watchCourse(course.id),
                builder: (context, snapshot) {
                  final rows = snapshot.data ?? const [];
                  final done = rows.where((r) => r.bestScore != null).length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: ready == 0 ? 0 : done / ready,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$done of $ready chapters completed'
                        '${course.chapters.length > ready ? ' · ${course.chapters.length - ready} more coming' : ''}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: const Text('CodeRecall'),
            actions: const [_ThemeMenuButton()],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Senior-level refreshers. Offline. Private.',
                style: theme.textTheme.bodyLarge!
                    .copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          FutureBuilder<List<Course>>(
            future: content.loadCourses(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                      child: Text('Failed to load courses:\n${snapshot.error}')),
                );
              }
              if (!snapshot.hasData) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final courses = snapshot.data!;
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList.separated(
                  itemCount: courses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _CourseCard(course: courses[i]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeMenuButton extends StatelessWidget {
  const _ThemeMenuButton();

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    return PopupMenuButton<ThemeMode>(
      icon: const Icon(Icons.brightness_6_outlined),
      tooltip: 'Theme',
      onSelected: settings.setThemeMode,
      itemBuilder: (context) => [
        for (final (mode, label, icon) in [
          (ThemeMode.system, 'System', Icons.brightness_auto_outlined),
          (ThemeMode.light, 'Light', Icons.light_mode_outlined),
          (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
        ])
          PopupMenuItem(
            value: mode,
            child: Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(label)),
                if (settings.themeMode == mode)
                  const Icon(Icons.check, size: 20),
              ],
            ),
          ),
      ],
    );
  }
}

IconData courseIcon(String courseId) => switch (courseId) {
      'oop' => Icons.data_object,
      'dsa' => Icons.account_tree_outlined,
      'algorithms' => Icons.functions,
      'flutter' => Icons.flutter_dash,
      _ => Icons.school_outlined,
    };

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ChapterListScreen(course: course),
        )),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      courseIcon(course.id),
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          '$ready chapter${ready == 1 ? '' : 's'} available'
                          '${course.chapters.length > ready ? ' · ${course.chapters.length - ready} coming' : ''}',
                          style: theme.textTheme.bodySmall!.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                course.description,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              StreamBuilder<List<ChapterProgressData>>(
                stream: db.watchCourse(course.id),
                builder: (context, snapshot) {
                  final rows = snapshot.data ?? const [];
                  final done = rows.where((r) => r.bestScore != null).length;
                  return Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: ready == 0 ? 0 : done / ready,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$done/$ready',
                          style: theme.textTheme.labelMedium),
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

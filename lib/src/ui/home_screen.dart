import 'package:flutter/material.dart';

import '../../main.dart';
import '../data/progress_db.dart';
import '../models/course.dart';
import '../theme/app_theme.dart';
import '../util/resume.dart';
import 'chapter_screen.dart';
import 'course_overview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<CourseListItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= AppScope.of(context).content.loadCourseList();
  }

  void _refresh() {
    setState(() {
      _future = AppScope.of(context).content.loadCourseList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: const Text('CodeRecall'),
            actions: const [_ThemeMenuButton()],
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
            sliver: SliverToBoxAdapter(child: _EducateHeader()),
          ),
          FutureBuilder<List<CourseListItem>>(
            future: _future,
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
              final items = snapshot.data!;
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverList.list(
                  children: [
                    _ContinueCard(items: items),
                    Text('Courses', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    for (final item in items) ...[
                      switch (item) {
                        AvailableCourse(:final course) => _CourseCard(course: course),
                        DownloadablePack pack =>
                          _DownloadableCard(pack: pack, onDownloaded: _refresh),
                      },
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Brief, persistent explanation of what the app is — for returning users
/// who skipped or already saw the full onboarding carousel.
class _EducateHeader extends StatelessWidget {
  const _EducateHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Senior-level skill refreshers — written for developers who '
          'already know how to code. Read a chapter, take the quiz, and '
          'your progress stays only on this device.',
          style: theme.textTheme.bodyLarge!
              .copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Pill(label: 'Offline'),
            Pill(label: 'No login'),
            Pill(label: 'No ads'),
          ],
        ),
      ],
    );
  }
}

/// "Pick up where you left off" — the single most recently active course,
/// jumping straight into its resume chapter (bypasses the course overview
/// screen; this is a shortcut, not a replacement for browsing that course).
class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.items});

  final List<CourseListItem> items;

  @override
  Widget build(BuildContext context) {
    final db = AppScope.of(context).db;
    return StreamBuilder<String?>(
      stream: db.watchMostRecentCourseId(),
      builder: (context, recentSnapshot) {
        final courseId = recentSnapshot.data;
        if (courseId == null) return const SizedBox.shrink();
        final available = items.whereType<AvailableCourse>();
        final match = available.where((c) => c.id == courseId);
        if (match.isEmpty) return const SizedBox.shrink();
        final course = match.first.course;

        return StreamBuilder<List<ChapterProgressData>>(
          stream: db.watchCourse(course.id),
          builder: (context, progressSnapshot) {
            final rows = progressSnapshot.data ?? const [];
            final progress = {for (final r in rows) r.chapterId: r};
            final target = resumeTarget(course, progress);
            if (target == null) return const SizedBox.shrink();
            final done = rows.where((r) => r.bestScore != null).length;
            final total = course.readyChapters.length;
            final theme = Theme.of(context);

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Card(
                elevation: 0,
                color: theme.colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Monogram(courseId: course.id),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Continue · ${course.title}',
                              style: theme.textTheme.labelLarge!.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              target.title,
                              style: theme.textTheme.titleMedium!.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '$done of $total chapters completed',
                              style: theme.textTheme.bodySmall!.copyWith(
                                color: theme.colorScheme.onPrimaryContainer
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ChapterScreen(course: course, chapter: target),
                        )),
                        child: const Text('Resume'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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

class _CourseCardShell extends StatelessWidget {
  const _CourseCardShell({required this.courseId, this.onTap, required this.child, this.highlight = false});

  final String courseId;
  final VoidCallback? onTap;
  final Widget child;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 5, color: highlight ? scheme.primary : scheme.outlineVariant),
            Padding(padding: const EdgeInsets.all(16), child: child),
          ],
        ),
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
    return _CourseCardShell(
      courseId: course.id,
      highlight: true,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CourseOverviewScreen(course: course),
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Monogram(courseId: course.id, size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(course.title, style: theme.textTheme.titleMedium),
                        ),
                        const Pill(label: 'Bundled', emphasis: true),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$ready chapter${ready == 1 ? '' : 's'} available'
                      '${course.chapters.length > ready ? ' · ${course.chapters.length - ready} coming' : ''}',
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                  ProgressRing(value: ready == 0 ? 0 : done / ready),
                  const SizedBox(width: 12),
                  Text(
                    '$done of $ready chapters completed',
                    style: theme.textTheme.labelMedium!
                        .copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DownloadableCard extends StatefulWidget {
  const _DownloadableCard({required this.pack, required this.onDownloaded});

  final DownloadablePack pack;
  final VoidCallback onDownloaded;

  @override
  State<_DownloadableCard> createState() => _DownloadableCardState();
}

enum _DownloadState { idle, downloading, error }

class _DownloadableCardState extends State<_DownloadableCard> {
  _DownloadState _state = _DownloadState.idle;
  double _progress = 0;
  Object? _error;

  Future<void> _download() async {
    setState(() {
      _state = _DownloadState.downloading;
      _progress = 0;
      _error = null;
    });
    try {
      await AppScope.of(context).content.downloadPack(
            widget.pack,
            onProgress: (p) => mounted ? setState(() => _progress = p) : null,
          );
      if (mounted) widget.onDownloaded();
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _DownloadState.error;
          _error = e;
        });
      }
    }
  }

  String _sizeLabel(int? bytes) {
    if (bytes == null) return '';
    final kb = bytes / 1024;
    return kb < 1024 ? ' · ${kb.round()} KB' : ' · ${(kb / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _CourseCardShell(
      courseId: widget.pack.id,
      onTap: _state == _DownloadState.downloading ? null : _download,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Monogram(courseId: widget.pack.id, size: 52, tinted: false),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.pack.title, style: theme.textTheme.titleMedium),
                    ),
                    const Pill(label: 'Downloadable'),
                  ],
                ),
                const SizedBox(height: 2),
                if (_state == _DownloadState.downloading)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 2),
                    child: LinearProgressIndicator(
                      value: _progress > 0 ? _progress : null,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  )
                else
                  Text(
                    _state == _DownloadState.error
                        ? 'Download failed — tap to retry ($_error)'
                        : 'Not downloaded${_sizeLabel(widget.pack.sizeBytes)} · tap to download',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: _state == _DownloadState.error
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (_state != _DownloadState.downloading) ...[
            const SizedBox(width: 8),
            Icon(Icons.download_outlined, color: theme.colorScheme.primary),
          ],
        ],
      ),
    );
  }
}

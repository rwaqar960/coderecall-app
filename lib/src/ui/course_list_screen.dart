import 'package:flutter/material.dart';

import '../../main.dart';
import '../data/progress_db.dart';
import '../models/course.dart';
import 'chapter_list_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  Future<List<CourseListItem>>? _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= AppScope.of(context).content.loadCourseList();
  }

  void _refresh() {
    setState(() => _future = AppScope.of(context).content.loadCourseList());
  }

  @override
  Widget build(BuildContext context) {
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
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => switch (items[i]) {
                    AvailableCourse(:final course) => _CourseCard(course: course),
                    DownloadablePack pack =>
                      _DownloadableCard(pack: pack, onDownloaded: _refresh),
                  },
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

class _CourseCardShell extends StatelessWidget {
  const _CourseCardShell({required this.courseId, this.onTap, required this.child});

  final String courseId;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
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
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChapterListScreen(course: course),
      )),
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
                  Expanded(
                    child: LinearProgressIndicator(
                      value: ready == 0 ? 0 : done / ready,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('$done/$ready', style: theme.textTheme.labelMedium),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(courseIcon(widget.pack.id),
                color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.pack.title, style: theme.textTheme.titleMedium),
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
          if (_state != _DownloadState.downloading)
            Icon(Icons.download_outlined, color: theme.colorScheme.primary),
        ],
      ),
    );
  }
}

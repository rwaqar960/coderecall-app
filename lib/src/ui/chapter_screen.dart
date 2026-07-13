import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../main.dart';
import '../models/course.dart';
import 'quiz_screen.dart';

class ChapterScreen extends StatefulWidget {
  const ChapterScreen({super.key, required this.course, required this.chapter});

  final Course course;
  final ChapterRef chapter;

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  Future<ChapterContent>? _content;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_content != null) return;
    final scope = AppScope.of(context);
    _content = scope.content.loadChapter(widget.course, widget.chapter);
    _content!.then(
      (_) => scope.db.markRead(widget.course.id, widget.chapter.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.chapter.title)),
      body: FutureBuilder<ChapterContent>(
        future: _content,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load chapter:\n${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chapter = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.schedule, size: 18),
                    label: Text('${chapter.minutes} min'),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    label: Text(chapter.level),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              MarkdownBody(
                data: chapter.body,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                  codeblockDecoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('Take the quiz'),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    course: widget.course,
                    chapter: widget.chapter,
                  ),
                )),
              ),
            ],
          );
        },
      ),
    );
  }
}

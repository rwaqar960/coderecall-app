import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../main.dart';
import '../models/course.dart';
import '../models/quiz.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.course, required this.chapter});

  final Course course;
  final ChapterRef chapter;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Future<Quiz>? _quiz;
  int _index = 0;
  int _score = 0;
  bool _revealed = false;
  bool _finished = false;
  final Set<String> _selected = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _quiz ??= AppScope.of(context).content.loadQuiz(widget.course, widget.chapter);
  }

  void _check(Question question) {
    setState(() {
      _revealed = true;
      if (question.isCorrect(_selected)) _score++;
    });
  }

  Future<void> _next(Quiz quiz) async {
    if (_index + 1 < quiz.questions.length) {
      setState(() {
        _index++;
        _revealed = false;
        _selected.clear();
      });
      return;
    }
    await AppScope.of(context).db.saveQuizResult(
        widget.course.id, widget.chapter.id, _score, quiz.questions.length);
    if (mounted) setState(() => _finished = true);
  }

  void _retry() => setState(() {
        _index = 0;
        _score = 0;
        _revealed = false;
        _finished = false;
        _selected.clear();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz · ${widget.chapter.title}')),
      body: FutureBuilder<Quiz>(
        future: _quiz,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load quiz:\n${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final quiz = snapshot.data!;
          if (_finished) return _ResultView(quiz: quiz, score: _score, onRetry: _retry);
          return _questionView(context, quiz);
        },
      ),
    );
  }

  Widget _questionView(BuildContext context, Quiz quiz) {
    final theme = Theme.of(context);
    final question = quiz.questions[_index];
    final markdownStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: (_index + (_revealed ? 1 : 0)) / quiz.questions.length,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Text('${_index + 1}/${quiz.questions.length}',
                style: theme.textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            Chip(
              label: Text(question.difficulty),
              visualDensity: VisualDensity.compact,
            ),
            if (question.type == QuestionType.multi)
              const Chip(
                label: Text('select all that apply'),
                visualDensity: VisualDensity.compact,
              ),
            if (question.type == QuestionType.codeReview)
              const Chip(
                label: Text('code review'),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 8),
        MarkdownBody(data: question.prompt, styleSheet: markdownStyle),
        if (question.code != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              question.code!,
              style: theme.textTheme.bodySmall!.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ],
        const SizedBox(height: 16),
        for (final option in question.options)
          _OptionCard(
            option: option,
            question: question,
            selected: _selected.contains(option.id),
            revealed: _revealed,
            onTap: _revealed
                ? null
                : () => setState(() {
                      if (question.type == QuestionType.multi) {
                        _selected.contains(option.id)
                            ? _selected.remove(option.id)
                            : _selected.add(option.id);
                      } else {
                        _selected
                          ..clear()
                          ..add(option.id);
                      }
                    }),
          ),
        const SizedBox(height: 16),
        if (_revealed) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: question.isCorrect(_selected)
                  ? theme.colorScheme.secondaryContainer
                  : theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.isCorrect(_selected) ? 'Correct' : 'Not quite',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                MarkdownBody(
                    data: question.explanation, styleSheet: markdownStyle),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => _next(quiz),
            child: Text(_index + 1 < quiz.questions.length ? 'Next' : 'Finish'),
          ),
        ] else
          FilledButton(
            onPressed: _selected.isEmpty ? null : () => _check(question),
            child: const Text('Check answer'),
          ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.question,
    required this.selected,
    required this.revealed,
    required this.onTap,
  });

  final QuizOption option;
  final Question question;
  final bool selected;
  final bool revealed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAnswer = question.answer.contains(option.id);
    Color? border;
    if (revealed && isAnswer) {
      border = theme.colorScheme.primary;
    } else if (revealed && selected && !isAnswer) {
      border = theme.colorScheme.error;
    } else if (selected) {
      border = theme.colorScheme.primary;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: border != null
            ? BorderSide(color: border, width: 2)
            : BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${option.id})  ', style: theme.textTheme.labelLarge),
              Expanded(
                child: MarkdownBody(
                  data: option.text,
                  styleSheet: MarkdownStyleSheet.fromTheme(theme),
                ),
              ),
              if (revealed && isAnswer)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
              if (revealed && selected && !isAnswer)
                Icon(Icons.cancel, color: theme.colorScheme.error),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.quiz, required this.score, required this.onRetry});

  final Quiz quiz;
  final int score;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = quiz.questions.length;
    final passed = total > 0 && score / total >= quiz.passScore;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              passed ? Icons.emoji_events_outlined : Icons.replay,
              size: 64,
              color: passed ? theme.colorScheme.primary : theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('$score / $total', style: theme.textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              passed
                  ? 'Passed — chapter complete.'
                  : 'Below ${(quiz.passScore * 100).round()}% — worth another read.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

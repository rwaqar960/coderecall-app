import 'package:flutter/material.dart';

import 'src/data/content_repository.dart';
import 'src/data/progress_db.dart';
import 'src/ui/course_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppScope(
    content: ContentRepository(),
    db: ProgressDb(),
    child: const CodeRecallApp(),
  ));
}

/// Gives every screen access to the content repository and progress DB
/// without a state-management dependency.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.content,
    required this.db,
    required super.child,
  });

  final ContentRepository content;
  final ProgressDb db;

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      content != oldWidget.content || db != oldWidget.db;
}

class CodeRecallApp extends StatelessWidget {
  const CodeRecallApp({super.key});

  static const _seed = Color(0xFF00696B);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeRecall',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const CourseListScreen(),
    );
  }
}

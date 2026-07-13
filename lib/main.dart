import 'package:flutter/material.dart';

import 'src/data/content_repository.dart';
import 'src/data/progress_db.dart';
import 'src/data/settings_controller.dart';
import 'src/ui/course_list_screen.dart';
import 'src/ui/landing_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await SettingsController.load();
  runApp(AppScope(
    content: ContentRepository(),
    db: ProgressDb(),
    settings: settings,
    child: const CodeRecallApp(),
  ));
}

/// Gives every screen access to the content repository, progress DB, and
/// settings without a state-management dependency.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.content,
    required this.db,
    required this.settings,
    required super.child,
  });

  final ContentRepository content;
  final ProgressDb db;
  final SettingsController settings;

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      content != oldWidget.content ||
      db != oldWidget.db ||
      settings != oldWidget.settings;
}

class CodeRecallApp extends StatelessWidget {
  const CodeRecallApp({super.key});

  static const seed = Color(0xFF00696B);

  static ThemeData _theme(Brightness brightness) => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
        useMaterial3: true,
        cardTheme: const CardThemeData(elevation: 0),
      );

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'CodeRecall',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: settings.themeMode,
        home: settings.onboardingSeen
            ? const CourseListScreen()
            : const LandingScreen(),
      ),
    );
  }
}

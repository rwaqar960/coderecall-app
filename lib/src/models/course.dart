/// Course metadata parsed from a content pack's `course.json`.
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.version,
    required this.level,
    required this.bundled,
    required this.primaryLanguage,
    required this.description,
    required this.chapters,
  });

  final String id;
  final String title;
  final String version;
  final String level;
  final bool bundled;
  final String primaryLanguage;
  final String description;
  final List<ChapterRef> chapters;

  List<ChapterRef> get readyChapters =>
      chapters.where((c) => c.isReady).toList();

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        title: json['title'] as String,
        version: json['version'] as String,
        level: json['level'] as String,
        bundled: json['bundled'] as bool,
        primaryLanguage: json['primaryLanguage'] as String,
        description: json['description'] as String,
        chapters: (json['chapters'] as List)
            .map((c) => ChapterRef.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}

class ChapterRef {
  const ChapterRef({
    required this.id,
    required this.title,
    required this.file,
    required this.quiz,
    required this.status,
  });

  final String id;
  final String title;
  final String file;
  final String quiz;
  final String status;

  bool get isReady => status == 'ready';

  factory ChapterRef.fromJson(Map<String, dynamic> json) => ChapterRef(
        id: json['id'] as String,
        title: json['title'] as String,
        file: json['file'] as String,
        quiz: json['quiz'] as String,
        status: json['status'] as String,
      );
}

/// A chapter's parsed front matter plus its Markdown body.
class ChapterContent {
  const ChapterContent({
    required this.title,
    required this.minutes,
    required this.level,
    required this.body,
  });

  final String title;
  final int minutes;
  final String level;
  final String body;
}

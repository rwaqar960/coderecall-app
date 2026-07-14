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

/// One entry in the home course list: either a course ready to read
/// ([AvailableCourse] — bundled, or previously downloaded) or a pack
/// advertised by the remote manifest that hasn't been fetched yet
/// ([DownloadablePack]). Closed set, so a sealed class rather than one
/// [Course] with nullable/empty fields standing in for "not downloaded."
sealed class CourseListItem {
  const CourseListItem();
  String get id;
  String get title;
}

class AvailableCourse extends CourseListItem {
  const AvailableCourse(this.course);
  final Course course;
  @override
  String get id => course.id;
  @override
  String get title => course.title;
}

class DownloadablePack extends CourseListItem {
  const DownloadablePack({
    required this.id,
    required this.title,
    required this.version,
    required this.url,
    required this.sizeBytes,
  });

  @override
  final String id;
  @override
  final String title;
  final String version;
  final String url;
  final int? sizeBytes;
}

/// A content pack entry from the remote manifest.json.
class ManifestPack {
  const ManifestPack({
    required this.id,
    required this.title,
    required this.version,
    required this.bundled,
    required this.url,
    required this.sizeBytes,
  });

  final String id;
  final String title;
  final String version;
  final bool bundled;
  final String? url;
  final int? sizeBytes;

  factory ManifestPack.fromJson(Map<String, dynamic> json) => ManifestPack(
        id: json['id'] as String,
        title: json['title'] as String,
        version: json['version'] as String,
        bundled: json['bundled'] as bool,
        url: json['url'] as String?,
        sizeBytes: json['sizeBytes'] as int?,
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

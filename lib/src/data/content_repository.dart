import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';

import '../models/course.dart';
import '../models/quiz.dart';

/// Loads course content. Bundled packs come from app assets; downloaded
/// packs (GitHub Releases) will be added behind the same interface later.
class ContentRepository {
  final Map<String, Course> _courseCache = {};

  Future<List<Course>> loadCourses() async {
    if (_courseCache.isNotEmpty) return _courseCache.values.toList();
    final packsRaw = await rootBundle.loadString('assets/content/packs.json');
    final bundled =
        (jsonDecode(packsRaw)['bundled'] as List).cast<String>();
    for (final id in bundled) {
      final raw =
          await rootBundle.loadString('assets/content/$id/course.json');
      final course = Course.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _courseCache[course.id] = course;
    }
    return _courseCache.values.toList();
  }

  Future<ChapterContent> loadChapter(Course course, ChapterRef ref) async {
    final raw =
        await rootBundle.loadString('assets/content/${course.id}/${ref.file}');
    return _parseChapter(raw, fallbackTitle: ref.title);
  }

  Future<Quiz> loadQuiz(Course course, ChapterRef ref) async {
    final raw =
        await rootBundle.loadString('assets/content/${course.id}/${ref.quiz}');
    return Quiz.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static final _frontMatter =
      RegExp(r'^---\s*\n(.*?)\n---\s*\n', dotAll: true);

  ChapterContent _parseChapter(String raw, {required String fallbackTitle}) {
    final match = _frontMatter.firstMatch(raw);
    if (match == null) {
      return ChapterContent(
          title: fallbackTitle, minutes: 0, level: 'senior', body: raw);
    }
    final meta = loadYaml(match.group(1)!) as YamlMap;
    return ChapterContent(
      title: (meta['title'] as String?) ?? fallbackTitle,
      minutes: (meta['minutes'] as int?) ?? 0,
      level: (meta['level'] as String?) ?? 'senior',
      body: raw.substring(match.end),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:yaml/yaml.dart';

import '../models/course.dart';
import '../models/quiz.dart';

const _manifestUrl =
    'https://raw.githubusercontent.com/rwaqar960/coderecall-content/main/manifest.json';

/// Loads course content. Bundled packs come from app assets; downloadable
/// packs are fetched as a zip from a GitHub Release (per manifest.json),
/// extracted into the app's documents directory, and read from there —
/// same [Course]/[ChapterRef] shape either way, so the rest of the app
/// never needs to know which source a course came from.
class ContentRepository {
  final Map<String, Course> _bundledCache = {};

  Future<List<Course>> _loadBundled() async {
    if (_bundledCache.isNotEmpty) return _bundledCache.values.toList();
    final packsRaw = await rootBundle.loadString('assets/content/packs.json');
    final bundled = (jsonDecode(packsRaw)['bundled'] as List).cast<String>();
    for (final id in bundled) {
      final raw =
          await rootBundle.loadString('assets/content/$id/course.json');
      final course = Course.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      _bundledCache[course.id] = course;
    }
    return _bundledCache.values.toList();
  }

  Future<Directory> _packDir(String packId) async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}/content/$packId');
  }

  Future<Course?> _loadDownloadedCourse(String packId) async {
    final courseFile = File('${(await _packDir(packId)).path}/course.json');
    if (!await courseFile.exists()) return null;
    final raw = await courseFile.readAsString();
    return Course.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Best-effort fetch of the remote pack index. Throws on network failure
  /// — callers decide how to degrade (the course list falls back to
  /// bundled + already-downloaded packs when this fails, which is the
  /// point: downloadable packs are a bonus, never a requirement to use
  /// the app offline).
  Future<List<ManifestPack>> fetchManifest() async {
    final res = await http.get(Uri.parse(_manifestUrl)).timeout(
          const Duration(seconds: 8),
        );
    if (res.statusCode != 200) {
      throw HttpException('manifest fetch failed: ${res.statusCode}');
    }
    final packs = jsonDecode(res.body)['packs'] as List;
    return packs
        .map((p) => ManifestPack.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  /// The home course list: every bundled course, plus every non-bundled
  /// manifest pack — as [AvailableCourse] if already downloaded, else as
  /// a [DownloadablePack] the UI can offer to fetch. If the manifest fetch
  /// fails (offline), only bundled courses and previously-downloaded packs
  /// are shown — no partial/broken entries.
  Future<List<CourseListItem>> loadCourseList() async {
    final items = <CourseListItem>[
      for (final c in await _loadBundled()) AvailableCourse(c),
    ];

    List<ManifestPack> remotePacks;
    try {
      remotePacks = await fetchManifest();
    } catch (_) {
      remotePacks = [];
    }

    for (final pack in remotePacks.where((p) => !p.bundled)) {
      final downloaded = await _loadDownloadedCourse(pack.id);
      items.add(
        downloaded != null
            ? AvailableCourse(downloaded)
            : DownloadablePack(
                id: pack.id,
                title: pack.title,
                version: pack.version,
                url: pack.url!,
                sizeBytes: pack.sizeBytes,
              ),
      );
    }
    return items;
  }

  /// Downloads and extracts a pack, reporting progress in [0, 1] when the
  /// server sends a Content-Length (some CDNs omit it; progress is simply
  /// not reported in that case, not an error).
  Future<Course> downloadPack(
    DownloadablePack pack, {
    void Function(double progress)? onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(pack.url));
    final streamed = await http.Client().send(request);
    if (streamed.statusCode != 200) {
      throw HttpException('download failed: ${streamed.statusCode}');
    }

    final total = streamed.contentLength;
    var received = 0;
    final bytes = <int>[];
    await for (final chunk in streamed.stream) {
      bytes.addAll(chunk);
      received += chunk.length;
      if (total != null && total > 0) onProgress?.call(received / total);
    }

    final archive = ZipDecoder().decodeBytes(bytes);
    final dir = await _packDir(pack.id);
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    for (final entry in archive) {
      final outPath = '${dir.path}/${entry.name}';
      if (entry.isFile) {
        final file = File(outPath);
        await file.create(recursive: true);
        await file.writeAsBytes(entry.content as List<int>);
      } else {
        await Directory(outPath).create(recursive: true);
      }
    }

    final course = await _loadDownloadedCourse(pack.id);
    if (course == null) {
      throw const FormatException('downloaded pack has no course.json');
    }
    return course;
  }

  Future<ChapterContent> loadChapter(Course course, ChapterRef ref) async {
    final raw = course.bundled
        ? await rootBundle.loadString('assets/content/${course.id}/${ref.file}')
        : await File('${(await _packDir(course.id)).path}/${ref.file}')
            .readAsString();
    return _parseChapter(raw, fallbackTitle: ref.title);
  }

  Future<Quiz> loadQuiz(Course course, ChapterRef ref) async {
    final raw = course.bundled
        ? await rootBundle.loadString('assets/content/${course.id}/${ref.quiz}')
        : await File('${(await _packDir(course.id)).path}/${ref.quiz}')
            .readAsString();
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

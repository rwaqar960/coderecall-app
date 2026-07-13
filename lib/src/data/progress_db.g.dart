// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_db.dart';

// ignore_for_file: type=lint
class $ChapterProgressTable extends ChapterProgress
    with TableInfo<$ChapterProgressTable, ChapterProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestScoreMeta = const VerificationMeta(
    'bestScore',
  );
  @override
  late final GeneratedColumn<int> bestScore = GeneratedColumn<int>(
    'best_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quizTotalMeta = const VerificationMeta(
    'quizTotal',
  );
  @override
  late final GeneratedColumn<int> quizTotal = GeneratedColumn<int>(
    'quiz_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastQuizAtMeta = const VerificationMeta(
    'lastQuizAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastQuizAt = GeneratedColumn<DateTime>(
    'last_quiz_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    courseId,
    chapterId,
    readAt,
    bestScore,
    quizTotal,
    lastQuizAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('best_score')) {
      context.handle(
        _bestScoreMeta,
        bestScore.isAcceptableOrUnknown(data['best_score']!, _bestScoreMeta),
      );
    }
    if (data.containsKey('quiz_total')) {
      context.handle(
        _quizTotalMeta,
        quizTotal.isAcceptableOrUnknown(data['quiz_total']!, _quizTotalMeta),
      );
    }
    if (data.containsKey('last_quiz_at')) {
      context.handle(
        _lastQuizAtMeta,
        lastQuizAt.isAcceptableOrUnknown(
          data['last_quiz_at']!,
          _lastQuizAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {courseId, chapterId};
  @override
  ChapterProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterProgressData(
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      bestScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_score'],
      ),
      quizTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiz_total'],
      ),
      lastQuizAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_quiz_at'],
      ),
    );
  }

  @override
  $ChapterProgressTable createAlias(String alias) {
    return $ChapterProgressTable(attachedDatabase, alias);
  }
}

class ChapterProgressData extends DataClass
    implements Insertable<ChapterProgressData> {
  final String courseId;
  final String chapterId;
  final DateTime? readAt;
  final int? bestScore;
  final int? quizTotal;
  final DateTime? lastQuizAt;
  const ChapterProgressData({
    required this.courseId,
    required this.chapterId,
    this.readAt,
    this.bestScore,
    this.quizTotal,
    this.lastQuizAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['course_id'] = Variable<String>(courseId);
    map['chapter_id'] = Variable<String>(chapterId);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    if (!nullToAbsent || bestScore != null) {
      map['best_score'] = Variable<int>(bestScore);
    }
    if (!nullToAbsent || quizTotal != null) {
      map['quiz_total'] = Variable<int>(quizTotal);
    }
    if (!nullToAbsent || lastQuizAt != null) {
      map['last_quiz_at'] = Variable<DateTime>(lastQuizAt);
    }
    return map;
  }

  ChapterProgressCompanion toCompanion(bool nullToAbsent) {
    return ChapterProgressCompanion(
      courseId: Value(courseId),
      chapterId: Value(chapterId),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      bestScore: bestScore == null && nullToAbsent
          ? const Value.absent()
          : Value(bestScore),
      quizTotal: quizTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(quizTotal),
      lastQuizAt: lastQuizAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastQuizAt),
    );
  }

  factory ChapterProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterProgressData(
      courseId: serializer.fromJson<String>(json['courseId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      bestScore: serializer.fromJson<int?>(json['bestScore']),
      quizTotal: serializer.fromJson<int?>(json['quizTotal']),
      lastQuizAt: serializer.fromJson<DateTime?>(json['lastQuizAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'courseId': serializer.toJson<String>(courseId),
      'chapterId': serializer.toJson<String>(chapterId),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'bestScore': serializer.toJson<int?>(bestScore),
      'quizTotal': serializer.toJson<int?>(quizTotal),
      'lastQuizAt': serializer.toJson<DateTime?>(lastQuizAt),
    };
  }

  ChapterProgressData copyWith({
    String? courseId,
    String? chapterId,
    Value<DateTime?> readAt = const Value.absent(),
    Value<int?> bestScore = const Value.absent(),
    Value<int?> quizTotal = const Value.absent(),
    Value<DateTime?> lastQuizAt = const Value.absent(),
  }) => ChapterProgressData(
    courseId: courseId ?? this.courseId,
    chapterId: chapterId ?? this.chapterId,
    readAt: readAt.present ? readAt.value : this.readAt,
    bestScore: bestScore.present ? bestScore.value : this.bestScore,
    quizTotal: quizTotal.present ? quizTotal.value : this.quizTotal,
    lastQuizAt: lastQuizAt.present ? lastQuizAt.value : this.lastQuizAt,
  );
  ChapterProgressData copyWithCompanion(ChapterProgressCompanion data) {
    return ChapterProgressData(
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      bestScore: data.bestScore.present ? data.bestScore.value : this.bestScore,
      quizTotal: data.quizTotal.present ? data.quizTotal.value : this.quizTotal,
      lastQuizAt: data.lastQuizAt.present
          ? data.lastQuizAt.value
          : this.lastQuizAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressData(')
          ..write('courseId: $courseId, ')
          ..write('chapterId: $chapterId, ')
          ..write('readAt: $readAt, ')
          ..write('bestScore: $bestScore, ')
          ..write('quizTotal: $quizTotal, ')
          ..write('lastQuizAt: $lastQuizAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    courseId,
    chapterId,
    readAt,
    bestScore,
    quizTotal,
    lastQuizAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterProgressData &&
          other.courseId == this.courseId &&
          other.chapterId == this.chapterId &&
          other.readAt == this.readAt &&
          other.bestScore == this.bestScore &&
          other.quizTotal == this.quizTotal &&
          other.lastQuizAt == this.lastQuizAt);
}

class ChapterProgressCompanion extends UpdateCompanion<ChapterProgressData> {
  final Value<String> courseId;
  final Value<String> chapterId;
  final Value<DateTime?> readAt;
  final Value<int?> bestScore;
  final Value<int?> quizTotal;
  final Value<DateTime?> lastQuizAt;
  final Value<int> rowid;
  const ChapterProgressCompanion({
    this.courseId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.readAt = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.quizTotal = const Value.absent(),
    this.lastQuizAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterProgressCompanion.insert({
    required String courseId,
    required String chapterId,
    this.readAt = const Value.absent(),
    this.bestScore = const Value.absent(),
    this.quizTotal = const Value.absent(),
    this.lastQuizAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : courseId = Value(courseId),
       chapterId = Value(chapterId);
  static Insertable<ChapterProgressData> custom({
    Expression<String>? courseId,
    Expression<String>? chapterId,
    Expression<DateTime>? readAt,
    Expression<int>? bestScore,
    Expression<int>? quizTotal,
    Expression<DateTime>? lastQuizAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (courseId != null) 'course_id': courseId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (readAt != null) 'read_at': readAt,
      if (bestScore != null) 'best_score': bestScore,
      if (quizTotal != null) 'quiz_total': quizTotal,
      if (lastQuizAt != null) 'last_quiz_at': lastQuizAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterProgressCompanion copyWith({
    Value<String>? courseId,
    Value<String>? chapterId,
    Value<DateTime?>? readAt,
    Value<int?>? bestScore,
    Value<int?>? quizTotal,
    Value<DateTime?>? lastQuizAt,
    Value<int>? rowid,
  }) {
    return ChapterProgressCompanion(
      courseId: courseId ?? this.courseId,
      chapterId: chapterId ?? this.chapterId,
      readAt: readAt ?? this.readAt,
      bestScore: bestScore ?? this.bestScore,
      quizTotal: quizTotal ?? this.quizTotal,
      lastQuizAt: lastQuizAt ?? this.lastQuizAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (bestScore.present) {
      map['best_score'] = Variable<int>(bestScore.value);
    }
    if (quizTotal.present) {
      map['quiz_total'] = Variable<int>(quizTotal.value);
    }
    if (lastQuizAt.present) {
      map['last_quiz_at'] = Variable<DateTime>(lastQuizAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressCompanion(')
          ..write('courseId: $courseId, ')
          ..write('chapterId: $chapterId, ')
          ..write('readAt: $readAt, ')
          ..write('bestScore: $bestScore, ')
          ..write('quizTotal: $quizTotal, ')
          ..write('lastQuizAt: $lastQuizAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ProgressDb extends GeneratedDatabase {
  _$ProgressDb(QueryExecutor e) : super(e);
  $ProgressDbManager get managers => $ProgressDbManager(this);
  late final $ChapterProgressTable chapterProgress = $ChapterProgressTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [chapterProgress];
}

typedef $$ChapterProgressTableCreateCompanionBuilder =
    ChapterProgressCompanion Function({
      required String courseId,
      required String chapterId,
      Value<DateTime?> readAt,
      Value<int?> bestScore,
      Value<int?> quizTotal,
      Value<DateTime?> lastQuizAt,
      Value<int> rowid,
    });
typedef $$ChapterProgressTableUpdateCompanionBuilder =
    ChapterProgressCompanion Function({
      Value<String> courseId,
      Value<String> chapterId,
      Value<DateTime?> readAt,
      Value<int?> bestScore,
      Value<int?> quizTotal,
      Value<DateTime?> lastQuizAt,
      Value<int> rowid,
    });

class $$ChapterProgressTableFilterComposer
    extends Composer<_$ProgressDb, $ChapterProgressTable> {
  $$ChapterProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quizTotal => $composableBuilder(
    column: $table.quizTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastQuizAt => $composableBuilder(
    column: $table.lastQuizAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChapterProgressTableOrderingComposer
    extends Composer<_$ProgressDb, $ChapterProgressTable> {
  $$ChapterProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestScore => $composableBuilder(
    column: $table.bestScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quizTotal => $composableBuilder(
    column: $table.quizTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastQuizAt => $composableBuilder(
    column: $table.lastQuizAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChapterProgressTableAnnotationComposer
    extends Composer<_$ProgressDb, $ChapterProgressTable> {
  $$ChapterProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<int> get bestScore =>
      $composableBuilder(column: $table.bestScore, builder: (column) => column);

  GeneratedColumn<int> get quizTotal =>
      $composableBuilder(column: $table.quizTotal, builder: (column) => column);

  GeneratedColumn<DateTime> get lastQuizAt => $composableBuilder(
    column: $table.lastQuizAt,
    builder: (column) => column,
  );
}

class $$ChapterProgressTableTableManager
    extends
        RootTableManager<
          _$ProgressDb,
          $ChapterProgressTable,
          ChapterProgressData,
          $$ChapterProgressTableFilterComposer,
          $$ChapterProgressTableOrderingComposer,
          $$ChapterProgressTableAnnotationComposer,
          $$ChapterProgressTableCreateCompanionBuilder,
          $$ChapterProgressTableUpdateCompanionBuilder,
          (
            ChapterProgressData,
            BaseReferences<
              _$ProgressDb,
              $ChapterProgressTable,
              ChapterProgressData
            >,
          ),
          ChapterProgressData,
          PrefetchHooks Function()
        > {
  $$ChapterProgressTableTableManager(
    _$ProgressDb db,
    $ChapterProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChapterProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> courseId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<int?> bestScore = const Value.absent(),
                Value<int?> quizTotal = const Value.absent(),
                Value<DateTime?> lastQuizAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterProgressCompanion(
                courseId: courseId,
                chapterId: chapterId,
                readAt: readAt,
                bestScore: bestScore,
                quizTotal: quizTotal,
                lastQuizAt: lastQuizAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String courseId,
                required String chapterId,
                Value<DateTime?> readAt = const Value.absent(),
                Value<int?> bestScore = const Value.absent(),
                Value<int?> quizTotal = const Value.absent(),
                Value<DateTime?> lastQuizAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChapterProgressCompanion.insert(
                courseId: courseId,
                chapterId: chapterId,
                readAt: readAt,
                bestScore: bestScore,
                quizTotal: quizTotal,
                lastQuizAt: lastQuizAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChapterProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$ProgressDb,
      $ChapterProgressTable,
      ChapterProgressData,
      $$ChapterProgressTableFilterComposer,
      $$ChapterProgressTableOrderingComposer,
      $$ChapterProgressTableAnnotationComposer,
      $$ChapterProgressTableCreateCompanionBuilder,
      $$ChapterProgressTableUpdateCompanionBuilder,
      (
        ChapterProgressData,
        BaseReferences<
          _$ProgressDb,
          $ChapterProgressTable,
          ChapterProgressData
        >,
      ),
      ChapterProgressData,
      PrefetchHooks Function()
    >;

class $ProgressDbManager {
  final _$ProgressDb _db;
  $ProgressDbManager(this._db);
  $$ChapterProgressTableTableManager get chapterProgress =>
      $$ChapterProgressTableTableManager(_db, _db.chapterProgress);
}

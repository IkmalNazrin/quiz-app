// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalQuizzesTable extends LocalQuizzes
    with TableInfo<$LocalQuizzesTable, LocalQuiz> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQuizzesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPublicMeta =
      const VerificationMeta('isPublic');
  @override
  late final GeneratedColumn<bool> isPublic = GeneratedColumn<bool>(
      'is_public', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_public" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creatorNameMeta =
      const VerificationMeta('creatorName');
  @override
  late final GeneratedColumn<String> creatorName = GeneratedColumn<String>(
      'creator_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        category,
        isPublic,
        ownerId,
        creatorName,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_quizzes';
  @override
  VerificationContext validateIntegrity(Insertable<LocalQuiz> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('is_public')) {
      context.handle(_isPublicMeta,
          isPublic.isAcceptableOrUnknown(data['is_public']!, _isPublicMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('creator_name')) {
      context.handle(
          _creatorNameMeta,
          creatorName.isAcceptableOrUnknown(
              data['creator_name']!, _creatorNameMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalQuiz map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQuiz(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      isPublic: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_public'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      creatorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}creator_name']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LocalQuizzesTable createAlias(String alias) {
    return $LocalQuizzesTable(attachedDatabase, alias);
  }
}

class LocalQuiz extends DataClass implements Insertable<LocalQuiz> {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final bool isPublic;
  final String ownerId;
  final String? creatorName;
  final DateTime createdAt;
  const LocalQuiz(
      {required this.id,
      required this.title,
      this.description,
      this.category,
      required this.isPublic,
      required this.ownerId,
      this.creatorName,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['is_public'] = Variable<bool>(isPublic);
    map['owner_id'] = Variable<String>(ownerId);
    if (!nullToAbsent || creatorName != null) {
      map['creator_name'] = Variable<String>(creatorName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LocalQuizzesCompanion toCompanion(bool nullToAbsent) {
    return LocalQuizzesCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      isPublic: Value(isPublic),
      ownerId: Value(ownerId),
      creatorName: creatorName == null && nullToAbsent
          ? const Value.absent()
          : Value(creatorName),
      createdAt: Value(createdAt),
    );
  }

  factory LocalQuiz.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQuiz(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      category: serializer.fromJson<String?>(json['category']),
      isPublic: serializer.fromJson<bool>(json['isPublic']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      creatorName: serializer.fromJson<String?>(json['creatorName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'category': serializer.toJson<String?>(category),
      'isPublic': serializer.toJson<bool>(isPublic),
      'ownerId': serializer.toJson<String>(ownerId),
      'creatorName': serializer.toJson<String?>(creatorName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LocalQuiz copyWith(
          {String? id,
          String? title,
          Value<String?> description = const Value.absent(),
          Value<String?> category = const Value.absent(),
          bool? isPublic,
          String? ownerId,
          Value<String?> creatorName = const Value.absent(),
          DateTime? createdAt}) =>
      LocalQuiz(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        category: category.present ? category.value : this.category,
        isPublic: isPublic ?? this.isPublic,
        ownerId: ownerId ?? this.ownerId,
        creatorName: creatorName.present ? creatorName.value : this.creatorName,
        createdAt: createdAt ?? this.createdAt,
      );
  LocalQuiz copyWithCompanion(LocalQuizzesCompanion data) {
    return LocalQuiz(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      category: data.category.present ? data.category.value : this.category,
      isPublic: data.isPublic.present ? data.isPublic.value : this.isPublic,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      creatorName:
          data.creatorName.present ? data.creatorName.value : this.creatorName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuiz(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('isPublic: $isPublic, ')
          ..write('ownerId: $ownerId, ')
          ..write('creatorName: $creatorName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, description, category, isPublic,
      ownerId, creatorName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQuiz &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.isPublic == this.isPublic &&
          other.ownerId == this.ownerId &&
          other.creatorName == this.creatorName &&
          other.createdAt == this.createdAt);
}

class LocalQuizzesCompanion extends UpdateCompanion<LocalQuiz> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> category;
  final Value<bool> isPublic;
  final Value<String> ownerId;
  final Value<String?> creatorName;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const LocalQuizzesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.isPublic = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.creatorName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalQuizzesCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.isPublic = const Value.absent(),
    required String ownerId,
    this.creatorName = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        ownerId = Value(ownerId),
        createdAt = Value(createdAt);
  static Insertable<LocalQuiz> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<bool>? isPublic,
    Expression<String>? ownerId,
    Expression<String>? creatorName,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (isPublic != null) 'is_public': isPublic,
      if (ownerId != null) 'owner_id': ownerId,
      if (creatorName != null) 'creator_name': creatorName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalQuizzesCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<String?>? category,
      Value<bool>? isPublic,
      Value<String>? ownerId,
      Value<String?>? creatorName,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return LocalQuizzesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isPublic: isPublic ?? this.isPublic,
      ownerId: ownerId ?? this.ownerId,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isPublic.present) {
      map['is_public'] = Variable<bool>(isPublic.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (creatorName.present) {
      map['creator_name'] = Variable<String>(creatorName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuizzesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('isPublic: $isPublic, ')
          ..write('ownerId: $ownerId, ')
          ..write('creatorName: $creatorName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalQuestionsTable extends LocalQuestions
    with TableInfo<$LocalQuestionsTable, LocalQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quizIdMeta = const VerificationMeta('quizId');
  @override
  late final GeneratedColumn<String> quizId = GeneratedColumn<String>(
      'quiz_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES local_quizzes (id)'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionsJsonMeta =
      const VerificationMeta('optionsJson');
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
      'options_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _correctIndexMeta =
      const VerificationMeta('correctIndex');
  @override
  late final GeneratedColumn<int> correctIndex = GeneratedColumn<int>(
      'correct_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timerSecondsMeta =
      const VerificationMeta('timerSeconds');
  @override
  late final GeneratedColumn<int> timerSeconds = GeneratedColumn<int>(
      'timer_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(15));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        quizId,
        content,
        optionsJson,
        correctIndex,
        difficulty,
        timerSeconds
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_questions';
  @override
  VerificationContext validateIntegrity(Insertable<LocalQuestion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quiz_id')) {
      context.handle(_quizIdMeta,
          quizId.isAcceptableOrUnknown(data['quiz_id']!, _quizIdMeta));
    } else if (isInserting) {
      context.missing(_quizIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('options_json')) {
      context.handle(
          _optionsJsonMeta,
          optionsJson.isAcceptableOrUnknown(
              data['options_json']!, _optionsJsonMeta));
    } else if (isInserting) {
      context.missing(_optionsJsonMeta);
    }
    if (data.containsKey('correct_index')) {
      context.handle(
          _correctIndexMeta,
          correctIndex.isAcceptableOrUnknown(
              data['correct_index']!, _correctIndexMeta));
    } else if (isInserting) {
      context.missing(_correctIndexMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('timer_seconds')) {
      context.handle(
          _timerSecondsMeta,
          timerSeconds.isAcceptableOrUnknown(
              data['timer_seconds']!, _timerSecondsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalQuestion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      quizId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quiz_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      optionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options_json'])!,
      correctIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct_index'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty']),
      timerSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timer_seconds'])!,
    );
  }

  @override
  $LocalQuestionsTable createAlias(String alias) {
    return $LocalQuestionsTable(attachedDatabase, alias);
  }
}

class LocalQuestion extends DataClass implements Insertable<LocalQuestion> {
  final String id;
  final String quizId;
  final String content;
  final String optionsJson;
  final int correctIndex;
  final String? difficulty;
  final int timerSeconds;
  const LocalQuestion(
      {required this.id,
      required this.quizId,
      required this.content,
      required this.optionsJson,
      required this.correctIndex,
      this.difficulty,
      required this.timerSeconds});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quiz_id'] = Variable<String>(quizId);
    map['content'] = Variable<String>(content);
    map['options_json'] = Variable<String>(optionsJson);
    map['correct_index'] = Variable<int>(correctIndex);
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    map['timer_seconds'] = Variable<int>(timerSeconds);
    return map;
  }

  LocalQuestionsCompanion toCompanion(bool nullToAbsent) {
    return LocalQuestionsCompanion(
      id: Value(id),
      quizId: Value(quizId),
      content: Value(content),
      optionsJson: Value(optionsJson),
      correctIndex: Value(correctIndex),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      timerSeconds: Value(timerSeconds),
    );
  }

  factory LocalQuestion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalQuestion(
      id: serializer.fromJson<String>(json['id']),
      quizId: serializer.fromJson<String>(json['quizId']),
      content: serializer.fromJson<String>(json['content']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      correctIndex: serializer.fromJson<int>(json['correctIndex']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      timerSeconds: serializer.fromJson<int>(json['timerSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'quizId': serializer.toJson<String>(quizId),
      'content': serializer.toJson<String>(content),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'correctIndex': serializer.toJson<int>(correctIndex),
      'difficulty': serializer.toJson<String?>(difficulty),
      'timerSeconds': serializer.toJson<int>(timerSeconds),
    };
  }

  LocalQuestion copyWith(
          {String? id,
          String? quizId,
          String? content,
          String? optionsJson,
          int? correctIndex,
          Value<String?> difficulty = const Value.absent(),
          int? timerSeconds}) =>
      LocalQuestion(
        id: id ?? this.id,
        quizId: quizId ?? this.quizId,
        content: content ?? this.content,
        optionsJson: optionsJson ?? this.optionsJson,
        correctIndex: correctIndex ?? this.correctIndex,
        difficulty: difficulty.present ? difficulty.value : this.difficulty,
        timerSeconds: timerSeconds ?? this.timerSeconds,
      );
  LocalQuestion copyWithCompanion(LocalQuestionsCompanion data) {
    return LocalQuestion(
      id: data.id.present ? data.id.value : this.id,
      quizId: data.quizId.present ? data.quizId.value : this.quizId,
      content: data.content.present ? data.content.value : this.content,
      optionsJson:
          data.optionsJson.present ? data.optionsJson.value : this.optionsJson,
      correctIndex: data.correctIndex.present
          ? data.correctIndex.value
          : this.correctIndex,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      timerSeconds: data.timerSeconds.present
          ? data.timerSeconds.value
          : this.timerSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuestion(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('content: $content, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctIndex: $correctIndex, ')
          ..write('difficulty: $difficulty, ')
          ..write('timerSeconds: $timerSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, quizId, content, optionsJson, correctIndex, difficulty, timerSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalQuestion &&
          other.id == this.id &&
          other.quizId == this.quizId &&
          other.content == this.content &&
          other.optionsJson == this.optionsJson &&
          other.correctIndex == this.correctIndex &&
          other.difficulty == this.difficulty &&
          other.timerSeconds == this.timerSeconds);
}

class LocalQuestionsCompanion extends UpdateCompanion<LocalQuestion> {
  final Value<String> id;
  final Value<String> quizId;
  final Value<String> content;
  final Value<String> optionsJson;
  final Value<int> correctIndex;
  final Value<String?> difficulty;
  final Value<int> timerSeconds;
  final Value<int> rowid;
  const LocalQuestionsCompanion({
    this.id = const Value.absent(),
    this.quizId = const Value.absent(),
    this.content = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.correctIndex = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.timerSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalQuestionsCompanion.insert({
    required String id,
    required String quizId,
    required String content,
    required String optionsJson,
    required int correctIndex,
    this.difficulty = const Value.absent(),
    this.timerSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        quizId = Value(quizId),
        content = Value(content),
        optionsJson = Value(optionsJson),
        correctIndex = Value(correctIndex);
  static Insertable<LocalQuestion> custom({
    Expression<String>? id,
    Expression<String>? quizId,
    Expression<String>? content,
    Expression<String>? optionsJson,
    Expression<int>? correctIndex,
    Expression<String>? difficulty,
    Expression<int>? timerSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quizId != null) 'quiz_id': quizId,
      if (content != null) 'content': content,
      if (optionsJson != null) 'options_json': optionsJson,
      if (correctIndex != null) 'correct_index': correctIndex,
      if (difficulty != null) 'difficulty': difficulty,
      if (timerSeconds != null) 'timer_seconds': timerSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalQuestionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? quizId,
      Value<String>? content,
      Value<String>? optionsJson,
      Value<int>? correctIndex,
      Value<String?>? difficulty,
      Value<int>? timerSeconds,
      Value<int>? rowid}) {
    return LocalQuestionsCompanion(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      content: content ?? this.content,
      optionsJson: optionsJson ?? this.optionsJson,
      correctIndex: correctIndex ?? this.correctIndex,
      difficulty: difficulty ?? this.difficulty,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (quizId.present) {
      map['quiz_id'] = Variable<String>(quizId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (correctIndex.present) {
      map['correct_index'] = Variable<int>(correctIndex.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (timerSeconds.present) {
      map['timer_seconds'] = Variable<int>(timerSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('content: $content, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctIndex: $correctIndex, ')
          ..write('difficulty: $difficulty, ')
          ..write('timerSeconds: $timerSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OfflineMutationsTable extends OfflineMutations
    with TableInfo<$OfflineMutationsTable, OfflineMutation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineMutationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _mutationTypeMeta =
      const VerificationMeta('mutationType');
  @override
  late final GeneratedColumn<String> mutationType = GeneratedColumn<String>(
      'mutation_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, mutationType, payloadJson, createdAt, retryCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_mutations';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineMutation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('mutation_type')) {
      context.handle(
          _mutationTypeMeta,
          mutationType.isAcceptableOrUnknown(
              data['mutation_type']!, _mutationTypeMeta));
    } else if (isInserting) {
      context.missing(_mutationTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineMutation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineMutation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      mutationType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mutation_type'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
    );
  }

  @override
  $OfflineMutationsTable createAlias(String alias) {
    return $OfflineMutationsTable(attachedDatabase, alias);
  }
}

class OfflineMutation extends DataClass implements Insertable<OfflineMutation> {
  final int id;
  final String mutationType;
  final String payloadJson;
  final DateTime createdAt;
  final int retryCount;
  const OfflineMutation(
      {required this.id,
      required this.mutationType,
      required this.payloadJson,
      required this.createdAt,
      required this.retryCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['mutation_type'] = Variable<String>(mutationType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  OfflineMutationsCompanion toCompanion(bool nullToAbsent) {
    return OfflineMutationsCompanion(
      id: Value(id),
      mutationType: Value(mutationType),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
    );
  }

  factory OfflineMutation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineMutation(
      id: serializer.fromJson<int>(json['id']),
      mutationType: serializer.fromJson<String>(json['mutationType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'mutationType': serializer.toJson<String>(mutationType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  OfflineMutation copyWith(
          {int? id,
          String? mutationType,
          String? payloadJson,
          DateTime? createdAt,
          int? retryCount}) =>
      OfflineMutation(
        id: id ?? this.id,
        mutationType: mutationType ?? this.mutationType,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
      );
  OfflineMutation copyWithCompanion(OfflineMutationsCompanion data) {
    return OfflineMutation(
      id: data.id.present ? data.id.value : this.id,
      mutationType: data.mutationType.present
          ? data.mutationType.value
          : this.mutationType,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineMutation(')
          ..write('id: $id, ')
          ..write('mutationType: $mutationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mutationType, payloadJson, createdAt, retryCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineMutation &&
          other.id == this.id &&
          other.mutationType == this.mutationType &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount);
}

class OfflineMutationsCompanion extends UpdateCompanion<OfflineMutation> {
  final Value<int> id;
  final Value<String> mutationType;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  const OfflineMutationsCompanion({
    this.id = const Value.absent(),
    this.mutationType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  });
  OfflineMutationsCompanion.insert({
    this.id = const Value.absent(),
    required String mutationType,
    required String payloadJson,
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
  })  : mutationType = Value(mutationType),
        payloadJson = Value(payloadJson);
  static Insertable<OfflineMutation> custom({
    Expression<int>? id,
    Expression<String>? mutationType,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mutationType != null) 'mutation_type': mutationType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
    });
  }

  OfflineMutationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? mutationType,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<int>? retryCount}) {
    return OfflineMutationsCompanion(
      id: id ?? this.id,
      mutationType: mutationType ?? this.mutationType,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (mutationType.present) {
      map['mutation_type'] = Variable<String>(mutationType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineMutationsCompanion(')
          ..write('id: $id, ')
          ..write('mutationType: $mutationType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalQuizzesTable localQuizzes = $LocalQuizzesTable(this);
  late final $LocalQuestionsTable localQuestions = $LocalQuestionsTable(this);
  late final $OfflineMutationsTable offlineMutations =
      $OfflineMutationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [localQuizzes, localQuestions, offlineMutations];
}

typedef $$LocalQuizzesTableCreateCompanionBuilder = LocalQuizzesCompanion
    Function({
  required String id,
  required String title,
  Value<String?> description,
  Value<String?> category,
  Value<bool> isPublic,
  required String ownerId,
  Value<String?> creatorName,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$LocalQuizzesTableUpdateCompanionBuilder = LocalQuizzesCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<String?> category,
  Value<bool> isPublic,
  Value<String> ownerId,
  Value<String?> creatorName,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$LocalQuizzesTableReferences
    extends BaseReferences<_$AppDatabase, $LocalQuizzesTable, LocalQuiz> {
  $$LocalQuizzesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocalQuestionsTable, List<LocalQuestion>>
      _localQuestionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.localQuestions,
              aliasName: $_aliasNameGenerator(
                  db.localQuizzes.id, db.localQuestions.quizId));

  $$LocalQuestionsTableProcessedTableManager get localQuestionsRefs {
    final manager = $$LocalQuestionsTableTableManager($_db, $_db.localQuestions)
        .filter((f) => f.quizId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localQuestionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$LocalQuizzesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalQuizzesTable> {
  $$LocalQuizzesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPublic => $composableBuilder(
      column: $table.isPublic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get creatorName => $composableBuilder(
      column: $table.creatorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> localQuestionsRefs(
      Expression<bool> Function($$LocalQuestionsTableFilterComposer f) f) {
    final $$LocalQuestionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.localQuestions,
        getReferencedColumn: (t) => t.quizId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalQuestionsTableFilterComposer(
              $db: $db,
              $table: $db.localQuestions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocalQuizzesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalQuizzesTable> {
  $$LocalQuizzesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPublic => $composableBuilder(
      column: $table.isPublic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get creatorName => $composableBuilder(
      column: $table.creatorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalQuizzesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalQuizzesTable> {
  $$LocalQuizzesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isPublic =>
      $composableBuilder(column: $table.isPublic, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get creatorName => $composableBuilder(
      column: $table.creatorName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> localQuestionsRefs<T extends Object>(
      Expression<T> Function($$LocalQuestionsTableAnnotationComposer a) f) {
    final $$LocalQuestionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.localQuestions,
        getReferencedColumn: (t) => t.quizId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalQuestionsTableAnnotationComposer(
              $db: $db,
              $table: $db.localQuestions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$LocalQuizzesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalQuizzesTable,
    LocalQuiz,
    $$LocalQuizzesTableFilterComposer,
    $$LocalQuizzesTableOrderingComposer,
    $$LocalQuizzesTableAnnotationComposer,
    $$LocalQuizzesTableCreateCompanionBuilder,
    $$LocalQuizzesTableUpdateCompanionBuilder,
    (LocalQuiz, $$LocalQuizzesTableReferences),
    LocalQuiz,
    PrefetchHooks Function({bool localQuestionsRefs})> {
  $$LocalQuizzesTableTableManager(_$AppDatabase db, $LocalQuizzesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQuizzesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQuizzesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalQuizzesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<bool> isPublic = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String?> creatorName = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalQuizzesCompanion(
            id: id,
            title: title,
            description: description,
            category: category,
            isPublic: isPublic,
            ownerId: ownerId,
            creatorName: creatorName,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<bool> isPublic = const Value.absent(),
            required String ownerId,
            Value<String?> creatorName = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalQuizzesCompanion.insert(
            id: id,
            title: title,
            description: description,
            category: category,
            isPublic: isPublic,
            ownerId: ownerId,
            creatorName: creatorName,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalQuizzesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({localQuestionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (localQuestionsRefs) db.localQuestions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localQuestionsRefs)
                    await $_getPrefetchedData<LocalQuiz, $LocalQuizzesTable,
                            LocalQuestion>(
                        currentTable: table,
                        referencedTable: $$LocalQuizzesTableReferences
                            ._localQuestionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$LocalQuizzesTableReferences(db, table, p0)
                                .localQuestionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.quizId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$LocalQuizzesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalQuizzesTable,
    LocalQuiz,
    $$LocalQuizzesTableFilterComposer,
    $$LocalQuizzesTableOrderingComposer,
    $$LocalQuizzesTableAnnotationComposer,
    $$LocalQuizzesTableCreateCompanionBuilder,
    $$LocalQuizzesTableUpdateCompanionBuilder,
    (LocalQuiz, $$LocalQuizzesTableReferences),
    LocalQuiz,
    PrefetchHooks Function({bool localQuestionsRefs})>;
typedef $$LocalQuestionsTableCreateCompanionBuilder = LocalQuestionsCompanion
    Function({
  required String id,
  required String quizId,
  required String content,
  required String optionsJson,
  required int correctIndex,
  Value<String?> difficulty,
  Value<int> timerSeconds,
  Value<int> rowid,
});
typedef $$LocalQuestionsTableUpdateCompanionBuilder = LocalQuestionsCompanion
    Function({
  Value<String> id,
  Value<String> quizId,
  Value<String> content,
  Value<String> optionsJson,
  Value<int> correctIndex,
  Value<String?> difficulty,
  Value<int> timerSeconds,
  Value<int> rowid,
});

final class $$LocalQuestionsTableReferences
    extends BaseReferences<_$AppDatabase, $LocalQuestionsTable, LocalQuestion> {
  $$LocalQuestionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $LocalQuizzesTable _quizIdTable(_$AppDatabase db) =>
      db.localQuizzes.createAlias(
          $_aliasNameGenerator(db.localQuestions.quizId, db.localQuizzes.id));

  $$LocalQuizzesTableProcessedTableManager get quizId {
    final $_column = $_itemColumn<String>('quiz_id')!;

    final manager = $$LocalQuizzesTableTableManager($_db, $_db.localQuizzes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_quizIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LocalQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correctIndex => $composableBuilder(
      column: $table.correctIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timerSeconds => $composableBuilder(
      column: $table.timerSeconds, builder: (column) => ColumnFilters(column));

  $$LocalQuizzesTableFilterComposer get quizId {
    final $$LocalQuizzesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.quizId,
        referencedTable: $db.localQuizzes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalQuizzesTableFilterComposer(
              $db: $db,
              $table: $db.localQuizzes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correctIndex => $composableBuilder(
      column: $table.correctIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timerSeconds => $composableBuilder(
      column: $table.timerSeconds,
      builder: (column) => ColumnOrderings(column));

  $$LocalQuizzesTableOrderingComposer get quizId {
    final $$LocalQuizzesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.quizId,
        referencedTable: $db.localQuizzes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalQuizzesTableOrderingComposer(
              $db: $db,
              $table: $db.localQuizzes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalQuestionsTable> {
  $$LocalQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => column);

  GeneratedColumn<int> get correctIndex => $composableBuilder(
      column: $table.correctIndex, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get timerSeconds => $composableBuilder(
      column: $table.timerSeconds, builder: (column) => column);

  $$LocalQuizzesTableAnnotationComposer get quizId {
    final $$LocalQuizzesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.quizId,
        referencedTable: $db.localQuizzes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LocalQuizzesTableAnnotationComposer(
              $db: $db,
              $table: $db.localQuizzes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LocalQuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalQuestionsTable,
    LocalQuestion,
    $$LocalQuestionsTableFilterComposer,
    $$LocalQuestionsTableOrderingComposer,
    $$LocalQuestionsTableAnnotationComposer,
    $$LocalQuestionsTableCreateCompanionBuilder,
    $$LocalQuestionsTableUpdateCompanionBuilder,
    (LocalQuestion, $$LocalQuestionsTableReferences),
    LocalQuestion,
    PrefetchHooks Function({bool quizId})> {
  $$LocalQuestionsTableTableManager(
      _$AppDatabase db, $LocalQuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> quizId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> optionsJson = const Value.absent(),
            Value<int> correctIndex = const Value.absent(),
            Value<String?> difficulty = const Value.absent(),
            Value<int> timerSeconds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalQuestionsCompanion(
            id: id,
            quizId: quizId,
            content: content,
            optionsJson: optionsJson,
            correctIndex: correctIndex,
            difficulty: difficulty,
            timerSeconds: timerSeconds,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String quizId,
            required String content,
            required String optionsJson,
            required int correctIndex,
            Value<String?> difficulty = const Value.absent(),
            Value<int> timerSeconds = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalQuestionsCompanion.insert(
            id: id,
            quizId: quizId,
            content: content,
            optionsJson: optionsJson,
            correctIndex: correctIndex,
            difficulty: difficulty,
            timerSeconds: timerSeconds,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LocalQuestionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({quizId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (quizId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.quizId,
                    referencedTable:
                        $$LocalQuestionsTableReferences._quizIdTable(db),
                    referencedColumn:
                        $$LocalQuestionsTableReferences._quizIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LocalQuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalQuestionsTable,
    LocalQuestion,
    $$LocalQuestionsTableFilterComposer,
    $$LocalQuestionsTableOrderingComposer,
    $$LocalQuestionsTableAnnotationComposer,
    $$LocalQuestionsTableCreateCompanionBuilder,
    $$LocalQuestionsTableUpdateCompanionBuilder,
    (LocalQuestion, $$LocalQuestionsTableReferences),
    LocalQuestion,
    PrefetchHooks Function({bool quizId})>;
typedef $$OfflineMutationsTableCreateCompanionBuilder
    = OfflineMutationsCompanion Function({
  Value<int> id,
  required String mutationType,
  required String payloadJson,
  Value<DateTime> createdAt,
  Value<int> retryCount,
});
typedef $$OfflineMutationsTableUpdateCompanionBuilder
    = OfflineMutationsCompanion Function({
  Value<int> id,
  Value<String> mutationType,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<int> retryCount,
});

class $$OfflineMutationsTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineMutationsTable> {
  $$OfflineMutationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mutationType => $composableBuilder(
      column: $table.mutationType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));
}

class $$OfflineMutationsTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineMutationsTable> {
  $$OfflineMutationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mutationType => $composableBuilder(
      column: $table.mutationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));
}

class $$OfflineMutationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineMutationsTable> {
  $$OfflineMutationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mutationType => $composableBuilder(
      column: $table.mutationType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);
}

class $$OfflineMutationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineMutationsTable,
    OfflineMutation,
    $$OfflineMutationsTableFilterComposer,
    $$OfflineMutationsTableOrderingComposer,
    $$OfflineMutationsTableAnnotationComposer,
    $$OfflineMutationsTableCreateCompanionBuilder,
    $$OfflineMutationsTableUpdateCompanionBuilder,
    (
      OfflineMutation,
      BaseReferences<_$AppDatabase, $OfflineMutationsTable, OfflineMutation>
    ),
    OfflineMutation,
    PrefetchHooks Function()> {
  $$OfflineMutationsTableTableManager(
      _$AppDatabase db, $OfflineMutationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineMutationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineMutationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineMutationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> mutationType = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
          }) =>
              OfflineMutationsCompanion(
            id: id,
            mutationType: mutationType,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String mutationType,
            required String payloadJson,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
          }) =>
              OfflineMutationsCompanion.insert(
            id: id,
            mutationType: mutationType,
            payloadJson: payloadJson,
            createdAt: createdAt,
            retryCount: retryCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineMutationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OfflineMutationsTable,
    OfflineMutation,
    $$OfflineMutationsTableFilterComposer,
    $$OfflineMutationsTableOrderingComposer,
    $$OfflineMutationsTableAnnotationComposer,
    $$OfflineMutationsTableCreateCompanionBuilder,
    $$OfflineMutationsTableUpdateCompanionBuilder,
    (
      OfflineMutation,
      BaseReferences<_$AppDatabase, $OfflineMutationsTable, OfflineMutation>
    ),
    OfflineMutation,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalQuizzesTableTableManager get localQuizzes =>
      $$LocalQuizzesTableTableManager(_db, _db.localQuizzes);
  $$LocalQuestionsTableTableManager get localQuestions =>
      $$LocalQuestionsTableTableManager(_db, _db.localQuestions);
  $$OfflineMutationsTableTableManager get offlineMutations =>
      $$OfflineMutationsTableTableManager(_db, _db.offlineMutations);
}

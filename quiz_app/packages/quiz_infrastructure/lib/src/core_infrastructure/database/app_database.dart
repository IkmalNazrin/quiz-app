import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

// Tables defining the local cache

@DataClassName('LocalQuiz')
class LocalQuizzes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  TextColumn get ownerId => text()();
  TextColumn get creatorName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LocalQuestion')
class LocalQuestions extends Table {
  TextColumn get id => text()();
  TextColumn get quizId => text().references(LocalQuizzes, #id)();
  TextColumn get content => text()();
  TextColumn get optionsJson => text()(); // Serialized JSON list of strings
  IntColumn get correctIndex => integer()();
  TextColumn get difficulty => text().nullable()();
  IntColumn get timerSeconds => integer().withDefault(const Constant(15))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('OfflineMutation')
class OfflineMutations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mutationType =>
      text()(); // e.g., 'create_quiz', 'submit_score'
  TextColumn get payloadJson => text()(); // Serialized JSON payload
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [LocalQuizzes, LocalQuestions, OfflineMutations])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'quiz_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

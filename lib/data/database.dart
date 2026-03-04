import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get iconName => text()();
  TextColumn get colorHex => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get reminderTime => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class HabitCompletions extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text().references(Habits, #id)();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Habits, HabitCompletions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'habit_database');
  }

  Future<List<Habit>> getAllHabits() => select(habits).get();

  Future<void> insertHabit(HabitsCompanion habit) => into(habits).insert(habit);

  Future<void> deleteHabit(String id) =>
      (delete(habits)..where((h) => h.id.equals(id))).go();

  Future<List<HabitCompletion>> getCompletionsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(habitCompletions)
          ..where((c) => c.completedAt.isBetweenValues(start, end)))
        .get();
  }

  Future<void> toggleCompletion(String habitId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final existing = await (select(habitCompletions)
          ..where((c) => c.habitId.equals(habitId))
          ..where((c) => c.completedAt.isBetweenValues(start, end)))
        .getSingleOrNull();

    if (existing != null) {
      await delete(habitCompletions).delete(existing);
    } else {
      await into(habitCompletions).insert(HabitCompletionsCompanion(
        id: Value(const Uuid().v4()),
        habitId: Value(habitId),
        completedAt: Value(date),
      ));
    }
  }

  Future<int> getStreakForHabit(String habitId) async {
    final completions = await (select(habitCompletions)
          ..where((c) => c.habitId.equals(habitId))
          ..orderBy([(c) => OrderingTerm.desc(c.completedAt)]))
        .get();

    if (completions.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (final completion in completions) {
      final compDate = DateTime(
        completion.completedAt.year,
        completion.completedAt.month,
        completion.completedAt.day,
      );
      final targetDate =
          DateTime(checkDate.year, checkDate.month, checkDate.day);

      if (compDate == targetDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (compDate == targetDate.subtract(const Duration(days: 1))) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}

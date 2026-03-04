import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/habit_repository.dart';
import '../data/models/habit.dart';

final habitRepositoryProvider = Provider((ref) => HabitRepository());

final habitsProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).getHabits();
});

final habitActionsProvider = Provider((ref) {
  final repo = ref.read(habitRepositoryProvider);

  return HabitActions(
    addHabit: repo.addHabit,
    toggleHabit: repo.toggleHabitCompletion,
    deleteHabit: repo.deleteHabit,
  );
});

class HabitActions {
  final Future<void> Function(String, String, String) addHabit;
  final Future<void> Function(String, DateTime) toggleHabit;
  final Future<void> Function(String) deleteHabit;

  HabitActions({
    required this.addHabit,
    required this.toggleHabit,
    required this.deleteHabit,
  });
}

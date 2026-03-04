import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../data/models/habit.dart';
import '../providers/habit_provider.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;
  final DateTime selectedDate;

  const HabitCard({
    super.key,
    required this.habit,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(habitActionsProvider);
    final isCompleted = habit.completedDates.any((d) =>
        d.year == selectedDate.year &&
        d.month == selectedDate.month &&
        d.day == selectedDate.day);

    final color = Color(int.parse(habit.colorHex.replaceFirst('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(), color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${habit.completedDates.length} days completed',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => actions.toggleHabit(habit.id, selectedDate),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.primary : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? AppTheme.primary : AppTheme.textTertiary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.black)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (habit.iconName) {
      case 'fitness':
        return Icons.fitness_center;
      case 'book':
        return Icons.book;
      case 'water':
        return Icons.water_drop;
      default:
        return Icons.check_circle;
    }
  }
}

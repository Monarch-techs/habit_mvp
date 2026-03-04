import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_mvp/data/models/habit.dart';

class HabitRepository {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _habitsRef {
    return _firestore.collection('users').doc(_userId).collection('habits');
  }

  Stream<List<Habit>> getHabits() {
    return _habitsRef.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Habit.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  Future<void> addHabit(String title, String icon, String color) async {
    await _habitsRef.add({
      'title': title,
      'iconName': icon,
      'colorHex': color,
      'createdAt': Timestamp.now(),
      'userId': _userId,
      'completedDates': [],
    });
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final doc = _habitsRef.doc(habitId);
    final snapshot = await doc.get();
    final data = snapshot.data()!;

    // Convert timestamps to dates properly
    final dates = (data['completedDates'] as List<dynamic>? ?? [])
        .map((t) => (t as Timestamp).toDate())
        .toList();

    final normalizedDate = DateTime(date.year, date.month, date.day);
    final exists = dates.any((d) =>
        d.year == normalizedDate.year &&
        d.month == normalizedDate.month &&
        d.day == normalizedDate.day);

    if (exists) {
      await doc.update({
        'completedDates':
            FieldValue.arrayRemove([Timestamp.fromDate(normalizedDate)])
      });
    } else {
      await doc.update({
        'completedDates':
            FieldValue.arrayUnion([Timestamp.fromDate(normalizedDate)])
      });
    }
  }

  Future<void> deleteHabit(String habitId) async {
    await _habitsRef.doc(habitId).delete();
  }
}

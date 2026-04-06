import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit_model.dart';

class HabitRepository {
  CollectionReference<Map<String, dynamic>> _habits(String uid) =>
      FirebaseFirestore.instance.collection('users/$uid/habits');

  CollectionReference<Map<String, dynamic>> _logs(String uid) =>
      FirebaseFirestore.instance.collection('users/$uid/habitLogs');

  static String logKey(String date, String habitId) => '${date}_$habitId';

  Stream<List<HabitModel>> watchHabits(String uid) {
    return _habits(uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) {
          final list = s.docs
              .map((d) => HabitModel.fromMap(d.id, d.data()))
              .toList();
          list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return list;
        });
  }

  Future<void> addHabit(String uid, HabitModel habit) async {
    await _habits(uid).doc(habit.id).set(habit.toMap());
  }

  Future<void> updateHabit(String uid, HabitModel habit) async {
    await _habits(uid).doc(habit.id).update(habit.toMap());
  }

  Future<void> deleteHabit(String uid, String id) async {
    await _habits(uid).doc(id).update({'isActive': false});
  }

  Future<void> logHabit(
      String uid, String habitId, String date, int count) async {
    final key = logKey(date, habitId);
    await _logs(uid).doc(key).set({
      'habitId': habitId,
      'date': date,
      'count': count,
      'completedAt': count > 0 ? FieldValue.serverTimestamp() : null,
    });
  }

  Stream<List<HabitLogModel>> watchLogsForHabit(
      String uid, String habitId, String fromDate, String toDate) {
    return _logs(uid)
        .where('habitId', isEqualTo: habitId)
        .snapshots()
        .map((s) => s.docs
            .map((d) => HabitLogModel.fromMap(d.data()))
            .where((l) => l.date.compareTo(fromDate) >= 0 && l.date.compareTo(toDate) <= 0)
            .toList());
  }

  Stream<List<HabitLogModel>> watchLogsForDate(String uid, String date) {
    return _logs(uid)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((s) => s.docs
            .map((d) => HabitLogModel.fromMap(d.data()))
            .toList());
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class StatsData {
  final String dateKey;
  final DateTime date;
  final int focusSeconds;
  final int sessionsCount;
  final int startedSessions; // сколько раз запускал таймер (для completion rate)
  final List<String> completedTodos;
  final List<String> completedTodoIds;

  StatsData({
    required this.dateKey,
    required this.date,
    required this.focusSeconds,
    required this.sessionsCount,
    required this.startedSessions,
    required this.completedTodos,
    required this.completedTodoIds,
  });

  factory StatsData.fromMap(Map<String, dynamic> map, String dateKey) {
    return StatsData(
      dateKey: dateKey,
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      focusSeconds: map['focusSeconds'] as int? ?? 0,
      sessionsCount: map['sessionsCount'] as int? ?? 0,
      startedSessions: map['startedSessions'] as int? ?? 0,
      completedTodos: List<String>.from(map['completedTodos'] ?? []),
      completedTodoIds: List<String>.from(map['completedTodoIds'] ?? []),
    );
  }
}

class StatsRepository {
  static final StatsRepository _instance = StatsRepository._internal();
  factory StatsRepository() => _instance;
  StatsRepository._internal();

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance.collection('users/$uid/stats');

  Stream<List<StatsData>> watchAllStats(String uid) {
    return _col(uid).snapshots().map((snap) =>
        snap.docs.map((d) => StatsData.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addFocusSeconds(String uid, String key, int seconds,
      {bool countSession = true}) async {
    final ref = _col(uid).doc(key);
    final doc = await ref.get();
    if (doc.exists) {
      final updates = <String, dynamic>{
        'focusSeconds': FieldValue.increment(seconds),
      };
      if (countSession) {
        updates['sessionsCount'] = FieldValue.increment(1);
      }
      await ref.update(updates);
    } else {
      final today = DateTime.now();
      await ref.set({
        'date': Timestamp.fromDate(DateTime(today.year, today.month, today.day)),
        'focusSeconds': seconds,
        'sessionsCount': countSession ? 1 : 0,
        'startedSessions': 0,
        'completedTodos': [],
        'completedTodoIds': [],
      });
    }
  }

  /// Вызывается при каждом свежем запуске таймера (не возобновлении после паузы).
  Future<void> incrementStartedSession(String uid, String key) async {
    final ref = _col(uid).doc(key);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.update({'startedSessions': FieldValue.increment(1)});
    } else {
      final today = DateTime.now();
      await ref.set({
        'date': Timestamp.fromDate(DateTime(today.year, today.month, today.day)),
        'focusSeconds': 0,
        'sessionsCount': 0,
        'startedSessions': 1,
        'completedTodos': [],
        'completedTodoIds': [],
      });
    }
  }

  Future<void> addCompletedTodo(
      String uid, String key, String id, String title) async {
    final ref = _col(uid).doc(key);
    final doc = await ref.get();
    if (doc.exists) {
      final ids = List<String>.from(doc.data()?['completedTodoIds'] ?? []);
      if (!ids.contains(id)) {
        await ref.update({
          'completedTodoIds': FieldValue.arrayUnion([id]),
          'completedTodos': FieldValue.arrayUnion([title]),
        });
      }
    } else {
      final today = DateTime.now();
      await ref.set({
        'date': Timestamp.fromDate(DateTime(today.year, today.month, today.day)),
        'focusSeconds': 0,
        'sessionsCount': 0,
        'completedTodos': [title],
        'completedTodoIds': [id],
      });
    }
  }

  Future<void> removeCompletedTodo(
      String uid, String key, String id) async {
    final ref = _col(uid).doc(key);
    final doc = await ref.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final ids    = List<String>.from(data['completedTodoIds'] ?? []);
    final titles = List<String>.from(data['completedTodos'] ?? []);

    final index = ids.indexOf(id);
    if (index == -1) return;

    ids.removeAt(index);
    if (index < titles.length) titles.removeAt(index);

    await ref.update({
      'completedTodoIds': ids,
      'completedTodos': titles,
    });
  }

  Future<void> updateTodoTitleInStats(
      String uid, String todoId, String newTitle) async {
    final snap = await _col(uid).get();
    for (final doc in snap.docs) {
      final data = doc.data();
      final ids = List<String>.from(data['completedTodoIds'] ?? []);
      final titles = List<String>.from(data['completedTodos'] ?? []);
      final index = ids.indexOf(todoId);
      if (index != -1 && index < titles.length) {
        titles[index] = newTitle;
        await doc.reference.update({'completedTodos': titles});
      }
    }
  }
}

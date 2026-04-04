import 'package:cloud_firestore/cloud_firestore.dart';

class TodoData {
  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int order;

  TodoData({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
    this.completedAt,
    this.order = 0,
  });

  TodoData copyWith({
    String? title,
    bool? isDone,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    int? order,
  }) {
    return TodoData(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      order: order ?? this.order,
    );
  }

  factory TodoData.fromMap(Map<String, dynamic> map, String id) {
    return TodoData(
      id: id,
      title: map['title'] as String? ?? '',
      isDone: map['isDone'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      order: map['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isDone': isDone,
        'createdAt': Timestamp.fromDate(createdAt),
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
        'order': order,
      };
}

class TodoRepository {
  static final TodoRepository _instance = TodoRepository._internal();
  factory TodoRepository() => _instance;
  TodoRepository._internal();

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance.collection('users/$uid/todos');

  Stream<List<TodoData>> watchTodos(String uid) {
    return _col(uid).snapshots().map((snap) {
      final todos =
          snap.docs.map((d) => TodoData.fromMap(d.data(), d.id)).toList();
      todos.sort((a, b) => a.order.compareTo(b.order));
      return todos;
    });
  }

  Future<TodoData> addTodo(String uid, String title, {int order = 0}) async {
    final ref = _col(uid).doc();
    final todo = TodoData(
      id: ref.id,
      title: title,
      isDone: false,
      createdAt: DateTime.now(),
      order: order,
    );
    await ref.set(todo.toMap());
    return todo;
  }

  Future<void> updateTodo(String uid, TodoData todo) async {
    await _col(uid).doc(todo.id).update(todo.toMap());
  }

  Future<void> deleteTodo(String uid, String id) async {
    await _col(uid).doc(id).delete();
  }

  Future<void> reorderTodos(String uid, List<TodoData> todos) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < todos.length; i++) {
      batch.update(_col(uid).doc(todos[i].id), {'order': i});
    }
    await batch.commit();
  }
}

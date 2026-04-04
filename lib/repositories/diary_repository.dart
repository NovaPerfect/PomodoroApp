import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryData {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int moodIndex;

  DiaryData({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.moodIndex,
  });

  DiaryData copyWith({
    String? title,
    String? content,
    int? moodIndex,
  }) {
    return DiaryData(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      moodIndex: moodIndex ?? this.moodIndex,
    );
  }

  factory DiaryData.fromMap(Map<String, dynamic> map, String id) {
    return DiaryData(
      id: id,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      moodIndex: map['moodIndex'] as int? ?? -1,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'content': content,
        'createdAt': Timestamp.fromDate(createdAt),
        'moodIndex': moodIndex,
      };
}

class DiaryRepository {
  static final DiaryRepository _instance = DiaryRepository._internal();
  factory DiaryRepository() => _instance;
  DiaryRepository._internal();

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance.collection('users/$uid/diary');

  Stream<List<DiaryData>> watchEntries(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => DiaryData.fromMap(d.data(), d.id)).toList());
  }

  Future<void> addEntry(String uid, DiaryData entry) async {
    final ref = _col(uid).doc();
    await ref.set(entry.toMap());
  }

  Future<void> updateEntry(String uid, DiaryData entry) async {
    await _col(uid).doc(entry.id).update(entry.toMap());
  }

  Future<void> deleteEntry(String uid, String id) async {
    await _col(uid).doc(id).delete();
  }
}

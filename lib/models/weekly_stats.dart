// Data-классы для расширенной статистики.
// Вычисляются на клиенте из Firestore stream — ничего не хранится отдельно.

class WeeklyStats {
  final int totalFocusSeconds;
  final int totalSessions;       // завершённые помодоро
  final int totalStarted;        // запущенные помодоро (для completion rate)
  final int totalTodos;          // выполненных задач
  final int totalDiaryEntries;   // записей в дневнике
  final int activeDays;          // дней с хоть каким-то фокусом
  final int bestDayTodos;        // максимум задач за один день
  final String bestDayLabel;     // "Среда" и т.п.
  final double avgMood;          // среднее moodIndex, -1 если нет данных
  final int prevWeekFocusSeconds;// для % сравнения

  /// Список активности по дням недели: index 0=Пн, 6=Вс. true = был фокус.
  final List<bool> activeDaysMask;

  const WeeklyStats({
    required this.totalFocusSeconds,
    required this.totalSessions,
    required this.totalStarted,
    required this.totalTodos,
    required this.totalDiaryEntries,
    required this.activeDays,
    required this.bestDayTodos,
    required this.bestDayLabel,
    required this.avgMood,
    required this.prevWeekFocusSeconds,
    required this.activeDaysMask,
  });

  static WeeklyStats empty() => const WeeklyStats(
    totalFocusSeconds: 0,
    totalSessions: 0,
    totalStarted: 0,
    totalTodos: 0,
    totalDiaryEntries: 0,
    activeDays: 0,
    bestDayTodos: 0,
    bestDayLabel: '—',
    avgMood: -1,
    prevWeekFocusSeconds: 0,
    activeDaysMask: [false, false, false, false, false, false, false],
  );

  /// Доля завершённых сессий (0.0–1.0).
  double get completionRate =>
      totalStarted == 0 ? 0.0 : (totalSessions / totalStarted).clamp(0.0, 1.0);

  /// Разница с прошлой неделей в секундах (может быть отрицательной).
  int get focusDelta => totalFocusSeconds - prevWeekFocusSeconds;

  /// "+18%" / "-5%" / "" если нет данных прошлой недели.
  String get focusDeltaLabel {
    if (prevWeekFocusSeconds == 0) return '';
    final pct =
        ((totalFocusSeconds - prevWeekFocusSeconds) / prevWeekFocusSeconds * 100)
            .round();
    return pct >= 0 ? '+$pct%' : '$pct%';
  }
}

class AllTimeRecords {
  final int bestStreakDays;
  final int currentStreakDays;
  final int bestDayFocusSeconds;
  final int bestDayTodos;
  final int totalDiaryEntries;

  const AllTimeRecords({
    required this.bestStreakDays,
    required this.currentStreakDays,
    required this.bestDayFocusSeconds,
    required this.bestDayTodos,
    required this.totalDiaryEntries,
  });

  static AllTimeRecords empty() => const AllTimeRecords(
    bestStreakDays: 0,
    currentStreakDays: 0,
    bestDayFocusSeconds: 0,
    bestDayTodos: 0,
    totalDiaryEntries: 0,
  );
}

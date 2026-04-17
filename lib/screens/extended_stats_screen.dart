import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/weekly_stats.dart';
import '../repositories/diary_repository.dart';
import '../repositories/stats_repository.dart';
import '../theme/app_theme.dart';

const _moodEmoji = ['😭', '😞', '😐', '😊', '🤩'];

class ExtendedStatsScreen extends StatefulWidget {
  final String uid;
  const ExtendedStatsScreen({super.key, required this.uid});

  @override
  State<ExtendedStatsScreen> createState() => _ExtendedStatsScreenState();
}

class _ExtendedStatsScreenState extends State<ExtendedStatsScreen> {
  bool _thisWeek = true;
  List<StatsData>  _stats = [];
  List<DiaryData>  _diary = [];
  StreamSubscription? _statsSub, _diarySub;

  @override
  void initState() {
    super.initState();
    _statsSub = StatsRepository()
        .watchAllStats(widget.uid)
        .listen((s) => setState(() => _stats = s));
    _diarySub = DiaryRepository()
        .watchEntries(widget.uid)
        .listen((d) => setState(() => _diary = d));
  }

  @override
  void dispose() {
    _statsSub?.cancel();
    _diarySub?.cancel();
    super.dispose();
  }

  // ── Вспомогательные ────────────────────────────────────────────
  DateTime _monday(DateTime d) =>
      DateTime(d.year, d.month, d.day)
          .subtract(Duration(days: d.weekday - 1));

  bool _inRange(DateTime d, DateTime from, DateTime to) {
    final day = DateTime(d.year, d.month, d.day);
    return !day.isBefore(from) && !day.isAfter(to);
  }

  // ── Вычисление недельной статистики ────────────────────────────
  WeeklyStats _computeWeekly(String locale) {
    final today    = DateTime.now();
    final thisMon  = _monday(today);
    final lastMon  = thisMon.subtract(const Duration(days: 7));
    final lastSun  = thisMon.subtract(const Duration(days: 1));

    final start = _thisWeek ? thisMon : lastMon;
    final end   = _thisWeek
        ? DateTime(today.year, today.month, today.day)
        : lastSun;

    // Текущий период
    final statsW = _stats.where((s) =>
        _inRange(s.date, start, end)).toList();
    final diaryW = _diary.where((d) =>
        _inRange(d.createdAt, start, end)).toList();

    // Прошлая неделя (для сравнения при "эта неделя")
    int prevFocus = 0;
    if (_thisWeek) {
      prevFocus = _stats
          .where((s) => _inRange(s.date, lastMon, lastSun))
          .fold(0, (acc, s) => acc + s.focusSeconds);
    }

    // Суммы
    final totalFocus    = statsW.fold(0, (a, s) => a + s.focusSeconds);
    final totalSessions = statsW.fold(0, (a, s) => a + s.sessionsCount);
    final totalStarted  = statsW.fold(0, (a, s) => a + s.startedSessions);
    final totalTodos    = statsW.fold(0, (a, s) => a + s.completedTodoIds.length);
    final activeDays    = statsW.where((s) => s.focusSeconds > 0).length;

    // Лучший день по задачам
    int bestTodos = 0;
    String bestDayLabel = '—';
    for (final s in statsW) {
      if (s.completedTodoIds.length > bestTodos) {
        bestTodos = s.completedTodoIds.length;
        bestDayLabel = DateFormat('EEEE', locale).format(s.date);
      }
    }

    // Среднее настроение
    final moodEntries = diaryW.where((d) => d.moodIndex >= 0).toList();
    final avgMood = moodEntries.isEmpty
        ? -1.0
        : moodEntries.fold(0, (a, d) => a + d.moodIndex) /
            moodEntries.length;

    // Маска активности Пн–Вс
    final mask = List<bool>.filled(7, false);
    for (final s in statsW) {
      if (s.focusSeconds > 0) {
        mask[s.date.weekday - 1] = true;
      }
    }

    return WeeklyStats(
      totalFocusSeconds:  totalFocus,
      totalSessions:      totalSessions,
      totalStarted:       totalStarted,
      totalTodos:         totalTodos,
      totalDiaryEntries:  diaryW.length,
      activeDays:         activeDays,
      bestDayTodos:       bestTodos,
      bestDayLabel:       bestTodos == 0 ? '—' : bestDayLabel,
      avgMood:            avgMood,
      prevWeekFocusSeconds: prevFocus,
      activeDaysMask:     mask,
    );
  }

  // ── Вычисление рекордов всех времён ───────────────────────────
  AllTimeRecords _computeRecords() {
    if (_stats.isEmpty) return AllTimeRecords.empty();

    final sorted = [..._stats]..sort((a, b) => a.date.compareTo(b.date));

    // Множество активных дней (dateKey)
    final activeSet = sorted
        .where((s) => s.focusSeconds > 0)
        .map((s) => StatsRepository.dateKey(s.date))
        .toSet();

    // Лучшая серия
    int maxStreak = 0, cur = 0;
    DateTime? prev;
    for (final s in sorted) {
      if (s.focusSeconds == 0) { prev = null; cur = 0; continue; }
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      if (prev == null) {
        cur = 1;
      } else {
        cur = d.difference(prev).inDays == 1 ? cur + 1 : 1;
      }
      maxStreak = max(maxStreak, cur);
      prev = d;
    }

    // Текущая серия (считаем от сегодня назад)
    int currentStreak = 0;
    var check = DateTime.now();
    while (true) {
      if (activeSet.contains(StatsRepository.dateKey(check))) {
        currentStreak++;
        check = check.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    // Рекорд дня
    final bestFocus = sorted.map((s) => s.focusSeconds).reduce(max);
    final bestTodos = sorted.map((s) => s.completedTodoIds.length).reduce(max);

    return AllTimeRecords(
      bestStreakDays:      maxStreak,
      currentStreakDays:   currentStreak,
      bestDayFocusSeconds: bestFocus,
      bestDayTodos:        bestTodos,
      totalDiaryEntries:   _diary.length,
    );
  }

  // ── Форматирование времени ─────────────────────────────────────
  String _fmtTime(int seconds, AppLocalizations l10n) {
    if (seconds == 0) return l10n.zeroMin;
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0 && m > 0) return '$h ${l10n.hour} $m ${l10n.min}';
    if (h > 0) return '$h ${l10n.hour}';
    return '$m ${l10n.min}';
  }

  String _moodLabel(double avg) {
    if (avg < 0) return '—';
    return _moodEmoji[avg.round().clamp(0, 4)];
  }

  // ── Заголовок периода ──────────────────────────────────────────
  String _periodLabel(String locale) {
    final today   = DateTime.now();
    final thisMon = _monday(today);
    String fmt(DateTime d) => DateFormat('d MMM', locale).format(d);
    if (_thisWeek) {
      return '${fmt(thisMon)} – ${fmt(today)}';
    } else {
      final lastMon = thisMon.subtract(const Duration(days: 7));
      final lastSun = thisMon.subtract(const Duration(days: 1));
      return '${fmt(lastMon)} – ${fmt(lastSun)}';
    }
  }

  // ── UI ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final weekly  = _computeWeekly(locale);
    final records = _computeRecords();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.extendedStatsTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          // swipe left → last week, swipe right → this week
          if (details.primaryVelocity! < -300 && _thisWeek) {
            setState(() => _thisWeek = false);
          } else if (details.primaryVelocity! > 300 && !_thisWeek) {
            setState(() => _thisWeek = true);
          }
        },
        child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Переключатель недели ───────────────────────────────
          _WeekToggle(
            thisWeek: _thisWeek,
            onChanged: (v) => setState(() => _thisWeek = v),
            periodLabel: _periodLabel(locale),
            thisWeekLabel: l10n.thisWeek,
            lastWeekLabel: l10n.lastWeek,
          ),
          const SizedBox(height: 16),

          // ── Фокус ─────────────────────────────────────────────
          _StatCard(
            emoji: '⏱',
            title: l10n.focusStat,
            value: _fmtTime(weekly.totalFocusSeconds, l10n),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_thisWeek && weekly.focusDeltaLabel.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      l10n.vsPrevWeek(weekly.focusDeltaLabel),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: weekly.focusDelta >= 0
                            ? AppColors.accent
                            : Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                _ProgressBar(
                  value: weekly.prevWeekFocusSeconds == 0
                      ? 1.0
                      : (weekly.totalFocusSeconds /
                              max(weekly.totalFocusSeconds,
                                  weekly.prevWeekFocusSeconds))
                          .clamp(0.0, 1.0),
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Задачи ────────────────────────────────────────────
          _StatCard(
            emoji: '✅',
            title: l10n.tasks,
            value: '${weekly.totalTodos}',
            subtitle: weekly.bestDayTodos > 0
                ? l10n.bestDayDetail(weekly.bestDayLabel, weekly.bestDayTodos)
                : l10n.noTasksForPeriod,
          ),
          const SizedBox(height: 12),

          // ── Дневник ───────────────────────────────────────────
          _StatCard(
            emoji: '📖',
            title: l10n.diary,
            value: '${weekly.totalDiaryEntries}',
            subtitle: weekly.totalDiaryEntries == 0
                ? l10n.noEntriesForPeriod
                : l10n.moodAverageLabel(_moodLabel(weekly.avgMood)),
          ),
          const SizedBox(height: 12),

          // ── Завершённость таймера ──────────────────────────────
          _StatCard(
            emoji: '🎯',
            title: l10n.completionRateStat,
            value: weekly.totalStarted == 0
                ? '—'
                : '${(weekly.completionRate * 100).round()}%',
            subtitle: weekly.totalStarted == 0
                ? l10n.startTimerHint
                : l10n.sessionsCompletedDetail(weekly.totalSessions, weekly.totalStarted),
            child: weekly.totalStarted > 0
                ? _ProgressBar(
                    value: weekly.completionRate,
                    color: AppColors.accent2,
                  )
                : null,
          ),
          const SizedBox(height: 12),

          // ── Активные дни ──────────────────────────────────────
          _StatCard(
            emoji: '📅',
            title: l10n.activeDaysStat,
            value: l10n.activeDaysOf(weekly.activeDays),
            child: _DaysMask(mask: weekly.activeDaysMask, locale: locale),
          ),
          const SizedBox(height: 20),

          // ── Рекорды всех времён ───────────────────────────────
          _RecordsCard(
            records: records,
            l10n: l10n,
            fmtTime: (s) => _fmtTime(s, l10n),
          ),
        ],
      ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Переключатель недели
// ─────────────────────────────────────────────────────────────────
class _WeekToggle extends StatelessWidget {
  final bool thisWeek;
  final ValueChanged<bool> onChanged;
  final String periodLabel;
  final String thisWeekLabel;
  final String lastWeekLabel;

  const _WeekToggle({
    required this.thisWeek,
    required this.onChanged,
    required this.periodLabel,
    required this.thisWeekLabel,
    required this.lastWeekLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _Tab(thisWeekLabel, selected: thisWeek,
                  onTap: () => onChanged(true)),
              _Tab(lastWeekLabel, selected: !thisWeek,
                  onTap: () => onChanged(false)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            periodLabel,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Tab(this.label, {required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [BoxShadow(
                    color: AppColors.shadow.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Карточка метрики
// ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final String? subtitle;
  final Widget? child;

  const _StatCard({
    required this.emoji,
    required this.title,
    required this.value,
    this.subtitle,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Значение
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontFamilyFallback: ['Comfortaa'],
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],

          if (child != null) ...[
            const SizedBox(height: 12),
            child!,
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Прогресс-бар
// ─────────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final double value; // 0.0–1.0
  final Color color;
  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      return Stack(
        children: [
          Container(
            height: 8,
            width: c.maxWidth,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            height: 8,
            width: c.maxWidth * value.clamp(0.0, 1.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────
// Маска активных дней Пн–Вс
// ─────────────────────────────────────────────────────────────────
class _DaysMask extends StatelessWidget {
  final List<bool> mask; // 7 элементов, index 0 = Пн
  final String locale;
  const _DaysMask({required this.mask, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final active = i < mask.length && mask[i];
        return Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: active ? AppColors.accent : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: active ? AppColors.accent : AppColors.divider,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                // Понедельник = weekday 1, но в нашем массиве index 0
                // Используем DateFormat для локализованного имени дня
                DateFormat('EEE', locale).format(
                  DateTime(2024, 1, 1 + i)), // 2024-01-01 = понедельник
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  color: active ? AppColors.accent : AppColors.textMuted,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Карточка рекордов
// ─────────────────────────────────────────────────────────────────
class _RecordsCard extends StatelessWidget {
  final AllTimeRecords records;
  final AppLocalizations l10n;
  final String Function(int) fmtTime;
  const _RecordsCard({required this.records, required this.l10n, required this.fmtTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                l10n.personalRecords,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _RecordRow(
            icon: '🔥',
            label: l10n.currentStreak,
            value: l10n.streakDaysLabel(records.currentStreakDays),
          ),
          const SizedBox(height: 10),
          _RecordRow(
            icon: '⭐',
            label: l10n.bestStreak,
            value: l10n.streakDaysLabel(records.bestStreakDays),
          ),
          const SizedBox(height: 10),
          _RecordRow(
            icon: '⏱',
            label: l10n.bestDayRecord,
            value: fmtTime(records.bestDayFocusSeconds),
          ),
          const SizedBox(height: 10),
          _RecordRow(
            icon: '✅',
            label: l10n.maxTasksDay,
            value: '${records.bestDayTodos}',
          ),
          const SizedBox(height: 10),
          _RecordRow(
            icon: '📖',
            label: l10n.totalEntries,
            value: '${records.totalDiaryEntries}',
          ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  const _RecordRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontFamilyFallback: ['Comfortaa'],
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../repositories/stats_repository.dart';
import '../repositories/diary_repository.dart';
import '../repositories/todo_repository.dart';
import '../theme/app_theme.dart';
import 'package:untitled/l10n/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime _selectedDate = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime _currentMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  List<StatsData> _allStats = [];
  List<DiaryData> _allDiary = [];
  List<TodoData>  _allTodos = [];

  StreamSubscription<List<StatsData>>? _statsSub;
  StreamSubscription<List<DiaryData>>? _diarySub;
  StreamSubscription<List<TodoData>>?  _todosSub;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  DateTime get _today =>
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    _statsSub = StatsRepository()
        .watchAllStats(_uid)
        .listen((data) => setState(() => _allStats = data));
    _diarySub = DiaryRepository()
        .watchEntries(_uid)
        .listen((data) => setState(() => _allDiary = data));
    _todosSub = TodoRepository()
        .watchTodos(_uid)
        .listen((data) => setState(() => _allTodos = data));
  }

  @override
  void dispose() {
    _statsSub?.cancel();
    _diarySub?.cancel();
    _todosSub?.cancel();
    super.dispose();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  StatsData? _getStats(DateTime date) {
    try {
      return _allStats.firstWhere((s) => _sameDay(s.date, date));
    } catch (_) {
      return null;
    }
  }

  String _formatFocusTime(int seconds, AppLocalizations l10n) {
    if (seconds < 60) return '$seconds ${l10n.sec}';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m < 60) {
      return s > 0 ? '$m ${l10n.min} $s ${l10n.sec}' : '$m ${l10n.min}';
    }
    final h  = m ~/ 60;
    final rm = m % 60;
    return rm > 0 ? '$h ${l10n.hour} $rm ${l10n.min}' : '$h ${l10n.hour}';
  }

  List<String> _getDoneTodos(DateTime date) {
    final stats = _getStats(date);
    if (stats == null) return [];

    final result = <String>[];
    for (int i = 0; i < stats.completedTodoIds.length; i++) {
      final id = stats.completedTodoIds[i];
      try {
        final liveTodo = _allTodos.firstWhere((t) => t.id == id);
        result.add(liveTodo.title);
      } catch (_) {
        if (i < stats.completedTodos.length) {
          result.add(stats.completedTodos[i]);
        }
      }
    }
    return result;
  }

  List<DiaryData> _getDiaryEntries(DateTime date) {
    return _allDiary.where((d) => _sameDay(d.createdAt, date)).toList();
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDay =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = (firstDay.weekday - 1) % 7;

    final days = <DateTime?>[];
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }
    return days;
  }

  String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month - 1];
  }

  String _moodEmoji(int index) {
    const emojis = ['😭', '😞', '😐', '😊', '🤩'];
    if (index < 0 || index >= emojis.length) return '';
    return emojis[index];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final calendarDays    = _buildCalendarDays();
    final selectedStats   = _getStats(_selectedDate);
    final selectedDiaries = _getDiaryEntries(_selectedDate);
    final doneTodoTitles  = _getDoneTodos(_selectedDate);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                l10n.stats,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.statsSubtitle,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13),
              ),

              const SizedBox(height: 24),

              // CALENDAR
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => setState(() {
                            _currentMonth = DateTime(
                                _currentMonth.year, _currentMonth.month - 1);
                          }),
                          icon: const Icon(Icons.chevron_left_rounded,
                              color: AppColors.textPrimary),
                        ),
                        Text(
                          '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            _currentMonth = DateTime(
                                _currentMonth.year, _currentMonth.month + 1);
                          }),
                          icon: const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: calendarDays.length,
                      itemBuilder: (ctx, i) {
                        final date = calendarDays[i];
                        if (date == null) return const SizedBox();
                        final isToday    = _sameDay(date, _today);
                        final isSelected = _sameDay(date, _selectedDate);
                        final hasData    = _allStats
                            .any((s) => _sameDay(s.date, date));
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedDate = date),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.accent
                                  : isToday
                                      ? AppColors.accent
                                          .withValues(alpha: 0.2)
                                      : Colors.transparent,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.background
                                          : AppColors.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (hasData && !isSelected)
                                  Positioned(
                                    bottom: 3,
                                    child: Container(
                                      width: 4, height: 4,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // DAY DETAILS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedDate.day} ${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),

                    // FOCUS TIME
                    _SectionTitle(
                        icon: Icons.timer_outlined,
                        title: l10n.focusTime),
                    const SizedBox(height: 8),
                    selectedStats != null
                        ? Row(
                            children: [
                              Text(
                                _formatFocusTime(
                                    selectedStats.focusSeconds, l10n),
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${selectedStats.sessionsCount} ${l10n.pomodoro}',
                                style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13),
                              ),
                            ],
                          )
                        : Text(l10n.noData,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 14)),
                    const SizedBox(height: 16),

                    // COMPLETED TASKS
                    _SectionTitle(
                        icon: Icons.check_circle_outline,
                        title: l10n.completedTasks),
                    const SizedBox(height: 8),
                    doneTodoTitles.isEmpty
                        ? Text(l10n.noTasksShort,
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 14))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: doneTodoTitles
                                .map((t) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.check_circle,
                                              color: AppColors.success,
                                              size: 14),
                                          const SizedBox(width: 8),
                                          Expanded(
                                              child: Text(t,
                                                  style: const TextStyle(
                                                      color: AppColors
                                                          .textPrimary,
                                                      fontSize: 14))),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),

                    // DIARY ENTRIES
                    if (selectedDiaries.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionTitle(
                          icon: Icons.book_outlined,
                          title: l10n.diaryEntries),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: selectedDiaries.map((d) {
                            final isLast =
                                selectedDiaries.last == d;
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: isLast ? 0 : 8),
                              child: Row(
                                children: [
                                  if (d.moodIndex >= 0) ...[
                                    Text(_moodEmoji(d.moodIndex),
                                        style: const TextStyle(
                                            fontSize: 16)),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Text(
                                      d.title.isEmpty
                                          ? l10n.untitled
                                          : d.title,
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 16),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: Colors.white10)),
      ],
    );
  }
}

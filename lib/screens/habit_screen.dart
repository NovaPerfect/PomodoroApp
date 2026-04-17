import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';
import '../models/habit_model.dart';
import '../repositories/habit_repository.dart';
import '../theme/app_theme.dart';

class HabitScreen extends StatefulWidget {
  final String uid;
  const HabitScreen({super.key, required this.uid});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final _repo = HabitRepository();

  // Last 5 weeks: 35 days ending today
  List<DateTime> get _gridDays {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // normalize to midnight
    final todayWeekday = today.weekday; // 1=Mon..7=Sun
    final startOffset = todayWeekday - 1 + 28; // go back to Mon 4 weeks ago
    final start = today.subtract(Duration(days: startOffset));
    return List.generate(35, (i) => start.add(Duration(days: i)));
  }

  void _showAddDialog() {
    final l10n   = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    String emoji = '⭐';
    String type = 'daily';
    int color = 0xFFE8A0BF;
    List<int> weekDays = [1, 2, 3, 4, 5]; // Mon–Fri default
    int targetCount = 1;

    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '1');
    // Локализованные короткие названия дней через DateFormat
    final dayLabels = List.generate(7,
        (i) => DateFormat('EEE', locale).format(DateTime(2024, 1, 1 + i)));

    final emojis = ['⭐', '💪', '📚', '🏃', '💧', '🧘', '🎯', '✏️', '🍎', '😴'];
    final colors = [
      0xFFE8A0BF, 0xFFC084FC, 0xFF818CF8,
      0xFF86EFAC, 0xFFFB923C, 0xFFF472B6,
      0xFF60A5FA, 0xFFFDE68A,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.newHabit,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  style: const TextStyle(color: AppColors.textPrimary),
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    hintText: l10n.habitNameHint,
                    hintStyle:
                        const TextStyle(color: AppColors.textMuted),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.textMuted),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Emoji picker
                Text(l10n.habitIcon,
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: emojis.map((e) {
                    final selected = emoji == e;
                    return GestureDetector(
                      onTap: () => setS(() => emoji = e),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.accent.withValues(alpha: 0.2)
                              : AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? Border.all(color: AppColors.accent)
                              : null,
                        ),
                        child: Center(
                            child: Text(e,
                                style: const TextStyle(fontSize: 20))),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Color picker
                Text(l10n.habitColor,
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: colors.map((c) {
                    final selected = color == c;
                    return GestureDetector(
                      onTap: () => setS(() => color = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(
                                  color: Colors.white, width: 2)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Type
                Text(l10n.habitType,
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _typeChip('daily', l10n.habitTypeDaily, type, (v) => setS(() => type = v)),
                    _typeChip('weekly', l10n.habitTypeWeekly, type, (v) => setS(() => type = v)),
                    _typeChip('counter', l10n.habitTypeCounter, type, (v) => setS(() => type = v)),
                  ],
                ),

                // Weekly: day selector
                if (type == 'weekly') ...[
                  const SizedBox(height: 12),
                  Text(l10n.habitWeekDays,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final day = i + 1;
                      final selected = weekDays.contains(day);
                      return GestureDetector(
                        onTap: () => setS(() {
                          if (selected) {
                            if (weekDays.length > 1) weekDays.remove(day);
                          } else {
                            weekDays.add(day);
                          }
                        }),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? Color(color).withValues(alpha: 0.8)
                                : AppColors.surfaceAlt,
                            border: selected
                                ? Border.all(color: Color(color), width: 1.5)
                                : null,
                          ),
                          child: Center(
                            child: Text(dayLabels[i],
                                style: TextStyle(
                                  color: selected ? Colors.white : AppColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                )),
                          ),
                        ),
                      );
                    }),
                  ),
                ],

                // Counter: target
                if (type == 'counter') ...[
                  const SizedBox(height: 12),
                  Text(l10n.habitGoalPerDay,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: targetCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.textPrimary),
                    cursorColor: AppColors.accent,
                    onChanged: (v) => targetCount = int.tryParse(v) ?? 1,
                    decoration: InputDecoration(
                      hintText: l10n.habitGoalHint,
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.textMuted),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.accent),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel,
                  style: const TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                final n = nameCtrl.text.trim();
                if (n.isEmpty) return;
                final habit = HabitModel(
                  id: const Uuid().v4(),
                  name: n,
                  emoji: emoji,
                  type: type,
                  color: color,
                  targetCount: targetCount,
                  weekDays: type == 'weekly' ? (List<int>.from(weekDays)..sort()) : [1, 2, 3, 4, 5, 6, 7],
                  createdAt: DateTime.now(),
                  isActive: true,
                );
                _repo.addHabit(widget.uid, habit);
                Navigator.pop(ctx);
              },
              child: Text(l10n.add,
                  style: const TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label, String current,
      void Function(String) onTap) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppColors.accent.withValues(alpha: 0.2)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: active ? Border.all(color: AppColors.accent) : null,
        ),
        child: Text(label,
            style: TextStyle(
              color: active ? AppColors.accent : AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.habits),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Expanded(
              child: StreamBuilder<List<HabitModel>>(
                stream: _repo.watchHabits(widget.uid),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting &&
                      !snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final habits = snap.data ?? [];
                  if (habits.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('(´• ω •`)',
                              style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 12),
                          Text(AppLocalizations.of(context)!.addFirstHabit,
                              style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 14)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: habits.length,
                    itemBuilder: (ctx, i) => _HabitCard(
                      habit: habits[i],
                      uid: widget.uid,
                      gridDays: _gridDays,
                      repo: _repo,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

// ─────────────────────────────────────────
// HABIT CARD WITH GRID
// ─────────────────────────────────────────
class _HabitCard extends StatelessWidget {
  final HabitModel habit;
  final String uid;
  final List<DateTime> gridDays;
  final HabitRepository repo;

  const _HabitCard({
    required this.habit,
    required this.uid,
    required this.gridDays,
    required this.repo,
  });

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final fromDate = _dateKey(gridDays.first);
    final toDate = _dateKey(gridDays.last);

    return StreamBuilder<List<HabitLogModel>>(
      stream: repo.watchLogsForHabit(uid, habit.id, fromDate, toDate),
      builder: (context, snap) {
        final logs = snap.data ?? [];
        final logMap = {for (final l in logs) l.date: l.count};

        // Compute streak
        int streak = 0;
        final today = DateTime.now();
        for (int i = 0; i <= 365; i++) {
          final d = today.subtract(Duration(days: i));
          final key = _dateKey(d);
          if ((logMap[key] ?? 0) > 0) {
            streak++;
          } else if (i > 0) {
            break;
          }
        }

        return Dismissible(
          key: Key(habit.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => repo.deleteHabit(uid, habit.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.red),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Text(habit.emoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(habit.name,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ),
                    if (streak > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥',
                              style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 3),
                          Text('$streak',
                              style: const TextStyle(
                                  color: AppColors.accent3,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Grid — 5 rows × 7 columns
                _buildGrid(logMap, context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(Map<String, int> logMap, BuildContext context) {
    const gap = 4.0;
    final locale = Localizations.localeOf(context).toString();
    final dayLabels = List.generate(
        7, (i) => DateFormat('EEE', locale).format(DateTime(2024, 1, 1 + i)));

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = (constraints.maxWidth - gap * 6) / 7;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day labels
        Row(
          children: List.generate(7, (col) {
            return SizedBox(
              width: cellSize,
              child: Text(
                dayLabels[col],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          })
              .expand((w) => [w, const SizedBox(width: gap)])
              .toList()
            ..removeLast(),
        ),
        const SizedBox(height: 4),

        // 5 weeks
        for (int row = 0; row < 5; row++) ...[
          Row(
            children: List.generate(7, (col) {
              final day = gridDays[row * 7 + col];
              final key = _dateKey(day);
              final count = logMap[key] ?? 0;
              final isToday = _isToday(day);
              final isFuture = day.isAfter(DateTime.now());

              // For weekly: only applicable on selected weekdays
              final weekday = day.weekday; // 1=Mon..7=Sun
              final isApplicable = habit.type != 'weekly' || habit.weekDays.contains(weekday);
              final done = count >= habit.targetCount && isApplicable;
              final canTap = isToday && isApplicable;

              return GestureDetector(
                onTap: canTap
                    ? () async {
                        if (habit.type == 'counter') {
                          // Increment, reset to 0 when exceeds target
                          final next = count >= habit.targetCount ? 0 : count + 1;
                          await repo.logHabit(uid, habit.id, key, next);
                        } else {
                          await repo.logHabit(uid, habit.id, key, count > 0 ? 0 : 1);
                        }
                      }
                    : null,
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: !isApplicable
                        ? Colors.transparent
                        : done
                            ? Color(habit.color).withValues(alpha: 0.85)
                            : isFuture
                                ? AppColors.divider.withValues(alpha: 0.3)
                                : AppColors.divider,
                    border: isToday && isApplicable
                        ? Border.all(color: Color(habit.color), width: 2)
                        : null,
                    boxShadow: done
                        ? [BoxShadow(color: Color(habit.color).withValues(alpha: 0.35), blurRadius: 6)]
                        : null,
                  ),
                  child: !isApplicable
                      ? null
                      : habit.type == 'counter' && count > 0
                          ? Center(
                              child: Text('$count',
                                  style: TextStyle(
                                    color: done ? Colors.white : AppColors.textMuted,
                                    fontSize: cellSize * 0.32,
                                    fontWeight: FontWeight.w800,
                                  )),
                            )
                          : done
                              ? Center(
                                  child: Icon(Icons.check_rounded,
                                      size: 14,
                                      color: Colors.white.withValues(alpha: 0.9)))
                              : null,
                ),
              );
            })
                .expand((w) => [w, const SizedBox(width: gap)])
                .toList()
              ..removeLast(),
          ),
          if (row < 4) const SizedBox(height: gap),
        ],
      ],
    );
      },
    );
  }
}

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';
import '../theme/app_theme.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  bool _visible = true; // окно видимо / скрыто

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.35, end: 0.85).animate(_pulseCtrl);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Диалог: переименовать метку ─────────────────────────────────────────────
  void _editLabel(TimerService timer, bool isWork) {
    final ctrl = TextEditingController(
        text: isWork ? timer.workLabel : timer.breakLabel);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rename', style: AppFonts.fredoka(fontSize: 18)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          // Лимит: уведомление в шторке не резиновое
          maxLength: TimerService.maxLabelLength,
          style: const TextStyle(color: AppColors.textPrimary),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: isWork ? 'FOCUS' : 'BREAK',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            counterStyle: const TextStyle(
                color: AppColors.textMuted, fontSize: 11),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final val = ctrl.text.trim().toUpperCase();
              if (val.isNotEmpty) {
                if (isWork) { timer.setWorkLabel(val); }
                else        { timer.setBreakLabel(val); }
              }
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  // ── Диалог: настройки помодоро ──────────────────────────────────────────────
  void _editPomodoro(TimerService timer) {
    int  work  = timer.workMinutes;
    int  brk   = timer.breakMinutes;
    bool notif = timer.notificationsEnabled;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text('Настройки', style: AppFonts.fredoka(fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _durationRow('Фокус', work, 1, 90,
                  (v) => setS(() => work = v)),
              const SizedBox(height: 8),
              _durationRow('Перерыв', brk, 1, 30,
                  (v) => setS(() => brk = v)),
              const SizedBox(height: 12),
              // ── Тоггл уведомлений ────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_outlined,
                        size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Уведомления',
                          style: AppFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: notif,
                        onChanged: (v) => setS(() => notif = v),
                        activeThumbColor: AppColors.accent,
                        activeTrackColor:
                            AppColors.accent.withValues(alpha: 0.35),
                        inactiveThumbColor: AppColors.textMuted,
                        inactiveTrackColor: AppColors.divider,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                timer.setWorkMinutes(work);
                timer.setBreakMinutes(brk);
                timer.setNotificationsEnabled(notif);
                Navigator.pop(ctx);
              },
              child: const Text('Сохранить',
                  style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _durationRow(String label, int value, int min, int max,
      ValueChanged<int> onChange) {
    return Row(
      children: [
        Text(label,
            style: AppFonts.nunito(
                fontSize: 14, fontWeight: FontWeight.w600)),
        const Spacer(),
        _adjBtn(Icons.remove_rounded,
            value > min ? () => onChange(value - 1) : null),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('$value мин',
              style: AppFonts.fredoka(fontSize: 15)),
        ),
        _adjBtn(Icons.add_rounded,
            value < max ? () => onChange(value + 1) : null),
      ],
    );
  }

  Widget _adjBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: onTap != null ? AppColors.surfaceAlt : AppColors.divider,
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon,
            size: 16,
            color: onTap != null
                ? AppColors.textPrimary
                : AppColors.textMuted),
      ),
    );
  }

  // ── BUILD ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<TimerService>(context);
    final isWork = timer.mode == TimerMode.work;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Фоновое изображение
          Positioned.fill(
            child: Image.asset(
              'assets/img/Background.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                if (_visible)
                  _buildWindow(timer, isWork)
                else
                  _buildShowChip(timer),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Окно таймера ────────────────────────────────────────────────────────────
  Widget _buildWindow(TimerService timer, bool isWork) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Заголовок окна ────────────────────────────────────
                _buildTitleBar(timer, isWork),
                // ── Содержимое ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildRing(timer),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfo(timer, isWork),
                              _buildControls(timer),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Заголовок окна с кнопками ────────────────────────────────────────────
  Widget _buildTitleBar(TimerService timer, bool isWork) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // тёплый розоватый оттенок — как в референсе
        color: AppColors.accent2.withValues(alpha: 0.18),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          // Название текущего режима
          Text(
            isWork ? timer.workLabel : timer.breakLabel,
            style: AppFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 1.4,
            ),
          ),
          const Spacer(),
          // [песочные часы] настройки помодоро
          _winBtn(
            'assets/img/icon_sandclock.png',
            tooltip: 'Настройки',
            onTap: () => _editPomodoro(timer),
          ),
          const SizedBox(width: 6),
          // [редактировать] переименовать
          _winBtn(
            'assets/img/icon_edit.png',
            tooltip: 'Переименовать',
            onTap: () => _editLabel(timer, isWork),
          ),
          const SizedBox(width: 6),
          // [крестик] скрыть
          _winBtn(
            'assets/img/icon_close.png',
            tooltip: 'Скрыть',
            onTap: () => setState(() => _visible = false),
            isClose: true,
          ),
        ],
      ),
    );
  }

  Widget _winBtn(
    String asset, {
    required VoidCallback onTap,
    String tooltip = '',
    bool isClose = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isClose
                ? const Color(0xFFE8C5C0)
                : AppColors.surfaceAlt,
            border: Border.all(
              color: isClose
                  ? const Color(0xFFD4A0A0)
                  : AppColors.divider,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Image.asset(asset),
          ),
        ),
      ),
    );
  }

  // ── Чип "показать таймер" (когда окно скрыто) ───────────────────────────────
  Widget _buildShowChip(TimerService timer) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () => setState(() => _visible = true),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 15, color: AppColors.accent2),
                    const SizedBox(width: 6),
                    Text(
                      timer.timeString,
                      style: AppFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 15, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Кольцо ─────────────────────────────────────────────────────────────────
  Widget _buildRing(TimerService timer) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(80, 80),
            painter: _RingPainter(progress: timer.progress),
          ),
          Text(
            timer.timeString,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Сессионные пилюли ───────────────────────────────────────────────────────
  Widget _buildInfo(TimerService timer, bool isWork) {
    final raw = timer.sessions % 4;
    final completedInCycle =
        (raw == 0 && timer.sessions > 0) ? 4 : raw;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final done = i < completedInCycle;
        final isActive =
            !done && i == completedInCycle && timer.isRunning && isWork;

        if (isActive) {
          return AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, unused) => _pill(
              done: false,
              opacity: _pulseAnim.value,
              isActive: true,
              isWork: isWork,
            ),
          );
        }
        return _pill(
          done: done,
          opacity: done ? 1.0 : 0.15,
          isActive: false,
          isWork: isWork,
        );
      }),
    );
  }

  Widget _pill({
    required bool done,
    required double opacity,
    required bool isActive,
    required bool isWork,
  }) {
    const focusColor = AppColors.accent2;
    const breakColor = Color(0xFFE8E0D5);
    final activeColor = isWork ? focusColor : breakColor;

    return Container(
      margin: const EdgeInsets.only(right: 5),
      width: 26,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: (done || isActive)
            ? activeColor.withValues(alpha: isActive ? opacity : 1.0)
            : AppColors.divider.withValues(alpha: opacity),
        boxShadow: done
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.45),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }

  // ── Кнопки управления ───────────────────────────────────────────────────────
  Widget _buildControls(TimerService timer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ctrlSmall(
            asset: 'assets/img/icon_repeat_pomodoro.png',
            onTap: timer.reset),
        const SizedBox(width: 8),
        _ctrlPlay(timer),
        const SizedBox(width: 8),
        _ctrlSmall(
            asset: 'assets/img/icon_next_pomodoro.png',
            onTap: timer.skip),
      ],
    );
  }

  Widget _ctrlSmall({required String asset, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: AppColors.surfaceAlt,
          border: Border.all(color: AppColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Image.asset(asset),
        ),
      ),
    );
  }

  Widget _ctrlPlay(TimerService timer) {
    final isRunning = timer.isRunning;
    return GestureDetector(
      onTap: timer.startPause,
      child: Container(
        width: 46,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: isRunning
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent, AppColors.accent2],
                ),
          color: isRunning ? AppColors.surfaceAlt : null,
          border: isRunning ? Border.all(color: AppColors.divider) : null,
          boxShadow: isRunning
              ? null
              : [
                  BoxShadow(
                    color: AppColors.accent2.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            isRunning
                ? 'assets/img/icon_pause_pomodoro.png'
                : 'assets/img/icon_play_pomodoro.png',
          ),
        ),
      ),
    );
  }
}

// ── Gradient progress ring ────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3.5;
    const strokeWidth = 7.0;
    const startAngle = -math.pi / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.divider
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final progressPaint = Paint()
        ..shader = const SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + math.pi * 2,
          colors: [AppColors.accent, AppColors.accent2],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        startAngle,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

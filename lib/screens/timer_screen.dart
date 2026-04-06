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

  String _workLabel = 'FOCUS';
  String _breakLabel = 'BREAK';

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.35, end: 0.85).animate(_pulseCtrl);
  }

  void _editLabel(bool isWork) {
    final ctrl = TextEditingController(text: isWork ? _workLabel : _breakLabel);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rename', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: AppColors.textPrimary),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: AppColors.textMuted),
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
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final val = ctrl.text.trim();
              if (val.isNotEmpty) {
                setState(() {
                  if (isWork) { _workLabel = val.toUpperCase(); }
                  else { _breakLabel = val.toUpperCase(); }
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = Provider.of<TimerService>(context);
    final isWork = timer.mode == TimerMode.work;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2D1B4E), AppColors.background],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // ── TIMER CARD ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                        decoration: BoxDecoration(
                          color: const Color(0x850A041C),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.13),
                          ),
                        ),
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
                                  // Label top center — tappable
                                  GestureDetector(
                                    onTap: () => _editLabel(isWork),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          isWork ? _workLabel : _breakLabel,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white.withValues(alpha: 0.45),
                                            letterSpacing: 1.4,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.edit_outlined,
                                            size: 10,
                                            color: Colors.white.withValues(alpha: 0.3)),
                                      ],
                                    ),
                                  ),
                                  // Session dots middle
                                  _buildInfo(timer, isWork),
                                  // Buttons bottom
                                  _buildControls(timer),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }


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
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(TimerService timer, bool isWork) {
    final completedInCycle = timer.sessions % 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Session pills
        Row(
          children: List.generate(4, (i) {
            final done = i < completedInCycle;
            final isActive =
                !done && i == completedInCycle && timer.isRunning && isWork;

            if (isActive) {
              return AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context2, _) => _pill(
                  done: false,
                  opacity: _pulseAnim.value,
                  isActive: true,
                ),
              );
            }
            return _pill(
              done: done,
              opacity: done ? 1.0 : 0.15,
              isActive: false,
            );
          }),
        ),
      ],
    );
  }

  Widget _pill({
    required bool done,
    required double opacity,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      width: 26,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: (done || isActive)
            ? const LinearGradient(
                colors: [Color(0xFFF472B6), Color(0xFFC084FC)],
              )
            : null,
        color: (done || isActive) ? null : Colors.white.withValues(alpha: opacity),
        boxShadow: done
            ? [
                BoxShadow(
                  color: const Color(0xFFF472B6).withValues(alpha: 0.5),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildControls(TimerService timer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ctrlSmall(icon: Icons.refresh_rounded, onTap: timer.reset),
        const SizedBox(width: 8),
        _ctrlPlay(timer),
        const SizedBox(width: 8),
        _ctrlSmall(icon: Icons.skip_next_rounded, onTap: timer.skip),
      ],
    );
  }

  Widget _ctrlSmall({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: Colors.white.withValues(alpha: 0.09),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.75),
          size: 17,
        ),
      ),
    );
  }

  Widget _ctrlPlay(TimerService timer) {
    return GestureDetector(
      onTap: timer.startPause,
      child: Container(
        width: 46,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF472B6),
              Color(0xFFC084FC),
              Color(0xFF818CF8),
            ],
            stops: [0, 0.55, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC084FC).withValues(alpha: 0.5),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          timer.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 20,
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

    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc with sweep gradient
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final progressPaint = Paint()
        ..shader = const SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + math.pi * 2,
          colors: [Color(0xFFF472B6), Color(0xFF818CF8)],
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

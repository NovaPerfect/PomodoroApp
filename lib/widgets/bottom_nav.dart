import 'package:flutter/material.dart';
import '../screens/timer_screen.dart';
import '../screens/todo_screen.dart';
import '../screens/diary_screen.dart';
import '../screens/music_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/premium_screen.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

// ── Nav item config ───────────────────────────────────────────────────────────
class _NavItem {
  final String? imagePath; // PNG asset — если есть
  final IconData fallback;  // Material иконка — пока нет PNG

  const _NavItem({this.imagePath, required this.fallback});
}

const _navItems = [
  _NavItem(imagePath: 'assets/img/icon_pomodoro.png',   fallback: Icons.timer_outlined),
  _NavItem(imagePath: 'assets/img/icon_todo.png',       fallback: Icons.check_circle_outline),
  _NavItem(imagePath: 'assets/img/icon_diary.png',      fallback: Icons.book_outlined),
  _NavItem(imagePath: 'assets/img/icon_music.png',      fallback: Icons.music_note_outlined),
  _NavItem(imagePath: 'assets/img/icon_statistic.png',  fallback: Icons.bar_chart_rounded),
  _NavItem(imagePath: 'assets/img/icon_settings.png',   fallback: Icons.settings_outlined),
  _NavItem(fallback: Icons.workspace_premium_outlined),
];

// ═════════════════════════════════════════════════════════════════════════════
//  MAIN NAVIGATION
// ═════════════════════════════════════════════════════════════════════════════
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  int _prevIndex = 0;
  final _audio = AudioService();
  final _pageController = PageController();

  static const _pages = [
    TimerScreen(),
    TodoScreen(),
    DiaryScreen(),
    MusicScreen(),
    StatsScreen(),
    SettingsScreen(),
    PremiumScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _audio.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // НАВИГАЦИЯ
          SafeArea(
            bottom: false,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final count = _navItems.length;
                  const gap = 4.0;
                  final btnSize = ((constraints.maxWidth - gap * (count - 1)) / count)
                      .clamp(32.0, 52.0);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(count, (i) {
                      return _NavButton(
                        key: ValueKey(i),
                        item: _navItems[i],
                        isActive: i == _currentIndex,
                        justActivated: i == _currentIndex && i != _prevIndex,
                        size: btnSize,
                        onTap: () {
                          setState(() {
                            _prevIndex = _currentIndex;
                            _currentIndex = i;
                          });
                          _pageController.jumpToPage(i);
                        },
                      );
                    }),
                  );
                },
              ),
            ),
          ),

          Divider(height: 1, color: AppColors.divider),

          // КОНТЕНТ
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() {
                _prevIndex = _currentIndex;
                _currentIndex = i;
              }),
              children: _pages,
            ),
          ),
        ],
      ),

      bottomNavigationBar: _audio.hasTrack
          ? _MiniPlayer(audio: _audio)
          : null,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  NAV BUTTON — kawaii card с pop анимацией
// ═════════════════════════════════════════════════════════════════════════════
class _NavButton extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final bool justActivated;
  final double size;
  final VoidCallback onTap;

  const _NavButton({
    super.key,
    required this.item,
    required this.isActive,
    required this.justActivated,
    required this.size,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;      // свайп — прыжок
  late final AnimationController _tapCtrl;   // тап — pop scale
  late final Animation<double> _translateY;
  late final Animation<double> _rotate;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Тап — быстрый pop scale (оригинальный)
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.22), weight: 25),
      TweenSequenceItem(
        tween: Tween(begin: 1.22, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 75,
      ),
    ]).animate(_tapCtrl);

    // Свайп — прыжок: вверх → вниз с отскоком → покой
    _translateY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 3.0), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 3.0, end: -4.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Лёгкое покачивание в воздухе
    _rotate = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.12), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -0.12, end: 0.12), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.12, end: -0.05), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _tapCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_NavButton old) {
    super.didUpdateWidget(old);
    // Свайп переключил вкладку — запускаем bounce на новой активной
    if (widget.justActivated && !old.justActivated) {
      _ctrl.forward(from: 0);
    }
  }

  void _handleTap() {
    _tapCtrl.forward(from: 0); // pop scale
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isActive;

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_ctrl, _tapCtrl]),
        builder: (context, child) => Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.identity()
            // ignore: deprecated_member_use
            ..translate(0.0, _translateY.value)
            ..rotateZ(_rotate.value)
            // ignore: deprecated_member_use
            ..scale(_scale.value),
          child: child,
        ),
        child: CustomPaint(
          painter: _SketchBorderPainter(isActive: isActive),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFF5ECD8)          // активная: насыщенный бежевый
                  : const Color(0xFFFFFCF8).withValues(alpha: 0.75), // неактивная: полупрозрачный белый
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5C4A3A).withValues(alpha: isActive ? 0.28 : 0.10),
                  blurRadius: isActive ? 8 : 3,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: widget.item.imagePath != null
                ? Image.asset(
                    widget.item.imagePath!,
                    fit: BoxFit.contain,
                    // нет цветовых эффектов — PNG как есть
                  )
                : Icon(
                    widget.item.fallback,
                    color: const Color(0xFF5C4A3A).withValues(alpha: isActive ? 0.9 : 0.35),
                    size: widget.size * 0.48,
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SKETCH BORDER PAINTER — небрежная обводка как от руки
// ─────────────────────────────────────────────────────────────────────────────
class _SketchBorderPainter extends CustomPainter {
  final bool isActive;
  _SketchBorderPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {

    const radius = Radius.circular(14);
    const color = Color(0xFF5C4A3A);
    final alpha = isActive ? 0.80 : 0.20;

    // Основная линия
    final p1 = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        radius,
      ),
      p1,
    );

    // Вторая линия чуть смещена — эффект "от руки"
    final p2 = Paint()
      ..color = color.withValues(alpha: alpha * 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-1.2, 0.8, size.width + 1.5, size.height + 0.5),
        const Radius.circular(15),
      ),
      p2,
    );

    // Третья — лёгкий штрих
    final p3 = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.8, -0.8, size.width - 0.5, size.height + 1.2),
        const Radius.circular(13),
      ),
      p3,
    );
  }

  @override
  bool shouldRepaint(_SketchBorderPainter old) => old.isActive != isActive;
}

// ════════════════════════════════════════════════════════════════════════════
//  МИНИ-ПЛЕЕР
// ════════════════════════════════════════════════════════════════════════════
class _MiniPlayer extends StatelessWidget {
  final AudioService audio;
  const _MiniPlayer({required this.audio});

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final track = audio.currentTrack!;
    final progress = audio.duration.inSeconds > 0
        ? audio.position.inSeconds / audio.duration.inSeconds
        : 0.0;
    final trackCount = audio.queueLength;
    final trackIndex = audio.currentIndex;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (audio.playlistName != null)
                          Text(
                            audio.playlistName!,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: audio.toggleShuffle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.shuffle_rounded,
                        color: audio.isShuffle
                            ? AppColors.accent
                            : AppColors.textMuted,
                        size: 18),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: audio.prev,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.skip_previous_rounded,
                        color: AppColors.textPrimary, size: 24),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: audio.playPause,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.accent, width: 1.5),
                      ),
                      child: Icon(
                        audio.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: audio.next,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.skip_next_rounded,
                        color: AppColors.textPrimary, size: 24),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: audio.toggleLoop,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.repeat_rounded,
                        color: audio.isLoop
                            ? AppColors.accent
                            : AppColors.textMuted,
                        size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(_fmt(audio.position),
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 10)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.accent,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                        thumbColor: AppColors.accent,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 4),
                        trackHeight: 2,
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (val) => audio.seek(Duration(
                            seconds: (val * audio.duration.inSeconds).toInt())),
                      ),
                    ),
                  ),
                  Text(_fmt(audio.duration),
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              if (trackCount > 0)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(trackCount, (i) {
                      final isActive = i == trackIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: isActive ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ),
              const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}

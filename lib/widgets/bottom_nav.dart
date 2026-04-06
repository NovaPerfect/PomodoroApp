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

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final _audio = AudioService();
  final _pageController = PageController();

  final List<IconData> _icons = const [
    Icons.timer_outlined,
    Icons.check_circle_outline,
    Icons.book_outlined,
    Icons.music_note_outlined,
    Icons.bar_chart_rounded,
    Icons.settings_outlined,
    Icons.workspace_premium_outlined,
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
      body: Column(
        children: [
          // ═══ НАВИГАЦИЯ СВЕРХУ ═══
          SafeArea(
            bottom: false,
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_icons.length, (i) {
                  final isActive = i == _currentIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _currentIndex = i);
                      _pageController.jumpToPage(i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _icons[i],
                        color: isActive
                            ? AppColors.accent
                            : AppColors.textMuted,
                        size: 24,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),

          // ═══ КОНТЕНТ СО СВАЙПОМ ═══
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              children: const [
                TimerScreen(),
                TodoScreen(),
                DiaryScreen(),
                MusicScreen(),
                StatsScreen(),
                SettingsScreen(),
                PremiumScreen(),
              ],
            ),
          ),
        ],
      ),

      // ═══ МИНИ-ПЛЕЕР СНИЗУ ═══
      bottomNavigationBar: _audio.hasTrack
          ? _MiniPlayer(audio: _audio)
          : null,
    );
  }
}

// ════════════════════════════════════════
//  МИНИ-ПЛЕЕР
// ════════════════════════════════════════
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
    final track    = audio.currentTrack!;
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
              // ── строка: название + кнопки ──
              Row(
                children: [
                  // название и плейлист
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

                  // shuffle
                  IconButton(
                    onPressed: audio.toggleShuffle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: audio.isShuffle
                          ? AppColors.accent
                          : AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // prev
                  IconButton(
                    onPressed: audio.prev,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.skip_previous_rounded,
                        color: AppColors.textPrimary, size: 24),
                  ),
                  const SizedBox(width: 4),

                  // play/pause
                  GestureDetector(
                    onTap: audio.playPause,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                        border: Border.all(
                            color: AppColors.accent, width: 1.5),
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

                  // next
                  IconButton(
                    onPressed: audio.next,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.skip_next_rounded,
                        color: AppColors.textPrimary, size: 24),
                  ),
                  const SizedBox(width: 8),

                  // repeat
                  IconButton(
                    onPressed: audio.toggleLoop,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.repeat_rounded,
                      color: audio.isLoop
                          ? AppColors.accent
                          : AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ── прогресс бар ──
              Row(
                children: [
                  Text(
                    _fmt(audio.position),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 10),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.accent,
                        inactiveTrackColor:
                        Colors.white.withValues(alpha: 0.1),
                        thumbColor: AppColors.accent,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 4),
                        trackHeight: 2,
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (val) => audio.seek(
                          Duration(
                            seconds:
                            (val * audio.duration.inSeconds).toInt(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    _fmt(audio.duration),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 10),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // ── кружочки треков ──
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

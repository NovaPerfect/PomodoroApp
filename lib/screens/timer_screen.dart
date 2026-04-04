import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';
import '../theme/app_theme.dart';
import 'package:untitled/l10n/app_localizations.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    // Listen to TimerService changes via Provider
    final timer = Provider.of<TimerService>(context);
    final l10n = AppLocalizations.of(context)!;

    final Color accentColor = timer.mode == TimerMode.work
        ? AppColors.accent3
        : AppColors.accent;

    return Scaffold(
      body: Stack(
        children: [
          // Background
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
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Mode Title (Localized)
                Text(
                  timer.mode == TimerMode.work ? l10n.workTimer : l10n.breakTimer,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                // Session dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i < timer.sessions % 4 ? 16 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: i < timer.sessions % 4
                          ? accentColor
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  )),
                ),

                const Spacer(),

                // Timer Ring
                SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 4,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: timer.progress,
                          strokeWidth: 4,
                          color: accentColor,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        timer.timeString,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 56,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: timer.reset,
                      icon: const Icon(Icons.refresh_rounded),
                      color: AppColors.textMuted,
                      iconSize: 28,
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: timer.startPause,
                      child: Container(
                        width: 70, height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accentColor, width: 2),
                          color: accentColor.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          timer.isRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: accentColor,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: timer.skip,
                      icon: const Icon(Icons.skip_next_rounded),
                      color: AppColors.textMuted,
                      iconSize: 28,
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

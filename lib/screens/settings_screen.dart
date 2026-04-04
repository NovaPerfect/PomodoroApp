import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volume_controller/volume_controller.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../services/timer_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import 'package:untitled/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _audio = AudioService();
  double _playerVolume = 1.0;   // громкость плеера 0.0 - 1.0
  double _systemVolume = 0.5;   // громкость системы 0.0 - 1.0

  @override
  void initState() {
    super.initState();
    _playerVolume = _audio.player.volume;

    VolumeController().getVolume().then((vol) {
      if (mounted) setState(() => _systemVolume = vol);
    });

    VolumeController().listener((vol) {
      if (mounted) setState(() => _systemVolume = vol);
    });
  }

  @override
  void dispose() {
    VolumeController().removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeService = Provider.of<LocaleService>(context);
    final timerService  = Provider.of<TimerService>(context);
    final authService   = Provider.of<AuthService>(context);
    final l10n          = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settings,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),

              // --- язык ---
              _buildSectionTitle(l10n.language),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildListTile(
                      title: 'English',
                      trailing: localeService.locale.languageCode == 'en'
                          ? const Icon(Icons.check, color: AppColors.accent)
                          : null,
                      onTap: () =>
                          localeService.setLocale(const Locale('en')),
                    ),
                    Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.05)),
                    _buildListTile(
                      title: 'Русский',
                      trailing: localeService.locale.languageCode == 'ru'
                          ? const Icon(Icons.check, color: AppColors.accent)
                          : null,
                      onTap: () =>
                          localeService.setLocale(const Locale('ru')),
                    ),
                    Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.05)),
                    _buildListTile(
                      title: 'Slovenčina',
                      trailing: localeService.locale.languageCode == 'sk'
                          ? const Icon(Icons.check, color: AppColors.accent)
                          : null,
                      onTap: () =>
                          localeService.setLocale(const Locale('sk')),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- помодоро ---
              _buildSectionTitle('Pomodoro'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildSlider(
                      label: l10n.workTimer,
                      value: timerService.workMinutes.toDouble(),
                      min: 1,
                      max: 60,
                      displayValue: '${timerService.workMinutes} min',
                      onChanged: (val) =>
                          timerService.setWorkMinutes(val.toInt()),
                    ),
                    const SizedBox(height: 16),
                    _buildSlider(
                      label: l10n.breakTimer,
                      value: timerService.breakMinutes.toDouble(),
                      min: 1,
                      max: 30,
                      displayValue: '${timerService.breakMinutes} min',
                      onChanged: (val) =>
                          timerService.setBreakMinutes(val.toInt()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- громкость ---
              _buildSectionTitle('Громкость'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // громкость плеера
                    _buildSlider(
                      label: 'Плеер',
                      icon: Icons.music_note_outlined,
                      value: _playerVolume,
                      min: 0.0,
                      max: 1.0,
                      displayValue:
                      '${(_playerVolume * 100).toInt()}%',
                      onChanged: (val) {
                        setState(() => _playerVolume = val);
                        _audio.player.setVolume(val);
                      },
                    ),

                    const SizedBox(height: 16),

                    // системная громкость
                    _buildSlider(
                      label: 'Система',
                      icon: Icons.volume_up_outlined,
                      value: _systemVolume,
                      min: 0.0,
                      max: 1.0,
                      displayValue:
                      '${(_systemVolume * 100).toInt()}%',
                      onChanged: (val) {
                        setState(() => _systemVolume = val);
                        VolumeController().setVolume(val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- аккаунт ---
              _buildSectionTitle('Account'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildListTile(
                  title: 'Sign Out',
                  trailing: const Icon(Icons.logout_rounded,
                      color: Colors.redAccent, size: 18),
                  onTap: () => authService.signOut(),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title:
      Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      trailing: trailing,
      onTap: onTap,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildSlider({
    required String label,
    IconData? icon,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.textMuted, size: 16),
                  const SizedBox(width: 6),
                ],
                Text(label,
                    style: const TextStyle(color: AppColors.textPrimary)),
              ],
            ),
            Text(
              displayValue,
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.accent,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            thumbColor: AppColors.accent,
            overlayColor: AppColors.accent.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
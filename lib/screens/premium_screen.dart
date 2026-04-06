import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/premium_service.dart';
import '../theme/app_theme.dart';
import 'habit_screen.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumService>();
    return premium.isPremium
        ? const _PremiumContent()
        : const _Paywall();
  }
}

// ─────────────────────────────────────────
// PAYWALL
// ─────────────────────────────────────────
class _Paywall extends StatelessWidget {
  const _Paywall();

  @override
  Widget build(BuildContext context) {
    final premium = context.read<PremiumService>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D1B4E), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(),

                // Crown icon
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF472B6), Color(0xFFC084FC)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC084FC).withValues(alpha: 0.5),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 46,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'StudyFlow Premium',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                Text(
                  'Разблокируй все возможности\nдля продуктивного обучения',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Feature list
                _featureRow('📋', 'Трекер привычек', 'Ежедневные, еженедельные, счётчики'),
                const SizedBox(height: 16),
                _featureRow('🏆', 'Достижения', 'Зарабатывай баллы и открывай кастомизацию'),
                const SizedBox(height: 16),
                _featureRow('📊', 'Расширенная статистика', 'Графики, тренды и детальная аналитика'),

                const Spacer(),

                // Unlock button
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => premium.unlock(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF472B6), Color(0xFFC084FC)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC084FC).withValues(alpha: 0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Попробовать Premium',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Тестовый доступ — без оплаты',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureRow(String emoji, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// PREMIUM CONTENT
// ─────────────────────────────────────────
class _PremiumContent extends StatelessWidget {
  const _PremiumContent();

  @override
  Widget build(BuildContext context) {
    final premium = context.read<PremiumService>();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Твои эксклюзивные возможности',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    // Crown badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF472B6), Color(0xFFC084FC)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.workspace_premium_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Premium',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Habits section
            SliverToBoxAdapter(
              child: _SectionCard(
                emoji: '📋',
                title: 'Трекер привычек',
                subtitle: 'Ежедневные цели и streak',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => HabitScreen(uid: uid)),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Achievements section (stub)
            const SliverToBoxAdapter(
              child: _SectionCard(
                emoji: '🏆',
                title: 'Достижения',
                subtitle: 'Скоро — зарабатывай баллы и открывай кастомизацию',
                comingSoon: true,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Extended stats section (stub)
            const SliverToBoxAdapter(
              child: _SectionCard(
                emoji: '📊',
                title: 'Расширенная статистика',
                subtitle: 'Скоро — графики, тренды и детальная аналитика',
                comingSoon: true,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Revoke button (for testing)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextButton(
                  onPressed: () => premium.revoke(),
                  child: Text(
                    'Отменить Premium (тест)',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.25),
                        fontSize: 12),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool comingSoon;

  const _SectionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: comingSoon ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          color: comingSoon
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              if (comingSoon)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Скоро',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                          fontWeight: FontWeight.w700)),
                )
              else
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'terms_screen.dart';
import 'privacy_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final l10n = AppLocalizations.of(context)!;

    if (auth.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error!), backgroundColor: Colors.redAccent),
        );
        auth.clearError();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Лого ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/img/icon.png', width: 38, height: 38,
                    errorBuilder: (_, _, _) =>
                        const Text('🐱', style: TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'nekodoro',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Чат-демо ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BubbleApp(text: l10n.loginBubble1),
                    const SizedBox(height: 12),
                    _BubbleUser(text: l10n.loginBubble2),
                    const SizedBox(height: 12),
                    _BubbleApp(text: l10n.loginBubble3),
                    const SizedBox(height: 12),
                    _BubbleUser(text: l10n.loginBubble4),
                    const SizedBox(height: 12),
                    _BubbleApp(text: l10n.loginBubble5),
                  ],
                ),
              ),
            ),

            // ── Кнопки ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: auth.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    )
                  : Column(
                      children: [
                        _AuthButton(
                          label: l10n.signIn,
                          filled: true,
                          onTap: auth.signInWithGoogle,
                          icon: const _GoogleLogo(),
                        ),
                        const SizedBox(height: 12),
                        _AuthButton(
                          label: l10n.signUp,
                          filled: false,
                          onTap: auth.signInWithGoogle,
                          icon: const _GoogleLogo(),
                        ),
                      ],
                    ),
            ),

            // ── Terms ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Builder(builder: (ctx) {
                final termsRec = TapGestureRecognizer()
                  ..onTap = () => Navigator.push(ctx,
                      MaterialPageRoute(builder: (_) => const TermsScreen()));
                final privacyRec = TapGestureRecognizer()
                  ..onTap = () => Navigator.push(ctx,
                      MaterialPageRoute(builder: (_) => const PrivacyScreen()));
                return Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: l10n.termsOfService,
                      recognizer: termsRec,
                      style: const TextStyle(
                        color: AppColors.accent2,
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.accent2,
                      ),
                    ),
                    const TextSpan(
                      text: '  |  ',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    TextSpan(
                      text: l10n.privacyPolicy,
                      recognizer: privacyRec,
                      style: const TextStyle(
                        color: AppColors.accent2,
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.accent2,
                      ),
                    ),
                  ]),
                  textAlign: TextAlign.center,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Пузырь от приложения (тёмный, слева) ──────────────────────────────────
class _BubbleApp extends StatelessWidget {
  final String text;
  const _BubbleApp({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Аватар кота
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset('assets/img/icon.png', fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Center(child: Text('🐱', style: TextStyle(fontSize: 18))),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}

// ── Пузырь от пользователя (светлый, справа) ──────────────────────────────
class _BubbleUser extends StatelessWidget {
  final String text;
  const _BubbleUser({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 40),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.divider, width: 1.5),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Кнопка авторизации ────────────────────────────────────────────────────
class _AuthButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;
  final Widget icon;

  const _AuthButton({
    required this.label,
    required this.filled,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: filled ? AppColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: filled
              ? null
              : Border.all(color: AppColors.textPrimary, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Google логотип ────────────────────────────────────────────────────────
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20, height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -1.5708, 1.5708, true, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.1416, 1.5708, true, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -3.1416, 1.5708, true, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0, 1.5708, true, paint);

    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.58, paint);
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(cx, cy - r * 0.22, r * 0.95, r * 0.44), paint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.48, paint);
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter old) => false;
}

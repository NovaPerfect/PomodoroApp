import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isRu ? 'Условия использования' : 'Terms of Service'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: isRu ? const _TermsRu() : const _TermsEn(),
      ),
    );
  }
}

// ─── Russian ──────────────────────────────────────────────────────────────────

class _TermsRu extends StatelessWidget {
  const _TermsRu();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Updated('Последнее обновление: апрель 2026 г.'),
        SizedBox(height: 20),
        _Section('1. Принятие условий', '''
Используя приложение Nekodoro («Приложение»), вы соглашаетесь с настоящими Условиями использования. Если вы не согласны с какими-либо пунктами, пожалуйста, не используйте Приложение.'''),
        _Section('2. Описание сервиса', '''
Nekodoro — приложение для повышения продуктивности, включающее:
• Таймер Помодоро
• Список задач (To-Do)
• Личный дневник
• Музыкальный плеер
• Статистику и трекер привычек

Некоторые функции доступны только авторизованным пользователям.'''),
        _Section('3. Аккаунт и авторизация', '''
Для использования Приложения вы входите через аккаунт Google. Вы несёте ответственность за сохранность доступа к своему аккаунту. Мы оставляем за собой право заблокировать аккаунт при нарушении настоящих Условий.'''),
        _Section('4. Пользовательский контент', '''
Вы сохраняете права на контент, который создаёте в Приложении (задачи, записи дневника и т.д.). Предоставляя нам доступ к этому контенту, вы даёте нам право хранить и отображать его в рамках функционирования Приложения.

Запрещается размещать контент, нарушающий законы или права третьих лиц.'''),
        _Section('5. Ограничение ответственности', '''
Приложение предоставляется «как есть» без каких-либо гарантий. Мы не несём ответственности за:
• Потерю данных в результате технических сбоев
• Перебои в работе сервиса
• Ущерб, возникший в результате использования Приложения

Рекомендуем периодически делать резервные копии важных данных.'''),
        _Section('6. Изменение сервиса', '''
Мы оставляем за собой право в любое время изменять, приостанавливать или прекращать работу Приложения (полностью или частично) без предварительного уведомления. Мы также можем обновлять настоящие Условия — актуальная версия всегда доступна в Приложении.'''),
        _Section('7. Премиум-подписка', '''
Некоторые функции Приложения могут быть доступны по платной подписке. Условия оплаты, возврата и отмены регулируются правилами платформы Google Play. Мы не обрабатываем платёжные данные напрямую.'''),
        _Section('8. Интеллектуальная собственность', '''
Все материалы Приложения (дизайн, логотипы, код) являются собственностью разработчика и защищены авторским правом. Вы не вправе копировать, модифицировать или распространять их без письменного разрешения.'''),
        _Section('9. Применимое право', '''
Настоящие Условия регулируются действующим законодательством. Споры разрешаются в установленном законом порядке.'''),
        _Section('10. Контакт', '''
По вопросам, связанным с Условиями использования, обращайтесь:
support@nekodoro.app'''),
      ],
    );
  }
}

// ─── English ──────────────────────────────────────────────────────────────────

class _TermsEn extends StatelessWidget {
  const _TermsEn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Updated('Last updated: April 2026'),
        SizedBox(height: 20),
        _Section('1. Acceptance of Terms', '''
By using the Nekodoro app ("App"), you agree to these Terms of Service. If you disagree with any part of these terms, please do not use the App.'''),
        _Section('2. Description of Service', '''
Nekodoro is a productivity app that includes:
• Pomodoro Timer
• To-Do List
• Personal Diary
• Music Player
• Stats and Habit Tracker

Some features are available to signed-in users only.'''),
        _Section('3. Account & Authentication', '''
To use the App you sign in with a Google account. You are responsible for keeping your account access secure. We reserve the right to suspend an account that violates these Terms.'''),
        _Section('4. User Content', '''
You retain ownership of the content you create in the App (tasks, diary entries, etc.). By giving us access to that content, you grant us the right to store and display it as part of the App's operation.

You may not post content that violates laws or third-party rights.'''),
        _Section('5. Limitation of Liability', '''
The App is provided "as is" without any warranties. We are not liable for:
• Data loss due to technical failures
• Service interruptions
• Any damage arising from use of the App

We recommend backing up important data periodically.'''),
        _Section('6. Changes to the Service', '''
We reserve the right to modify, suspend, or discontinue the App (in whole or in part) at any time without prior notice. We may also update these Terms — the current version is always available in the App.'''),
        _Section('7. Premium Subscription', '''
Some features may be available through a paid subscription. Payment, refund, and cancellation terms are governed by Google Play policies. We do not process payment data directly.'''),
        _Section('8. Intellectual Property', '''
All App materials (design, logos, code) are the property of the developer and are protected by copyright. You may not copy, modify, or distribute them without written permission.'''),
        _Section('9. Governing Law', '''
These Terms are governed by applicable law. Disputes shall be resolved in accordance with the procedures established by law.'''),
        _Section('10. Contact', '''
For questions related to these Terms, contact us at:
support@nekodoro.app'''),
      ],
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.6,
              )),
        ],
      ),
    );
  }
}

class _Updated extends StatelessWidget {
  final String text;
  const _Updated(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ));
  }
}

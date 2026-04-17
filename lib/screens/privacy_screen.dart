import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isRu ? 'Политика конфиденциальности' : 'Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: isRu ? const _PrivacyRu() : const _PrivacyEn(),
      ),
    );
  }
}

// ─── Russian ──────────────────────────────────────────────────────────────────

class _PrivacyRu extends StatelessWidget {
  const _PrivacyRu();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Updated('Последнее обновление: апрель 2026 г.'),
        SizedBox(height: 20),
        _Intro('''
Nekodoro («мы», «нас») уважает вашу конфиденциальность. Настоящая Политика объясняет, какие данные мы собираем, как их используем и как вы можете ими управлять.'''),
        _Section('1. Какие данные мы собираем', '''
При входе через Google мы получаем:
• Имя и фамилию
• Адрес электронной почты
• Фотографию профиля (если есть)
• Уникальный идентификатор Google-аккаунта

В процессе использования Приложения мы храним:
• Задачи (To-Do) и их статус
• Записи личного дневника
• Статистику сессий таймера
• Привычки и журнал их выполнения
• Настройки приложения (язык, тема и т.д.)'''),
        _Section('2. Как мы используем данные', '''
Данные используются исключительно для:
• Идентификации вашего аккаунта
• Синхронизации ваших данных между устройствами
• Корректной работы всех функций Приложения
• Улучшения качества сервиса (в агрегированном виде)

Мы НЕ продаём ваши данные третьим лицам.
Мы НЕ используем данные для рекламы.'''),
        _Section('3. Хранение данных', '''
Все пользовательские данные хранятся в сервисах Google:

Firebase Authentication — авторизация
Cloud Firestore — пользовательский контент

Google обрабатывает данные в соответствии с собственной Политикой конфиденциальности:
policies.google.com/privacy

Данные могут храниться на серверах в разных странах. Firebase соответствует требованиям GDPR.'''),
        _Section('4. Безопасность', '''
Мы применяем стандартные меры безопасности:
• Все данные передаются по зашифрованному соединению (HTTPS/TLS)
• Доступ к данным ограничен правилами безопасности Firestore
• Каждый пользователь видит только свои данные

Несмотря на это, ни одна система не может гарантировать 100% защиту. Используйте надёжный пароль Google-аккаунта.'''),
        _Section('5. Данные детей', '''
Приложение не предназначено для детей младше 13 лет. Мы намеренно не собираем данные лиц младше этого возраста. Если вам стало известно, что ребёнок предоставил нам свои данные — свяжитесь с нами для их удаления.'''),
        _Section('6. Ваши права', '''
Вы имеете право:
• Получить копию своих данных
• Исправить неточные данные
• Удалить свой аккаунт и все связанные данные
• Отозвать разрешения Google (через настройки аккаунта Google)

Для удаления аккаунта: Настройки → Аккаунт → Удалить аккаунт
Или напишите нам на support@nekodoro.app'''),
        _Section('7. Сторонние сервисы', '''
Приложение использует следующие сторонние сервисы со своими политиками конфиденциальности:

• Google Sign-In — google.com/policies/privacy
• Firebase (Google) — firebase.google.com/support/privacy
• Google Play (для платежей) — play.google.com/about/privacy'''),
        _Section('8. Изменения политики', '''
Мы можем обновлять настоящую Политику. При существенных изменениях вы будете уведомлены через Приложение. Актуальная версия всегда доступна в разделе настроек.'''),
        _Section('9. Контакт', '''
По вопросам конфиденциальности обращайтесь:
support@nekodoro.app

Мы ответим в течение 30 рабочих дней.'''),
      ],
    );
  }
}

// ─── English ──────────────────────────────────────────────────────────────────

class _PrivacyEn extends StatelessWidget {
  const _PrivacyEn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Updated('Last updated: April 2026'),
        SizedBox(height: 20),
        _Intro('''
Nekodoro ("we", "us") respects your privacy. This Policy explains what data we collect, how we use it, and how you can manage it.'''),
        _Section('1. Data We Collect', '''
When you sign in with Google, we receive:
• First and last name
• Email address
• Profile photo (if available)
• Unique Google account identifier

During use of the App, we store:
• Tasks (To-Do) and their status
• Personal diary entries
• Timer session statistics
• Habits and their completion history
• App settings (language, theme, etc.)'''),
        _Section('2. How We Use Your Data', '''
Data is used exclusively to:
• Identify your account
• Sync your data across devices
• Ensure all App features work correctly
• Improve service quality (in aggregated form)

We do NOT sell your data to third parties.
We do NOT use your data for advertising.'''),
        _Section('3. Data Storage', '''
All user data is stored in Google services:

Firebase Authentication — authentication
Cloud Firestore — user content

Google processes data in accordance with its own Privacy Policy:
policies.google.com/privacy

Data may be stored on servers in different countries. Firebase is GDPR compliant.'''),
        _Section('4. Security', '''
We apply standard security measures:
• All data is transmitted over an encrypted connection (HTTPS/TLS)
• Data access is restricted by Firestore security rules
• Each user sees only their own data

That said, no system can guarantee 100% protection. Use a strong Google account password.'''),
        _Section('5. Children\'s Data', '''
The App is not intended for children under 13. We do not knowingly collect data from anyone under that age. If you believe a child has provided us with their data, please contact us for deletion.'''),
        _Section('6. Your Rights', '''
You have the right to:
• Obtain a copy of your data
• Correct inaccurate data
• Delete your account and all associated data
• Revoke Google permissions (via Google account settings)

To delete your account: Settings → Account → Delete Account
Or email us at support@nekodoro.app'''),
        _Section('7. Third-Party Services', '''
The App uses the following third-party services with their own privacy policies:

• Google Sign-In — google.com/policies/privacy
• Firebase (Google) — firebase.google.com/support/privacy
• Google Play (for payments) — play.google.com/about/privacy'''),
        _Section('8. Policy Changes', '''
We may update this Policy. For significant changes, you will be notified through the App. The current version is always available in the settings section.'''),
        _Section('9. Contact', '''
For privacy-related questions, contact us at:
support@nekodoro.app

We will respond within 30 business days.'''),
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

class _Intro extends StatelessWidget {
  final String text;
  const _Intro(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            height: 1.6,
          )),
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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('sk'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'StudyFlow'**
  String get appName;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @diary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diary;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @workTimer.
  ///
  /// In en, this message translates to:
  /// **'Work-Timer'**
  String get workTimer;

  /// No description provided for @breakTimer.
  ///
  /// In en, this message translates to:
  /// **'Break-Timer'**
  String get breakTimer;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @newDiaryEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newDiaryEntry;

  /// No description provided for @editDiaryEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get editDiaryEntry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get confirmDelete;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasks;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @newTask.
  ///
  /// In en, this message translates to:
  /// **'New Task'**
  String get newTask;

  /// No description provided for @taskTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What needs to be done?'**
  String get taskTitleHint;

  /// No description provided for @moodQuestion.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get moodQuestion;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get untitled;

  /// No description provided for @noContent.
  ///
  /// In en, this message translates to:
  /// **'No text...'**
  String get noContent;

  /// No description provided for @focusTime.
  ///
  /// In en, this message translates to:
  /// **'Focus Time'**
  String get focusTime;

  /// No description provided for @completedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get completedTasks;

  /// No description provided for @diaryEntries.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diaryEntries;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @tasksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get things done today ✨'**
  String get tasksSubtitle;

  /// No description provided for @diarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record your thoughts and feelings 🌸'**
  String get diarySubtitle;

  /// No description provided for @musicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your mood 🎧'**
  String get musicSubtitle;

  /// No description provided for @statsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your progress 📈'**
  String get statsSubtitle;

  /// No description provided for @noDiaryEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet\nTap + to write'**
  String get noDiaryEntries;

  /// No description provided for @diaryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Record your day...'**
  String get diaryPlaceholder;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @noTasksShort.
  ///
  /// In en, this message translates to:
  /// **'No tasks'**
  String get noTasksShort;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @sec.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get sec;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hour;

  /// No description provided for @pomodoro.
  ///
  /// In en, this message translates to:
  /// **'pomodoro'**
  String get pomodoro;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @loginBubble1.
  ///
  /// In en, this message translates to:
  /// **'Time to focus! 🍅\nStarting Pomodoro...'**
  String get loginBubble1;

  /// No description provided for @loginBubble2.
  ///
  /// In en, this message translates to:
  /// **'I can\'t, I\'m so distracted 😩'**
  String get loginBubble2;

  /// No description provided for @loginBubble3.
  ///
  /// In en, this message translates to:
  /// **'Just 25 minutes of focus.\nYou can do it! I\'ll be here 🐱'**
  String get loginBubble3;

  /// No description provided for @loginBubble4.
  ///
  /// In en, this message translates to:
  /// **'Okay, let\'s try'**
  String get loginBubble4;

  /// No description provided for @loginBubble5.
  ///
  /// In en, this message translates to:
  /// **'Great! Put down your phone\nand open your textbook. Let\'s go! ✨'**
  String get loginBubble5;

  /// No description provided for @pomodoroSection.
  ///
  /// In en, this message translates to:
  /// **'Pomodoro'**
  String get pomodoroSection;

  /// No description provided for @volumeSection.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volumeSection;

  /// No description provided for @playerVolume.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get playerVolume;

  /// No description provided for @systemVolume.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemVolume;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @moodTerrible.
  ///
  /// In en, this message translates to:
  /// **'Terrible'**
  String get moodTerrible;

  /// No description provided for @moodBad.
  ///
  /// In en, this message translates to:
  /// **'Bad'**
  String get moodBad;

  /// No description provided for @moodOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get moodOkay;

  /// No description provided for @moodGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get moodGood;

  /// No description provided for @moodGreat.
  ///
  /// In en, this message translates to:
  /// **'Great'**
  String get moodGreat;

  /// No description provided for @habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// No description provided for @newHabit.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get newHabit;

  /// No description provided for @habitNameHint.
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get habitNameHint;

  /// No description provided for @habitIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get habitIcon;

  /// No description provided for @habitColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get habitColor;

  /// No description provided for @habitType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get habitType;

  /// No description provided for @habitWeekDays.
  ///
  /// In en, this message translates to:
  /// **'Days of week'**
  String get habitWeekDays;

  /// No description provided for @habitGoalPerDay.
  ///
  /// In en, this message translates to:
  /// **'Goal per day'**
  String get habitGoalPerDay;

  /// No description provided for @last5Weeks.
  ///
  /// In en, this message translates to:
  /// **'Last 5 weeks'**
  String get last5Weeks;

  /// No description provided for @addFirstHabit.
  ///
  /// In en, this message translates to:
  /// **'Add your first habit'**
  String get addFirstHabit;

  /// No description provided for @habitTypeDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get habitTypeDaily;

  /// No description provided for @habitTypeWeekly.
  ///
  /// In en, this message translates to:
  /// **'By days'**
  String get habitTypeWeekly;

  /// No description provided for @habitTypeCounter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get habitTypeCounter;

  /// No description provided for @habitGoalHint.
  ///
  /// In en, this message translates to:
  /// **'E.g.: 8 (glasses of water)'**
  String get habitGoalHint;

  /// No description provided for @premiumUnlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features\nfor productive learning'**
  String get premiumUnlockSubtitle;

  /// No description provided for @habitTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit Tracker'**
  String get habitTrackerTitle;

  /// No description provided for @habitTrackerPaywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily, weekly, counters'**
  String get habitTrackerPaywallSubtitle;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achievementsPaywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Earn points and unlock customization'**
  String get achievementsPaywallSubtitle;

  /// No description provided for @extendedStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Extended Statistics'**
  String get extendedStatsTitle;

  /// No description provided for @extendedStatsPaywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Charts, trends and detailed analytics'**
  String get extendedStatsPaywallSubtitle;

  /// No description provided for @tryPremium.
  ///
  /// In en, this message translates to:
  /// **'Try Premium'**
  String get tryPremium;

  /// No description provided for @testAccessFree.
  ///
  /// In en, this message translates to:
  /// **'Test access — free'**
  String get testAccessFree;

  /// No description provided for @premiumExclusiveFeatures.
  ///
  /// In en, this message translates to:
  /// **'Your exclusive features'**
  String get premiumExclusiveFeatures;

  /// No description provided for @habitTrackerPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Daily goals and streak'**
  String get habitTrackerPremiumSubtitle;

  /// No description provided for @achievementsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon — earn points and unlock customization'**
  String get achievementsComingSoon;

  /// No description provided for @extendedStatsPremiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly results · Records · Trends'**
  String get extendedStatsPremiumSubtitle;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @revokePremiumTest.
  ///
  /// In en, this message translates to:
  /// **'Revoke Premium (test)'**
  String get revokePremiumTest;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get lastWeek;

  /// No description provided for @focusStat.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusStat;

  /// No description provided for @completionRateStat.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get completionRateStat;

  /// No description provided for @activeDaysStat.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDaysStat;

  /// No description provided for @personalRecords.
  ///
  /// In en, this message translates to:
  /// **'Personal records'**
  String get personalRecords;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bestStreak;

  /// No description provided for @bestDayRecord.
  ///
  /// In en, this message translates to:
  /// **'Best day'**
  String get bestDayRecord;

  /// No description provided for @maxTasksDay.
  ///
  /// In en, this message translates to:
  /// **'Max tasks per day'**
  String get maxTasksDay;

  /// No description provided for @totalEntries.
  ///
  /// In en, this message translates to:
  /// **'Total entries'**
  String get totalEntries;

  /// No description provided for @noTasksForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasksForPeriod;

  /// No description provided for @noEntriesForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntriesForPeriod;

  /// No description provided for @startTimerHint.
  ///
  /// In en, this message translates to:
  /// **'Start the timer'**
  String get startTimerHint;

  /// No description provided for @zeroMin.
  ///
  /// In en, this message translates to:
  /// **'0 min'**
  String get zeroMin;

  /// No description provided for @activeDaysOf.
  ///
  /// In en, this message translates to:
  /// **'{count} of 7'**
  String activeDaysOf(int count);

  /// No description provided for @streakDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} d.'**
  String streakDaysLabel(int count);

  /// No description provided for @vsPrevWeek.
  ///
  /// In en, this message translates to:
  /// **'{delta} vs last week'**
  String vsPrevWeek(String delta);

  /// No description provided for @sessionsCompletedDetail.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} sessions completed'**
  String sessionsCompletedDetail(int done, int total);

  /// No description provided for @bestDayDetail.
  ///
  /// In en, this message translates to:
  /// **'Best day: {day} ({count})'**
  String bestDayDetail(String day, int count);

  /// No description provided for @moodAverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Mood: {mood}'**
  String moodAverageLabel(String mood);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'sk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

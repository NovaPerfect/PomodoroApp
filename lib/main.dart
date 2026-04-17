import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/audio_service.dart';
import 'services/audio_handler.dart';
import 'package:audio_service/audio_service.dart' as svc;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav.dart';
import 'services/timer_service.dart';
import 'services/locale_service.dart';
import 'services/premium_service.dart';
import 'package:untitled/l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localeService = LocaleService();
  await localeService.init();

  final timerService = TimerService();
  await timerService.init();

  // Запрашиваем разрешение на уведомления (Android 13+)
  await Permission.notification.request();

  // Создаём каналы уведомлений заранее (нужно для Android 8+).
  final FlutterLocalNotificationsPlugin localNotif =
      FlutterLocalNotificationsPlugin();
  await localNotif.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );
  final androidPlugin = localNotif
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  // Канал для системного обратного отсчёта (без звука, ОС управляет хронометром)
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'pomodoro_countdown',
      'Pomodoro Countdown',
      description: 'Live timer countdown',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    ),
  );
  // Канал для звукового сигнала окончания сессии
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'pomodoro_alert',
      'Pomodoro Alerts',
      description: 'Plays when a Pomodoro session ends',
      importance: Importance.high,
    ),
  );

  // Initialize flutter_foreground_task (idempotent).
  FlutterForegroundTask.initCommunicationPort();
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      // Новый channelId — Android не понижает importance у существующих каналов,
      // поэтому нужен новый. MIN = иконка в статус-баре, шторка не засоряется.
      channelId: 'pomodoro_timer_bg',
      channelName: 'Pomodoro Timer (background)',
      channelDescription: 'Silent keep-alive for the timer foreground service',
      channelImportance: NotificationChannelImportance.MIN,
      priority: NotificationPriority.MIN,
      enableVibration: false,
      playSound: false,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(1000),
      autoRunOnBoot: false,
      allowWakeLock: true,
      allowWifiLock: false,
    ),
  );

  // 1. Initialize the background audio handler first
  StudyFlowAudioHandler? handler;
  try {
    handler = await svc.AudioService.init<StudyFlowAudioHandler>(
      builder: () => StudyFlowAudioHandler(),
      config: const svc.AudioServiceConfig(
        androidNotificationChannelId: 'com.novaperfect.nekodoro.audio',
        androidNotificationChannelName: 'Nekodoro Music',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidShowNotificationBadge: true,
      ),
    );
  } catch (e) {
    debugPrint('svc.AudioService.init failed: $e');
  }

  // 2. Set the handler in our service
  final audioService = AudioService();
  if (handler != null) {
    audioService.setHandler(handler);
  } else {
    // Fallback if init failed
    audioService.setHandler(StudyFlowAudioHandler());
  }

  final premiumService = PremiumService();
  await premiumService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeService),
        ChangeNotifierProvider.value(value: timerService),
        ChangeNotifierProvider.value(value: AuthService()),
        ChangeNotifierProvider.value(value: premiumService),
        ChangeNotifierProvider.value(value: audioService),
      ],
      child: const MyApp(),
    ),
  );
}

class _AuthGate extends StatefulWidget {
  final bool isLoggedIn;
  const _AuthGate({required this.isLoggedIn});

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    _syncLocale(widget.isLoggedIn);
  }

  @override
  void didUpdateWidget(_AuthGate old) {
    super.didUpdateWidget(old);
    if (old.isLoggedIn != widget.isLoggedIn) {
      _syncLocale(widget.isLoggedIn);
    }
  }

  void _syncLocale(bool loggedIn) {
    final locale = context.read<LocaleService>();
    if (loggedIn) {
      locale.loadSavedLocale();
    } else {
      locale.resetToSystemLocale();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoggedIn ? const MainNavigation() : const LoginScreen();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = Provider.of<LocaleService>(context);

    return MaterialApp(
      title: 'StudyFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: localeService.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('sk'),
      ],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return _AuthGate(isLoggedIn: snapshot.hasData);
        },
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/audio_service.dart';
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

  AudioService().init();

  final premiumService = PremiumService();
  await premiumService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeService),
        ChangeNotifierProvider.value(value: timerService),
        ChangeNotifierProvider.value(value: AuthService()),
        ChangeNotifierProvider.value(value: premiumService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = Provider.of<LocaleService>(context);

    return MaterialApp(
      title: 'StudyFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
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
          if (snapshot.hasData) {
            return const MainNavigation();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grand_dojo/core/l10n/generated/app_localizations.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/app_state_provider.dart';
import 'delivery/screens/splash/splash_screen.dart';
import 'delivery/screens/auth/login_screen.dart';
import 'delivery/screens/onboarding/onboarding_flow.dart';
import 'delivery/screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(const ProviderScope(child: GrandDojoApp()));
}

class GrandDojoApp extends ConsumerWidget {
  const GrandDojoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Grand Dojo',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      home: const _AppRouter(),
    );
  }
}

class _AppRouter extends ConsumerWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);

    switch (appState.route) {
      case AppRoute.loading:
        return const SplashScreen();
      case AppRoute.login:
        return const LoginScreen();
      case AppRoute.onboarding:
        return const OnboardingFlow();
      case AppRoute.dashboard:
        return const DashboardScreen();
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:salonverse/theme/app_theme.dart';
import 'package:salonverse/routes/app_router.dart';
import 'package:salonverse/utils/app_services.dart';
import 'package:salonverse/controllers/settings_provider.dart';
import 'package:salonverse/controllers/auth_provider.dart';
import 'package:salonverse/controllers/salon_provider.dart';
import 'package:salonverse/controllers/booking_provider.dart';
import 'package:salonverse/controllers/salon_workspace_provider.dart';
import 'package:salonverse/widgets/offline_banner.dart';

import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter framework error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
    }
  };

  // Global async error handling
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('[AsyncError] $error\n$stack');
    }
    return true;
  };

  try {
    await AppServices.init();
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('[AppServices] Init error: $e\n$stack');
    }
  }

  // Pre-resolve auto-login so the router has the correct initial auth state.
  final authProvider = AuthProvider();
  try {
    await authProvider.tryAutoLogin();
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('[AuthProvider] Auto-login error: $e\n$stack');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => SalonProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => SalonWorkspaceProvider()),
      ],
      child: const SalonVerseApp(),
    ),
  );
}

class SalonVerseApp extends StatelessWidget {
  const SalonVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDarkMode = settings.isDarkMode;
    final accent = settings.accentColor;

    return MaterialApp.router(
      title: 'SalonVerse',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppThemeBuilder.buildTheme(Brightness.light, accent: accent),
      darkTheme: AppThemeBuilder.buildTheme(Brightness.dark, accent: accent),
      routerConfig: appRouter,
      builder: (context, child) {
        return Column(
          children: [
            const OfflineBanner(),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
    );
  }
}

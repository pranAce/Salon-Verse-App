import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:salonverse/app/theme/app_theme.dart';
import 'package:salonverse/app/routes/app_router.dart';
import 'package:salonverse/core/storage/app_storage.dart';
import 'package:salonverse/features/home/services/settings_provider.dart';
import 'package:salonverse/features/auth/services/auth_provider.dart';
import 'package:salonverse/features/salons/services/salon_provider.dart';
import 'package:salonverse/features/booking/services/booking_provider.dart';
import 'package:salonverse/features/loyalty/services/loyalty_provider.dart';
import 'package:salonverse/core/widgets/offline_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    return true;
  };

  try {
    await AppStorage.init();
  } catch (_) {}

  final authProvider = AuthProvider();
  try {
    await authProvider.tryAutoLogin();
  } catch (_) {}

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => SalonProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => LoyaltyProvider()),
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

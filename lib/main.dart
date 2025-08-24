import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:raha/screens/transport_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart' as theme_provider;
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

import 'screens/accommodations_screen.dart';
import 'providers/user_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initial system UI overlay style - will be updated by theme provider
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => theme_provider.ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<theme_provider.ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'راحتي للرعاية الصحية',
            debugShowCheckedModeBanner: false,

            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _getFlutterThemeMode(themeProvider.themeMode),

            // Localization settings
            locale: const Locale('ar', 'DZ'), // Arabic (Algeria)
            supportedLocales: const [
              Locale('ar', 'DZ'), // Arabic (Algeria)
              Locale('en', 'US'), // English
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // RTL support with theme sync check
            builder: (context, child) {
              // Periodically check system theme sync (only when in system mode)
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (themeProvider.themeMode ==
                    theme_provider.ThemeMode.system) {
                  themeProvider.checkSystemTheme();
                }
              });

              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },

            home: const SplashScreen(),
            routes: {
              '/dashboard': (context) => const HomeScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/profile': (context) => const ProfileScreen(),

              '/accommodations': (context) => const AccommodationsScreen(),
              '/transport': (context) => const TransportScreen(),
            },
          );
        },
      ),
    );
  }

  // Convert our custom ThemeMode to Flutter's ThemeMode
  ThemeMode _getFlutterThemeMode(theme_provider.ThemeMode themeMode) {
    switch (themeMode) {
      case theme_provider.ThemeMode.light:
        return ThemeMode.light;
      case theme_provider.ThemeMode.dark:
        return ThemeMode.dark;
      case theme_provider.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}

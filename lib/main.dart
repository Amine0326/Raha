import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/medical_centers_screen.dart';
import 'screens/accommodations_screen.dart';
import 'screens/transport_screen.dart';
import 'screens/consultation_screen.dart';
import 'screens/medical_journey_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'راحتي للرعاية الصحية',
      debugShowCheckedModeBanner: false,

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

      // RTL support
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const SplashScreen(),
      routes: {
        '/dashboard': (context) => const MainNavigation(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/medical-centers': (context) => const MedicalCentersScreen(),
        '/accommodations': (context) => const AccommodationsScreen(),
        '/transport': (context) => const TransportScreen(),
        '/consultation': (context) => const ConsultationScreen(),
        '/medical-journey': (context) => const MedicalJourneyScreen(),
      },
    );
  }
}

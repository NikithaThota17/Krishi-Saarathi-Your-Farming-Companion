import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/crop_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/market_screen.dart';
import 'screens/schemes_screen.dart';
import 'screens/weather_screen.dart';
import 'services/app_settings_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppSettingsService.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettingsService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Krishi Saarathi',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: const LaunchGate(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/weather': (context) => const WeatherScreen(),
            '/crops': (context) => const CropScreen(),
            '/market': (context) => const MarketScreen(),
            '/schemes': (context) => const SchemesScreen(),
          },
        );
      },
    );
  }
}

class LaunchGate extends StatefulWidget {
  const LaunchGate({super.key});

  @override
  State<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<LaunchGate> {
  Future<bool> _shouldOpenHome() async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      return true;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _shouldOpenHome(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data! ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}

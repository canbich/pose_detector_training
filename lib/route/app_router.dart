import 'package:approx_pilates_demo/pages/exercise/exercise_screen.dart';
import 'package:approx_pilates_demo/pages/home/home_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  // 🔹 Route isimleri
  static const String home = '/home';
  static const String exercise = '/exercise';

  // 🔹 Route generator
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case exercise:
        return MaterialPageRoute(builder: (_) => const ExerciseScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('404 — Sayfa bulunamadı')),
          ),
        );
    }
  }
}

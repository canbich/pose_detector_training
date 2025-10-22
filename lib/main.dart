import 'package:approx_pilates_demo/route/app_router.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const PilatesApp());
}

class PilatesApp extends StatelessWidget {
  const PilatesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pilates App',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

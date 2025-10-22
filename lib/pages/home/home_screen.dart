import 'package:approx_pilates_demo/route/app_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.exercise);
          },
          child: Text('Exercise Screen'),
        ),
      ),
    );
  }
}

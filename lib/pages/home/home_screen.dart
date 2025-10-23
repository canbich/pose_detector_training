import 'package:approx_pilates_demo/pose_references/pose_reference.dart';
import 'package:approx_pilates_demo/route/app_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.exercise,
                  arguments: defaultPose,
                );
              },
              child: Text('Default Pose'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.exercise,
                  arguments: warriorPose,
                );
              },
              child: Text('Warrior Pose'),
            ),
          ],
        ),
      ),
    );
  }
}

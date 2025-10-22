import 'package:approx_pilates_demo/widgets/pose_detector_view.dart';
import 'package:flutter/material.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PoseDetectorView(), // sadece kamera + pose detection
    );
  }
}

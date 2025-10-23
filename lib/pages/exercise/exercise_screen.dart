import 'package:approx_pilates_demo/pose_references/pose_reference.dart';
import 'package:approx_pilates_demo/widgets/pose_detector_view.dart';
import 'package:flutter/material.dart';

class ExerciseScreen extends StatefulWidget {
  final PoseReference poseReference;

  const ExerciseScreen({super.key, required this.poseReference});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PoseDetectorView(
        poseReference: widget.poseReference, // kameraya bu bilgiyi aktaracağız
      ),
    );
  }
}

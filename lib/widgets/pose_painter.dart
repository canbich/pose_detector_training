import 'package:approx_pilates_demo/pose_references/pose_reference.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final defaultPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.green;

    for (final pose in poses) {
      void paintLineValidated(
        PoseLandmarkType type1,
        PoseLandmarkType type2,
        PoseLandmarkType type3,
        double referenceAngle,
      ) {
        final joint1 = pose.landmarks[type1]!;
        final joint2 = pose.landmarks[type2]!;
        final joint3 = pose.landmarks[type3]!;

        final angle = calculateAngle(
          Offset(joint1.x, joint1.y),
          Offset(joint2.x, joint2.y),
          Offset(joint3.x, joint3.y),
        );

        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = (angle - referenceAngle).abs() < 15
              ? Colors.green
              : Colors.red;

        canvas.drawLine(
          Offset(
            translateX(
              joint1.x,
              size,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              joint1.y,
              size,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
          ),
          Offset(
            translateX(
              joint2.x,
              size,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
            translateY(
              joint2.y,
              size,
              imageSize,
              rotation,
              cameraLensDirection,
            ),
          ),
          paint,
        );
      }

      // Sol kol
      paintLineValidated(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
        defaultPose.leftElbowAngle,
      );
      // Sağ kol
      paintLineValidated(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.rightWrist,
        defaultPose.rightElbowAngle,
      );
      // Sol bacak
      paintLineValidated(
        PoseLandmarkType.leftHip,
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.leftAnkle,
        defaultPose.leftKneeAngle,
      );
      // Sağ bacak
      paintLineValidated(
        PoseLandmarkType.rightHip,
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.rightAnkle,
        defaultPose.rightKneeAngle,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}

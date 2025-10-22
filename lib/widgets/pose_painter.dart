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
    for (final pose in poses) {
      // --- Yardımcı: üç nokta arasındaki açıyı hesaplayıp iki çizgiyi çizer ---
      void paintJointLines(
        PoseLandmarkType pointA,
        PoseLandmarkType pointB,
        PoseLandmarkType pointC,
        double targetAngle,
      ) {
        final a = pose.landmarks[pointA]!;
        final b = pose.landmarks[pointB]!;
        final c = pose.landmarks[pointC]!;

        final angle = calculateAngle(
          Offset(a.x, a.y),
          Offset(b.x, b.y),
          Offset(c.x, c.y),
        );

        final isValid = (angle - targetAngle).abs() < 15;

        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = isValid ? Colors.green : Colors.red;

        // Her zaman hem üst hem alt çizgi çizilir:
        final aOffset = Offset(
          translateX(a.x, size, imageSize, rotation, cameraLensDirection),
          translateY(a.y, size, imageSize, rotation, cameraLensDirection),
        );
        final bOffset = Offset(
          translateX(b.x, size, imageSize, rotation, cameraLensDirection),
          translateY(b.y, size, imageSize, rotation, cameraLensDirection),
        );
        final cOffset = Offset(
          translateX(c.x, size, imageSize, rotation, cameraLensDirection),
          translateY(c.y, size, imageSize, rotation, cameraLensDirection),
        );

        // 🔹 A-B (örneğin omuz–dirsek)
        canvas.drawLine(aOffset, bOffset, paint);
        // 🔹 B-C (örneğin dirsek–bilek)
        canvas.drawLine(bOffset, cOffset, paint);
      }

      // --- Kollar ---
      paintJointLines(
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
        defaultPose.leftElbowAngle,
      );

      paintJointLines(
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.rightWrist,
        defaultPose.rightElbowAngle,
      );

      // --- Bacaklar ---
      paintJointLines(
        PoseLandmarkType.leftHip,
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.leftAnkle,
        defaultPose.leftKneeAngle,
      );

      paintJointLines(
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

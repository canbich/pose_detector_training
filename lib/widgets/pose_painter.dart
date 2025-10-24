import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'ema.dart';
import 'coordinates_translator.dart';
import 'pose_validation_result.dart';

class FullBodyPosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final Map<String, EMA> _emaMap;
  final PoseValidationResult Function(Map<PoseLandmarkType, PoseLandmark>)
  validator;

  FullBodyPosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    this._emaMap,
    this.validator,
  );

  double _getEMA(PoseLandmarkType type, double coord, String axis) {
    final key = "${type.name}_$axis";
    if (!_emaMap.containsKey(key)) {
      _emaMap[key] = EMA(value: coord);
    }
    return _emaMap[key]!.update(coord);
  }

  Offset _getOffset(
    PoseLandmark landmark,
    Size size,
    String axis,
    PoseLandmarkType type,
  ) {
    final x = _getEMA(type, landmark.x, "x");
    final y = _getEMA(type, landmark.y, "y");
    return Offset(
      translateX(x, size, imageSize, rotation, cameraLensDirection),
      translateY(y, size, imageSize, rotation, cameraLensDirection),
    );
  }

  void _drawLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    canvas.drawLine(a, b, paint);
  }

  void _drawPoint(
    Canvas canvas,
    Offset point, {
    Color color = Colors.blue,
    double radius = 4,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawCircle(point, radius, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final pose in poses) {
      final lm = pose.landmarks;
      final result = validator(lm);

      final paintValid = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.green;
      final paintInvalid = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.red;
      final paintNeutral = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.grey;

      // --- Tüm landmarkları nokta olarak çiz ---
      for (final entry in lm.entries) {
        final offset = _getOffset(entry.value, size, "x", entry.key);
        _drawPoint(canvas, offset);
      }

      // --- Kollar ---
      final leftShoulder = _getOffset(
        lm[PoseLandmarkType.leftShoulder]!,
        size,
        "x",
        PoseLandmarkType.leftShoulder,
      );
      final leftElbow = _getOffset(
        lm[PoseLandmarkType.leftElbow]!,
        size,
        "x",
        PoseLandmarkType.leftElbow,
      );
      final leftWrist = _getOffset(
        lm[PoseLandmarkType.leftWrist]!,
        size,
        "x",
        PoseLandmarkType.leftWrist,
      );

      final rightShoulder = _getOffset(
        lm[PoseLandmarkType.rightShoulder]!,
        size,
        "x",
        PoseLandmarkType.rightShoulder,
      );
      final rightElbow = _getOffset(
        lm[PoseLandmarkType.rightElbow]!,
        size,
        "x",
        PoseLandmarkType.rightElbow,
      );
      final rightWrist = _getOffset(
        lm[PoseLandmarkType.rightWrist]!,
        size,
        "x",
        PoseLandmarkType.rightWrist,
      );

      _drawLine(
        canvas,
        leftShoulder,
        leftElbow,
        result.validRegions.contains(PoseRegion.leftArm)
            ? paintValid
            : paintInvalid,
      );
      _drawLine(
        canvas,
        leftElbow,
        leftWrist,
        result.validRegions.contains(PoseRegion.leftArm)
            ? paintValid
            : paintInvalid,
      );
      _drawLine(
        canvas,
        rightShoulder,
        rightElbow,
        result.validRegions.contains(PoseRegion.rightArm)
            ? paintValid
            : paintInvalid,
      );
      _drawLine(
        canvas,
        rightElbow,
        rightWrist,
        result.validRegions.contains(PoseRegion.rightArm)
            ? paintValid
            : paintInvalid,
      );

      // --- Gövde ---
      final leftHip = _getOffset(
        lm[PoseLandmarkType.leftHip]!,
        size,
        "x",
        PoseLandmarkType.leftHip,
      );
      final rightHip = _getOffset(
        lm[PoseLandmarkType.rightHip]!,
        size,
        "x",
        PoseLandmarkType.rightHip,
      );

      _drawLine(
        canvas,
        leftShoulder,
        rightShoulder,
        result.validRegions.contains(PoseRegion.torso)
            ? paintValid
            : paintInvalid,
      );
      _drawLine(
        canvas,
        leftShoulder,
        leftHip,
        result.validRegions.contains(PoseRegion.torso)
            ? paintValid
            : paintInvalid,
      );
      _drawLine(
        canvas,
        rightShoulder,
        rightHip,
        result.validRegions.contains(PoseRegion.torso)
            ? paintValid
            : paintInvalid,
      );
      _drawLine(
        canvas,
        leftHip,
        rightHip,
        result.validRegions.contains(PoseRegion.torso)
            ? paintValid
            : paintInvalid,
      );

      // --- Bacaklar ---
      final leftKnee = _getOffset(
        lm[PoseLandmarkType.leftKnee]!,
        size,
        "x",
        PoseLandmarkType.leftKnee,
      );
      final leftAnkle = _getOffset(
        lm[PoseLandmarkType.leftAnkle]!,
        size,
        "x",
        PoseLandmarkType.leftAnkle,
      );
      final rightKnee = _getOffset(
        lm[PoseLandmarkType.rightKnee]!,
        size,
        "x",
        PoseLandmarkType.rightKnee,
      );
      final rightAnkle = _getOffset(
        lm[PoseLandmarkType.rightAnkle]!,
        size,
        "x",
        PoseLandmarkType.rightAnkle,
      );

      _drawLine(
        canvas,
        leftHip,
        leftKnee,
        result.validRegions.contains(PoseRegion.leftLeg)
            ? paintValid
            : paintInvalid,
      );
      _drawLine(
        canvas,
        leftKnee,
        leftAnkle,
        result.validRegions.contains(PoseRegion.leftLeg)
            ? paintValid
            : paintInvalid,
      );
      _drawLine(
        canvas,
        rightHip,
        rightKnee,
        result.validRegions.contains(PoseRegion.rightLeg)
            ? paintValid
            : paintInvalid,
      );
      _drawLine(
        canvas,
        rightKnee,
        rightAnkle,
        result.validRegions.contains(PoseRegion.rightLeg)
            ? paintValid
            : paintInvalid,
      );

      // --- Eller (parmaklar) ---
      final handPairs = [
        [PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb],
        [PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndex],
        [PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinky],
        [PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb],
        [PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndex],
        [PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinky],
      ];
      for (var pair in handPairs) {
        final a = _getOffset(lm[pair[0]]!, size, "x", pair[0]);
        final b = _getOffset(lm[pair[1]]!, size, "x", pair[1]);
        _drawLine(canvas, a, b, paintNeutral);
      }

      // --- Ayaklar ---
      final footPairs = [
        [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel],
        [PoseLandmarkType.leftHeel, PoseLandmarkType.leftFootIndex],
        [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel],
        [PoseLandmarkType.rightHeel, PoseLandmarkType.rightFootIndex],
      ];
      for (var pair in footPairs) {
        final a = _getOffset(lm[pair[0]]!, size, "x", pair[0]);
        final b = _getOffset(lm[pair[1]]!, size, "x", pair[1]);
        _drawLine(canvas, a, b, paintNeutral);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FullBodyPosePainter oldDelegate) => true;
}

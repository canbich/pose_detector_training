import 'package:approx_pilates_demo/widgets/pose_validation_result.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'ema.dart';
import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  final Map<String, EMA> _emaMap;
  final PoseValidationResult Function(Map<PoseLandmarkType, PoseLandmark>)
  validator;

  PosePainter(
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

  void _paintJoint(
    Canvas canvas,
    Size size,
    PoseLandmarkType aType,
    PoseLandmarkType bType,
    PoseLandmarkType cType,
    Map<PoseLandmarkType, PoseLandmark> landmarks,
    bool isRegionValid,
  ) {
    final a = landmarks[aType]!;
    final b = landmarks[bType]!;
    final c = landmarks[cType]!;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = isRegionValid ? Colors.green : Colors.red;

    final aOffset = Offset(
      translateX(
        _getEMA(aType, a.x, "x"),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      ),
      translateY(
        _getEMA(aType, a.y, "y"),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      ),
    );
    final bOffset = Offset(
      translateX(
        _getEMA(bType, b.x, "x"),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      ),
      translateY(
        _getEMA(bType, b.y, "y"),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      ),
    );
    final cOffset = Offset(
      translateX(
        _getEMA(cType, c.x, "x"),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      ),
      translateY(
        _getEMA(cType, c.y, "y"),
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      ),
    );

    canvas.drawLine(aOffset, bOffset, paint);
    canvas.drawLine(bOffset, cOffset, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final pose in poses) {
      final landmarks = pose.landmarks;
      final result = validator(landmarks);

      _paintJoint(
        canvas,
        size,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
        landmarks,
        result.validRegions.contains(PoseRegion.leftArm),
      );

      _paintJoint(
        canvas,
        size,
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.rightWrist,
        landmarks,
        result.validRegions.contains(PoseRegion.rightArm),
      );

      _paintJoint(
        canvas,
        size,
        PoseLandmarkType.leftHip,
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.leftAnkle,
        landmarks,
        result.validRegions.contains(PoseRegion.leftLeg),
      );

      _paintJoint(
        canvas,
        size,
        PoseLandmarkType.rightHip,
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.rightAnkle,
        landmarks,
        result.validRegions.contains(PoseRegion.rightLeg),
      );
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) => true;
}

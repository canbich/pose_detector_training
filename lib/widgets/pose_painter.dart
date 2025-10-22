import 'package:approx_pilates_demo/pose_references/pose_reference.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'coordinates_translator.dart';

class EMA {
  //TODO: EMA kullanımı - Exponential Moving Average - Üstel hareket ortalaması

  // kameradan gelen her framedeki landmark koordinatları çok oynuyor
  // eğer her frame'i direkt çizersem çok titreme oluyor
  // çözüm: her landmark için ema uygulayıp küçük değişiklikler yapıyoruz

  double value;
  final double alpha;
  EMA({required this.value, this.alpha = 0.1});

  double update(double newValue) {
    value = alpha * newValue + (1 - alpha) * value;
    return value;
    // update(newValue)  yeni değer geldiğinde EMA’yı günceller ve yumuşatılmış sonucu döner
  }
}

class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
    this._emaMap,
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  /// key: landmark type + axis (x/y), value: EMA objesi
  final Map<String, EMA> _emaMap;

  double _getEMA(PoseLandmarkType type, double coord, String axis) {
    final key = "${type.name}_$axis";
    if (!_emaMap.containsKey(key)) {
      _emaMap[key] = EMA(value: coord);
    }
    return _emaMap[key]!.update(coord);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final pose in poses) {
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

        // EMA ile smooth hesap
        final aOffset = Offset(
          translateX(
            _getEMA(pointA, a.x, "x"),
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          ),

          //Landmark koordinatlarını alıyoruz (örneğin leftElbow.x)

          // _getEMA ile EMA’yı uygula  titremeyi azalt

          // Çizgiyi yumuşak koordinatla çiz
          translateY(
            _getEMA(pointA, a.y, "y"),
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          ),
        );
        final bOffset = Offset(
          translateX(
            _getEMA(pointB, b.x, "x"),
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          ),
          translateY(
            _getEMA(pointB, b.y, "y"),
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          ),
        );
        final cOffset = Offset(
          translateX(
            _getEMA(pointC, c.x, "x"),
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          ),
          translateY(
            _getEMA(pointC, c.y, "y"),
            size,
            imageSize,
            rotation,
            cameraLensDirection,
          ),
        );

        // Omuz–Dirsek
        canvas.drawLine(aOffset, bOffset, paint);
        // Dirsek–Bilek
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
  bool shouldRepaint(covariant PosePainter oldDelegate) => true;
}

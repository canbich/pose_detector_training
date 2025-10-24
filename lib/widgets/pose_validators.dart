import 'package:approx_pilates_demo/widgets/pose_validation_result.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'dart:math';
import 'package:flutter/material.dart';

double calculateAngle(Offset a, Offset b, Offset c) {
  final ab = Offset(a.dx - b.dx, a.dy - b.dy);
  final cb = Offset(c.dx - b.dx, c.dy - b.dy);

  final dot = ab.dx * cb.dx + ab.dy * cb.dy;
  final magAB = sqrt(ab.dx * ab.dx + ab.dy * ab.dy);
  final magCB = sqrt(cb.dx * cb.dx + cb.dy * cb.dy);

  final cosAngle = dot / (magAB * magCB);
  return acos(cosAngle.clamp(-1.0, 1.0)) * 180 / pi;
}

/// Bacağın gerçekten yana açık olup olmadığını kontrol eder.
/// threshold ne kadar küçükse o kadar hassas olur.
bool isLegOpenedSideways(
  PoseLandmark hip,
  PoseLandmark ankle, {
  double threshold = 80,
}) {
  final dx = ankle.x - hip.x;
  // sağa açılmışsa pozitif, sola açılmışsa negatif.
  return dx.abs() > threshold;
}

/// Warrior pose validator (hibrit versiyon)
PoseValidationResult warriorPoseValidator(
  Map<PoseLandmarkType, PoseLandmark> lm,
) {
  final validRegions = <PoseRegion>{};
  final feedback = <PoseRegion, String>{};

  // --- Kollar ---
  final leftShoulder = lm[PoseLandmarkType.leftShoulder]!;
  final leftElbow = lm[PoseLandmarkType.leftElbow]!;
  final leftWrist = lm[PoseLandmarkType.leftWrist]!;

  final rightShoulder = lm[PoseLandmarkType.rightShoulder]!;
  final rightElbow = lm[PoseLandmarkType.rightElbow]!;
  final rightWrist = lm[PoseLandmarkType.rightWrist]!;

  final leftElbowAngle = calculateAngle(
    Offset(leftShoulder.x, leftShoulder.y),
    Offset(leftElbow.x, leftElbow.y),
    Offset(leftWrist.x, leftWrist.y),
  );

  final rightElbowAngle = calculateAngle(
    Offset(rightShoulder.x, rightShoulder.y),
    Offset(rightElbow.x, rightElbow.y),
    Offset(rightWrist.x, rightWrist.y),
  );

  if ((leftElbowAngle - 180).abs() < 15 &&
      (leftShoulder.y - leftElbow.y).abs() < 30) {
    validRegions.add(PoseRegion.leftArm);
  } else {
    feedback[PoseRegion.leftArm] =
        "Left arm should be straight and horizontal.";
  }

  if ((rightElbowAngle - 180).abs() < 15 &&
      (rightShoulder.y - rightElbow.y).abs() < 30) {
    validRegions.add(PoseRegion.rightArm);
  } else {
    feedback[PoseRegion.rightArm] =
        "Right arm should be straight and horizontal.";
  }

  // --- Bacaklar ---
  final leftHip = lm[PoseLandmarkType.leftHip]!;
  final leftKnee = lm[PoseLandmarkType.leftKnee]!;
  final leftAnkle = lm[PoseLandmarkType.leftAnkle]!;

  final rightHip = lm[PoseLandmarkType.rightHip]!;
  final rightKnee = lm[PoseLandmarkType.rightKnee]!;
  final rightAnkle = lm[PoseLandmarkType.rightAnkle]!;

  final leftKneeAngle = calculateAngle(
    Offset(leftHip.x, leftHip.y),
    Offset(leftKnee.x, leftKnee.y),
    Offset(leftAnkle.x, leftAnkle.y),
  );

  final rightKneeAngle = calculateAngle(
    Offset(rightHip.x, rightHip.y),
    Offset(rightKnee.x, rightKnee.y),
    Offset(rightAnkle.x, rightAnkle.y),
  );

  final leftLegOpened = isLegOpenedSideways(leftHip, leftAnkle);
  final rightLegOpened = isLegOpenedSideways(rightHip, rightAnkle);

  // Sol bacak: yana açık + 90° civarı kırık
  if (leftLegOpened && (leftKneeAngle - 90).abs() < 15) {
    validRegions.add(PoseRegion.leftLeg);
  } else {
    feedback[PoseRegion.leftLeg] =
        "Left leg should be bent (~90°) and opened sideways.";
  }

  // Sağ bacak: yana açık + düz (~180°)
  if (rightLegOpened && (rightKneeAngle - 180).abs() < 15) {
    validRegions.add(PoseRegion.rightLeg);
  } else {
    feedback[PoseRegion.rightLeg] =
        "Right leg should be straight (~180°) and opened sideways.";
  }

  // --- Gövde hizası ---
  final torsoSlope =
      ((rightShoulder.y + leftShoulder.y) / 2) - ((rightHip.y + leftHip.y) / 2);
  if (torsoSlope.abs() < 50) {
    validRegions.add(PoseRegion.torso);
  } else {
    feedback[PoseRegion.torso] = "Torso should be more upright and aligned.";
  }

  // Gerekli bölgeler
  final requiredRegions = {
    PoseRegion.leftArm,
    PoseRegion.rightArm,
    PoseRegion.leftLeg,
    PoseRegion.rightLeg,
    PoseRegion.torso,
  };

  return PoseValidationResult.fromValidRegions(
    validRegions,
    requiredRegions: requiredRegions,
    feedback: feedback,
  );
}

PoseValidationResult defaultPoseValidator(
  Map<PoseLandmarkType, PoseLandmark> lm,
) {
  final validRegions = <PoseRegion>{};

  final leftElbow = calculateAngle(
    Offset(
      lm[PoseLandmarkType.leftShoulder]!.x,
      lm[PoseLandmarkType.leftShoulder]!.y,
    ),
    Offset(
      lm[PoseLandmarkType.leftElbow]!.x,
      lm[PoseLandmarkType.leftElbow]!.y,
    ),
    Offset(
      lm[PoseLandmarkType.leftWrist]!.x,
      lm[PoseLandmarkType.leftWrist]!.y,
    ),
  );
  if ((leftElbow - 160).abs() < 15) validRegions.add(PoseRegion.leftArm);

  final rightElbow = calculateAngle(
    Offset(
      lm[PoseLandmarkType.rightShoulder]!.x,
      lm[PoseLandmarkType.rightShoulder]!.y,
    ),
    Offset(
      lm[PoseLandmarkType.rightElbow]!.x,
      lm[PoseLandmarkType.rightElbow]!.y,
    ),
    Offset(
      lm[PoseLandmarkType.rightWrist]!.x,
      lm[PoseLandmarkType.rightWrist]!.y,
    ),
  );
  if ((rightElbow - 160).abs() < 15) validRegions.add(PoseRegion.rightArm);

  return PoseValidationResult.fromValidRegions(validRegions);
}

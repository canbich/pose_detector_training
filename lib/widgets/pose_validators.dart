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

  return PoseValidationResult(
    isValid: validRegions.isNotEmpty,
    validRegions: validRegions,
  );
}

PoseValidationResult warriorPoseValidator(
  Map<PoseLandmarkType, PoseLandmark> lm,
) {
  final validRegions = <PoseRegion>{};

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

  // Kol geçerliliği: dirsek açısı ve yataylık
  if ((leftElbowAngle - 180).abs() < 15 &&
      (leftShoulder.y - leftElbow.y).abs() < 30) {
    validRegions.add(PoseRegion.leftArm);
  }

  if ((rightElbowAngle - 180).abs() < 15 &&
      (rightShoulder.y - rightElbow.y).abs() < 30) {
    validRegions.add(PoseRegion.rightArm);
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

  if ((leftKneeAngle - 90).abs() < 15) validRegions.add(PoseRegion.leftLeg);
  if ((rightKneeAngle - 180).abs() < 15) validRegions.add(PoseRegion.rightLeg);

  return PoseValidationResult(
    isValid: validRegions.length == 4, // tüm bölgeler doğruysa geçerli
    validRegions: validRegions,
  );
}

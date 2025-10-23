class PoseReference {
  final double leftElbowAngle;
  final double rightElbowAngle;
  final double leftKneeAngle;
  final double rightKneeAngle;

  PoseReference({
    required this.leftElbowAngle,
    required this.rightElbowAngle,
    required this.leftKneeAngle,
    required this.rightKneeAngle,
  });
}

final defaultPose = PoseReference(
  leftElbowAngle: 160,
  rightElbowAngle: 160,
  leftKneeAngle: 180,
  rightKneeAngle: 180,
);

final warriorPose = PoseReference(
  leftElbowAngle: 180, // kollar düz
  rightElbowAngle: 180,
  leftKneeAngle: 90, // ön bacak
  rightKneeAngle: 175, // arka bacak
);

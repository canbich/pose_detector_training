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
  leftKneeAngle: 170,
  rightKneeAngle: 170,
);

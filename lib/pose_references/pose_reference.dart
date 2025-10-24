class PoseReference {
  final double leftElbowAngle;
  final double rightElbowAngle;
  final double leftKneeAngle;
  final double rightKneeAngle;
  final double torsoTilt; // Gövde yataylığı veya eğikliği
  final double shoulderTilt; // Omuz yataylığı

  PoseReference({
    required this.leftElbowAngle,
    required this.rightElbowAngle,
    required this.leftKneeAngle,
    required this.rightKneeAngle,
    this.torsoTilt = 0, // default 0 derece
    this.shoulderTilt = 0, // default 0 derece
  });
}

final warriorPose = PoseReference(
  leftElbowAngle: 180,
  rightElbowAngle: 180,
  leftKneeAngle: 90,
  rightKneeAngle: 175,
  torsoTilt: 15, // örnek: 15 derece yana eğik
  shoulderTilt: 5, // omuzlar neredeyse yatay
);

final defaultPose = PoseReference(
  leftElbowAngle: 160,
  rightElbowAngle: 160,
  leftKneeAngle: 180,
  rightKneeAngle: 180,
);

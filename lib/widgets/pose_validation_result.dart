enum PoseRegion { leftArm, rightArm, leftLeg, rightLeg }

class PoseValidationResult {
  final bool isValid; // tüm poz geçerli mi
  final Set<PoseRegion> validRegions; // hangi bölgeler doğru

  PoseValidationResult({required this.isValid, required this.validRegions});
}

// pose_validation_result.dart

enum PoseRegion { leftArm, rightArm, leftLeg, rightLeg, torso }

/// Sonuç modelimiz.
/// - `isValid` : tüm gerekli bölgeler doğruysa true (fabrika constructor'ından hesaplanırsa otomatik).
/// - `validRegions` : validator'ın "doğru" olarak işaretlediği bölgeler.
/// - `feedback` : her bölge için isteğe bağlı açıklayıcı mesaj (örn: "Bacağı daha çok kır").
class PoseValidationResult {
  final bool isValid;
  final Set<PoseRegion> validRegions;
  final Map<PoseRegion, String>? feedback;

  const PoseValidationResult({
    required this.isValid,
    required this.validRegions,
    this.feedback,
  });

  /// Kolay kullanım için: sadece doğru bölgeleri ver, gerekli bölgeleri belirt,
  /// isValid otomatik hesaplansın.
  /// Eğer `requiredRegions` verilmezse varsayılan olarak tüm PoseRegion'lar zorunlu kabul edilir.
  factory PoseValidationResult.fromValidRegions(
    Set<PoseRegion> validRegions, {
    Set<PoseRegion>? requiredRegions,
    Map<PoseRegion, String>? feedback,
  }) {
    final requiredSet = requiredRegions ?? PoseRegion.values.toSet();
    final allOk = requiredSet.every((r) => validRegions.contains(r));
    return PoseValidationResult(
      isValid: allOk,
      validRegions: validRegions,
      feedback: feedback,
    );
  }

  /// Bir bölgenin geçerli olup olmadığını hızlıca kontrol et.
  bool isRegionValid(PoseRegion region) => validRegions.contains(region);

  /// Belirli bir bölge için açıklama/feedback döner, yoksa boş string.
  String feedbackFor(PoseRegion region) =>
      feedback == null ? '' : (feedback![region] ?? '');

  /// Mevcut sonucu başka bir feedback map ile kopyalar (immutable yardımcı).
  PoseValidationResult copyWith({
    bool? isValid,
    Set<PoseRegion>? validRegions,
    Map<PoseRegion, String>? feedback,
  }) {
    return PoseValidationResult(
      isValid: isValid ?? this.isValid,
      validRegions: validRegions ?? this.validRegions,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  String toString() {
    return 'PoseValidationResult(isValid: $isValid, validRegions: $validRegions, feedback: $feedback)';
  }
}

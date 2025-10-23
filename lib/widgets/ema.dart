class EMA {
  double value;
  final double alpha;
  EMA({required this.value, this.alpha = 0.1});

  double update(double newValue) {
    value = alpha * newValue + (1 - alpha) * value;
    return value;
  }
}

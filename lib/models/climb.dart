class Climb {
  final double startKm;
  final double endKm;
  final double lengthKm;
  final double elevationGain;
  final double averageGradient;
  final double maxGradient;

  Climb({
    required this.startKm,
    required this.endKm,
    required this.lengthKm,
    required this.elevationGain,
    required this.averageGradient,
    required this.maxGradient,
  });

  String get gradientString => '${averageGradient.toStringAsFixed(1)}%';
  String get lengthString => '${lengthKm.toStringAsFixed(1)} km';
}

import 'dart:math';

/// Genera los coeficientes de aprendizaje de un estudiante.
/// Son fijos de por vida — deterministas por el ID del estudiante.
/// Rango: 0.5x (talento bajo) a 1.5x (talento alto) por stat.
class GenerateLearningCoefficients {

  static const List<String> stats = ['str', 'spd', 'tec', 'def', 'men'];

  /// Genera coeficientes deterministas basados en el ID del estudiante.
  Map<String, double> execute(String studentId) {
    // Seed basado en el hash del ID — mismo ID = mismos coeficientes siempre
    final seed = studentId.hashCode.abs();
    final rng  = Random(seed);

    return {
      for (final stat in stats)
        stat: _generateCoefficient(rng),
    };
  }

  double _generateCoefficient(Random rng) {
    // Distribución: mayoría entre 0.8-1.2, extremos raros
    // Usamos una distribución triangular aproximada
    final roll = rng.nextDouble();
    if (roll < 0.10) return 0.5 + rng.nextDouble() * 0.3;  // 10% talento bajo (0.5-0.8)
    if (roll < 0.80) return 0.8 + rng.nextDouble() * 0.4;  // 70% talento normal (0.8-1.2)
    return 1.2 + rng.nextDouble() * 0.3;                    // 20% talento alto (1.2-1.5)
  }

  /// Convierte un coeficiente a estrellas para la UI (1-5 estrellas).
  static int toStars(double coefficient) {
    if (coefficient >= 1.35) return 5;
    if (coefficient >= 1.15) return 4;
    if (coefficient >= 0.95) return 3;
    if (coefficient >= 0.75) return 2;
    return 1;
  }

  static String toLabel(double coefficient, dynamic loc) {
    if (coefficient >= 1.35) return loc.talentProdigy;
    if (coefficient >= 1.15) return loc.talentGifted;
    if (coefficient >= 0.95) return loc.talentNormal;
    if (coefficient >= 0.75) return loc.talentHardWorker;
    return loc.talentLimited;
  }
}
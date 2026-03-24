import 'package:equatable/equatable.dart';

/// Stats de combate de un estudiante.
/// Inmutable — para modificar, usar copyWith.
class StudentStats extends Equatable {
  final int str; // Fuerza
  final int spd; // Velocidad
  final int tec; // Técnica
  final int def; // Defensa
  final int men; // Mentalidad
  final int res; // Resistencia / Stamina base

  const StudentStats({
    required this.str,
    required this.spd,
    required this.tec,
    required this.def,
    required this.men,
    required this.res,
  });

  int get total => str + spd + tec + def + men;

  StudentStats copyWith({
    int? str, int? spd, int? tec,
    int? def, int? men, int? res,
  }) => StudentStats(
    str: str ?? this.str,
    spd: spd ?? this.spd,
    tec: tec ?? this.tec,
    def: def ?? this.def,
    men: men ?? this.men,
    res: res ?? this.res,
  );

  Map<String, int> toMap() => {
    'str': str, 'spd': spd, 'tec': tec,
    'def': def, 'men': men, 'res': res,
  };

  factory StudentStats.fromMap(Map<String, dynamic> map) => StudentStats(
    str: map['str'] ?? 10,
    spd: map['spd'] ?? 10,
    tec: map['tec'] ?? 10,
    def: map['def'] ?? 10,
    men: map['men'] ?? 10,
    res: map['res'] ?? 50,
  );

  @override
  List<Object?> get props => [str, spd, tec, def, men, res];
}

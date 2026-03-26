import 'package:equatable/equatable.dart';

import '../../value_objects/belt.dart';
import '../../value_objects/student_stats.dart';

class AIStudent extends Equatable {
  final String id;
  final String name;
  final StudentStats stats;
  final Belt belt;
  final String styleId;

  const AIStudent({
    required this.id,
    required this.name,
    required this.stats,
    required this.belt,
    required this.styleId,
  });

  @override
  List<Object?> get props => [id];
}
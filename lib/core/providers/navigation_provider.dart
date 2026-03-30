import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Permite que cualquier pantalla solicite un cambio de tab en el dashboard.
final navigationProvider = StateProvider<int>((ref) => 0);
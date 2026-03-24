import 'package:dartz/dartz.dart';
import '../../entities/student.dart';
import '../../entities/fight.dart';
import '../../../infrastructure/services/fight_simulation_service.dart';

class SimulateFightUseCase {
  final FightSimulationService _service;

  SimulateFightUseCase(this._service);

  Either<String, FightResult> execute({
    required Student blue,
    required Student red,
    required FightStrategy blueStrategy,
    required FightStrategy redStrategy,
    List<SliderValues>? blueSliders,
    List<SliderValues>? redSliders,
    int? seed,
  }) {
    try {
      final svc = seed != null ? FightSimulationService(seed: seed) : _service;
      final result = svc.simulate(
        blue: blue,
        red: red,
        blueStrategy: blueStrategy,
        redStrategy: redStrategy,
        blueRoundSliders: blueSliders,
        redRoundSliders: redSliders,
      );
      return Right(result);
    } catch (e) {
      return Left('fight_simulation_error: $e');
    }
  }
}

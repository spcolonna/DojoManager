import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/student.dart';
import '../../../domain/use_cases/training/simulate_week_use_case.dart';
import '../../../infrastructure/repositories/firebase_dojo_repository.dart';
import '../../../core/providers/dojo_provider.dart';
import '../../../core/config/training_activities_config.dart';

class TrainingState {
  /// studentId → lista de activityIds seleccionados
  final Map<String, List<String>> activitiesByStudentId;
  final bool isSimulating;
  final List<WeekSimulationResult>? results;
  final String? error;

  const TrainingState({
    this.activitiesByStudentId = const {},
    this.isSimulating = false,
    this.results,
    this.error,
  });

  List<String> activitiesFor(String studentId) =>
      activitiesByStudentId[studentId] ?? [];

  TrainingState copyWith({
    Map<String, List<String>>? activitiesByStudentId,
    bool? isSimulating,
    List<WeekSimulationResult>? results,
    String? error,
    bool clearResults = false,
    bool clearError = false,
  }) => TrainingState(
    activitiesByStudentId: activitiesByStudentId ?? this.activitiesByStudentId,
    isSimulating: isSimulating ?? this.isSimulating,
    results: clearResults ? null : results ?? this.results,
    error: clearError ? null : error ?? this.error,
  );
}

class TrainingViewModel extends StateNotifier<TrainingState> {
  final SimulateWeekUseCase _useCase;
  final Ref _ref;

  TrainingViewModel(this._useCase, this._ref) : super(const TrainingState());

  void toggleActivity(String studentId, String activityId) {
    final current = List<String>.from(state.activitiesFor(studentId));
    if (current.contains(activityId)) {
      current.remove(activityId);
    } else {
      if (current.length >= TrainingActivitiesConfig.maxActivitiesPerWeek) return;
      current.add(activityId);
    }
    state = state.copyWith(
      activitiesByStudentId: {...state.activitiesByStudentId, studentId: current},
    );
  }

  Future<void> simulateWeek(List<Student> students) async {
    if (students.isEmpty) return;
    state = state.copyWith(isSimulating: true, clearResults: true, clearError: true);

    try {
      final dojo = await _ref.read(dojoProvider.future);
      if (dojo == null) {
        state = state.copyWith(isSimulating: false, error: 'Dojo not found');
        return;
      }

      final results = await _useCase.execute(
        students: students,
        activitiesByStudentId: state.activitiesByStudentId,
        dojoId: dojo.id,
      );

      _ref.invalidate(studentsProvider);
      state = state.copyWith(isSimulating: false, results: results);
    } catch (e) {
      state = state.copyWith(isSimulating: false, error: e.toString());
    }
  }

  void clearResults() => state = state.copyWith(clearResults: true);
}

final trainingViewModelProvider =
StateNotifierProvider<TrainingViewModel, TrainingState>((ref) {
  return TrainingViewModel(
    SimulateWeekUseCase(FirebaseDojoRepository()),
    ref,
  );
});
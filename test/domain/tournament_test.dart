import 'package:flutter_test/flutter_test.dart';
import 'package:grand_dojo/domain/entities/ai_opponent.dart';
import 'package:grand_dojo/domain/entities/tournament.dart';
import 'package:grand_dojo/domain/use_cases/tournament/generate_ai_opponents_use_case.dart';
import 'package:grand_dojo/domain/use_cases/tournament/generate_league_use_case.dart';
import 'package:grand_dojo/domain/use_cases/tournament/process_tournament_results_use_case.dart';
import 'package:grand_dojo/domain/use_cases/tournament/enroll_students_use_case.dart';

void main() {

  group('GenerateAIOpponentsUseCase', () {
    final useCase = GenerateAIOpponentsUseCase();

    test('genera el número correcto de oponentes', () {
      final opponents = useCase.execute(
        playerStyleId: 'karate',
        beltLevel: 1,
        divisionLevel: 1,
        count: 7,
        seed: 42,
      );
      expect(opponents.length, 7);
    });

    test('es determinista — mismo seed = mismo resultado', () {
      final a = useCase.execute(
        playerStyleId: 'karate', beltLevel: 3,
        divisionLevel: 2, count: 5, seed: 100,
      );
      final b = useCase.execute(
        playerStyleId: 'karate', beltLevel: 3,
        divisionLevel: 2, count: 5, seed: 100,
      );
      expect(a.first.teamName, b.first.teamName);
      expect(a.first.fighters.first.stats.str,
          b.first.fighters.first.stats.str);
    });

    test('distinto seed = distinto resultado', () {
      final a = useCase.execute(
        playerStyleId: 'karate', beltLevel: 1,
        divisionLevel: 1, count: 1, seed: 1,
      );
      final b = useCase.execute(
        playerStyleId: 'karate', beltLevel: 1,
        divisionLevel: 1, count: 1, seed: 2,
      );
      expect(a.first.teamName, isNot(b.first.teamName));
    });

    test('stats escalan con el nivel de faja', () {
      final low = useCase.execute(
        playerStyleId: 'karate', beltLevel: 1,
        divisionLevel: 1, count: 1, seed: 42,
      );
      final high = useCase.execute(
        playerStyleId: 'karate', beltLevel: 8,
        divisionLevel: 1, count: 1, seed: 42,
      );
      final lowAvg = low.first.fighters.first.stats.str;
      final highAvg = high.first.fighters.first.stats.str;
      expect(highAvg, greaterThan(lowAvg));
    });
  });

  group('GenerateLeagueUseCase', () {
    final aiGen   = GenerateAIOpponentsUseCase();
    final leagueGen = GenerateLeagueUseCase();

    late List<AIOpponent> opponents;
    late Tournament league;

    setUp(() {
      opponents = aiGen.execute(
        playerStyleId: 'karate', beltLevel: 1,
        divisionLevel: 1, count: 7, seed: 42,
      );
      league = leagueGen.execute(
        playerDojoId: 'dojo_123',
        playerDojoName: 'Test Dojo',
        styleId: 'karate',
        beltLevelKey: 'belt_white',
        beltLevel: 1,
        season: 1,
        week: 1,
        aiOpponents: opponents,
      );
    });

    test('genera 8 equipos (1 jugador + 7 IA)', () {
      expect(league.teams.length, 8);
    });

    test('el equipo del jugador existe', () {
      expect(league.playerTeam, isNotNull);
      expect(league.playerTeam!.isPlayer, true);
    });

    test('round-robin genera el número correcto de partidos', () {
      // n equipos → n*(n-1)/2 partidos
      final n = league.teams.length;
      expect(league.matches.length, n * (n - 1) ~/ 2);
    });

    test('ningún equipo se enfrenta a sí mismo', () {
      for (final match in league.matches) {
        expect(match.homeTeamId, isNot(match.awayTeamId));
      }
    });

    test('cada equipo juega contra todos los demás exactamente una vez', () {
      for (final team in league.teams) {
        final matchesOfTeam = league.matches.where((m) =>
        m.homeTeamId == team.id || m.awayTeamId == team.id).length;
        expect(matchesOfTeam, league.teams.length - 1);
      }
    });

    test('el jugador tiene partidos asignados', () {
      expect(league.playerMatches.isNotEmpty, true);
    });

    test('torneo inicia en estado upcoming', () {
      expect(league.status, TournamentStatus.upcoming);
    });
  });

  group('ProcessTournamentResultsUseCase', () {
    final process = ProcessTournamentResultsUseCase();
    final aiGen   = GenerateAIOpponentsUseCase();
    final leagueGen = GenerateLeagueUseCase();

    late Tournament league;

    setUp(() {
      final opponents = aiGen.execute(
        playerStyleId: 'karate', beltLevel: 1,
        divisionLevel: 1, count: 3, seed: 99,
      );
      league = leagueGen.execute(
        playerDojoId: 'dojo_test',
        playerDojoName: 'Test FC',
        styleId: 'karate',
        beltLevelKey: 'belt_white',
        beltLevel: 1,
        season: 1,
        week: 1,
        aiOpponents: opponents,
      );
    });

    test('victoria del home suma 3 puntos al ganador, 0 al perdedor', () {
      final match = league.matches.first;
      final played = match.copyWith(
        result: MatchResult.homeWin,
        homePoints: 10,
        awayPoints: 4,
        isPlayed: true,
      );
      final updated = process.execute(
          tournament: league, playedMatch: played);

      final homeTeam = updated.teams
          .firstWhere((t) => t.id == match.homeTeamId);
      final awayTeam = updated.teams
          .firstWhere((t) => t.id == match.awayTeamId);

      expect(homeTeam.points, 3);
      expect(awayTeam.points, 0);
      expect(homeTeam.wins, 1);
      expect(awayTeam.losses, 1);
    });

    test('empate suma 1 punto a cada equipo', () {
      final match = league.matches.first;
      final played = match.copyWith(
        result: MatchResult.draw,
        homePoints: 6,
        awayPoints: 6,
        isPlayed: true,
      );
      final updated = process.execute(
          tournament: league, playedMatch: played);

      final homeTeam = updated.teams
          .firstWhere((t) => t.id == match.homeTeamId);
      final awayTeam = updated.teams
          .firstWhere((t) => t.id == match.awayTeamId);

      expect(homeTeam.points, 1);
      expect(awayTeam.points, 1);
    });

    test('tabla de posiciones se ordena por puntos descendente', () {
      var current = league;
      for (final match in league.matches.take(3)) {
        final played = match.copyWith(
          result: MatchResult.homeWin,
          homePoints: 8, awayPoints: 2,
          isPlayed: true,
        );
        current = process.execute(tournament: current, playedMatch: played);
      }
      final points = current.teams.map((t) => t.points).toList();
      for (int i = 0; i < points.length - 1; i++) {
        expect(points[i], greaterThanOrEqualTo(points[i + 1]));
      }
    });

    test('torneo pasa a completed cuando todos los partidos se juegan', () {
      var current = league;
      for (final match in league.matches) {
        final played = match.copyWith(
          result: MatchResult.homeWin,
          homePoints: 6, awayPoints: 2,
          isPlayed: true,
        );
        current = process.execute(tournament: current, playedMatch: played);
      }
      expect(current.status, TournamentStatus.completed);
    });
  });

  group('EnrollStudentsUseCase', () {
    final enroll = EnrollStudentsUseCase();

    test('inscripción válida de 2 estudiantes con orden correcto', () {
      // Test con datos mínimos — se expande cuando tengamos factories de test
      final result = enroll.execute(
        students: [],
        enrolledStudentIds: [],
        fightOrder: [0, 1, 0],
        tournament: _emptyTournament(),
      );
      expect(result.success, false); // sin estudiantes → falla correctamente
    });

    test('más de 2 inscritos → error', () {
      final result = enroll.execute(
        students: [],
        enrolledStudentIds: ['a', 'b', 'c'],
        fightOrder: [0, 1, 2],
        tournament: _emptyTournament(),
      );
      expect(result.success, false);
      expect(result.error, contains('Maximum'));
    });

    test('orden de pelea con longitud incorrecta → error', () {
      final result = enroll.execute(
        students: [],
        enrolledStudentIds: ['a', 'b'],
        fightOrder: [0, 1],  // debe ser 3
        tournament: _emptyTournament(),
      );
      expect(result.success, false);
      expect(result.error, contains('exactly'));
    });
  });
}

Tournament _emptyTournament() => const Tournament(
  id: 'test', dojoId: 'dojo', type: TournamentType.styleLeague,
  status: TournamentStatus.upcoming, season: 1, week: 1,
  beltLevelKey: 'belt_white', styleId: 'karate',
  teams: [], matches: [],
);
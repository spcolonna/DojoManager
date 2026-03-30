import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/config/fight_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/fight.dart';
import '../../../domain/entities/fight_fighter.dart';
import '../../../domain/entities/fight_tick_snapshot.dart';
import '../../../infrastructure/services/fight_simulation_service.dart';
import '../../widgets/arena/arena_painter.dart';
import '../../widgets/arena/fighter_painter.dart';
import '../../widgets/arena/particle_painter.dart';
import '../../widgets/arena/trail_point.dart';

enum _Phase { countdown, fighting, betweenRounds, finished }

class _FloatLabel {
  final String text;
  final Color color;
  double x, y, life;
  _FloatLabel({
    required this.text, required this.color,
    required this.x, required this.y, this.life = 1.0,
  });
}

class FightArenaScreen extends StatefulWidget {
  final FightFighter blueFighter;
  final FightFighter redFighter;
  final String blueTeamId;
  final String redTeamId;
  final Color blueColor;
  final Color redColor;
  final String blueName;
  final String redName;
  final FightStrategy initialStrategy;
  final void Function(int blueWins, int redWins) onComplete;

  const FightArenaScreen({
    super.key,
    required this.blueFighter,
    required this.redFighter,
    required this.blueTeamId,
    required this.redTeamId,
    required this.blueColor,
    required this.redColor,
    required this.blueName,
    required this.redName,
    this.initialStrategy = FightStrategy.technical,
    required this.onComplete,
  });

  @override
  State<FightArenaScreen> createState() => _FightArenaScreenState();
}

class _FightArenaScreenState extends State<FightArenaScreen>
    with TickerProviderStateMixin {
  final _rng = Random();
  final _service = FightSimulationService();
  late Ticker _ticker;

  _Phase _phase = _Phase.countdown;
  int _countdown = 3;
  int _currentRound = 1;
  FightStrategy _playerStrategy = FightStrategy.technical;

  late FightRoundSimulation _roundSim;
  int _tickIdx = 0;
  int _tickAccMs = 0;
  static const _tickMs = 300;

  int _blueRoundScore = 0, _redRoundScore = 0;
  int _blueWins = 0, _redWins = 0;
  double _blueStamina = 100, _redStamina = 100;

  // Posiciones actuales e objetivo
  double _bx = 0.28, _by = 0.5;
  double _rx = 0.72, _ry = 0.5;
  double _tbx = 0.28, _tby = 0.5;
  double _trx = 0.72, _try_ = 0.5;

  // Estado de movimiento
  bool _blueAttacking = false;
  bool _redAttacking  = false;

  // Efectos
  bool _blueFlash = false, _redFlash = false;
  double _shakeX = 0, _shakeY = 0;
  double _bluePulse = 0, _redPulse = 0;
  final List<ArenaParticle> _particles = [];
  final List<_FloatLabel> _labels = [];

  // Trails
  final List<TrailPoint> _blueTrail = [];
  final List<TrailPoint> _redTrail  = [];
  static const _trailMax = 12;
  int _trailAccMs = 0;
  static const _trailIntervalMs = 40;

  Duration _last = Duration.zero;
  int _interRoundMs = 0;
  static const _interRoundDurationMs = 8000;
  int _countdownAccMs = 0;

  @override
  void initState() {
    super.initState();
    _playerStrategy = widget.initialStrategy;
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final dt   = elapsed - _last;
    _last      = elapsed;
    final dtMs = dt.inMilliseconds.clamp(0, 50);

    setState(() {
      _updatePhase(dtMs);
      _lerpPositions(dtMs);
      _updateTrails(dtMs);
      _updateParticles(dtMs);
      _updateLabels(dtMs);
      _shakeX *= pow(0.82, dtMs / 16.0);
      _shakeY *= pow(0.82, dtMs / 16.0);
      _bluePulse = (_bluePulse + dtMs / 900.0) % 1.0;
      _redPulse  = (_redPulse  + dtMs / 900.0) % 1.0;
    });
  }

  void _updatePhase(int dtMs) {
    switch (_phase) {
      case _Phase.countdown:
        _countdownAccMs += dtMs;
        if (_countdownAccMs >= 1000) {
          _countdownAccMs -= 1000;
          _countdown--;
          if (_countdown <= 0) _startRound();
        }
      case _Phase.fighting:
        _tickAccMs += dtMs;
        while (_tickAccMs >= _tickMs) {
          _tickAccMs -= _tickMs;
          _advanceTick();
        }
      case _Phase.betweenRounds:
        _interRoundMs += dtMs;
        if (_interRoundMs >= _interRoundDurationMs) _startNextRound();
      case _Phase.finished:
        break;
    }
  }

  void _startRound() {
    _phase = _Phase.fighting;
    _blueRoundScore = 0;
    _redRoundScore  = 0;
    _tickIdx = 0;
    _tickAccMs = 0;
    _roundSim = _service.simulateRoundToSnapshots(
      blue: widget.blueFighter,
      red: widget.redFighter,
      blueStrategy: _playerStrategy,
      redStrategy: _aiStrategy(),
      blueStartStamina: _blueStamina,
      redStartStamina: _redStamina,
      seed: _rng.nextInt(999999) + _currentRound,
    );
  }

  void _advanceTick() {
    if (_tickIdx >= _roundSim.snapshots.length) {
      _endRound();
      return;
    }

    final snap = _roundSim.snapshots[_tickIdx++];
    _blueRoundScore = snap.blueScore;
    _redRoundScore  = snap.redScore;
    _blueStamina    = snap.blueStamina;
    _redStamina     = snap.redStamina;

    // ── Movimiento según estado ──────────────────────────────────────────────
    final t = _tickIdx * 0.12;
    switch (snap.movementState) {

      case MovementState.circling:
      // Rotan alrededor del centro, distancia media
        _tbx = 0.25 + cos(t) * 0.08;
        _tby = 0.5  + sin(t) * 0.10;
        _trx = 0.75 + cos(t + pi) * 0.08;
        _try_ = 0.5 + sin(t + pi) * 0.10;
        _blueAttacking = false;
        _redAttacking  = false;

      case MovementState.approaching:
      // Se acercan al centro
        _tbx = 0.38 + cos(t) * 0.03;
        _tby = 0.5  + sin(t) * 0.05;
        _trx = 0.62 + cos(t + pi) * 0.03;
        _try_ = 0.5 + sin(t + pi) * 0.05;

      case MovementState.clinch:
      // Muy cerca — casi pegados
        _tbx = 0.42 + cos(t) * 0.02;
        _tby = 0.5  + sin(t) * 0.03;
        _trx = 0.58 + cos(t + pi) * 0.02;
        _try_ = 0.5 + sin(t + pi) * 0.03;

      case MovementState.retreating:
      // Cada uno vuelve a su lado
        _tbx = 0.28 + cos(t) * 0.05;
        _tby = 0.5  + sin(t) * 0.07;
        _trx = 0.72 + cos(t + pi) * 0.05;
        _try_ = 0.5 + sin(t + pi) * 0.07;
        _blueAttacking = false;
        _redAttacking  = false;
    }

    // Bloqueos
    if (snap.blueBlocked) {
      _labels.add(_FloatLabel(
        text: '🛡', color: widget.blueColor,
        x: _bx, y: _by - 0.08,
      ));
    }
    if (snap.redBlocked) {
      _labels.add(_FloatLabel(
        text: '🛡', color: widget.redColor,
        x: _rx, y: _ry - 0.08,
      ));
    }

    if (snap.eventType != null) _handleEvent(snap);
  }

  void _handleEvent(FightTickSnapshot snap) {
    final isBlue = snap.eventIsBlue;
    final color  = isBlue ? widget.blueColor : widget.redColor;
    final hitX   = isBlue ? _rx : _bx;
    final hitY   = isBlue ? _ry : _by;

    switch (snap.eventType) {
      case 'dominant_hit':
        _spawnBurst(hitX, hitY, color, 14);
        _spawnRing(hitX, hitY, color);
        _labels.add(_FloatLabel(
            text: '+2', color: color,
            x: hitX, y: hitY - 0.09));
        if (isBlue) _blueFlash = true; else _redFlash = true;
        _shakeX = (_rng.nextDouble() - 0.5) * 22;
        _shakeY = (_rng.nextDouble() - 0.5) * 10;

      case 'clean_hit':
        _spawnBurst(hitX, hitY, color, 6);
        _labels.add(_FloatLabel(
            text: '+1', color: color,
            x: hitX, y: hitY - 0.08));
        if (isBlue) _blueFlash = true; else _redFlash = true;
        _shakeX = (_rng.nextDouble() - 0.5) * 6;
        _shakeY = (_rng.nextDouble() - 0.5) * 3;

      case 'takedown':
        _spawnFall(hitX, hitY, color);
        _spawnRing(hitX, hitY, color);
        _labels.add(_FloatLabel(
            text: '+2', color: color,
            x: hitX, y: hitY - 0.09));
        if (isBlue) _blueFlash = true; else _redFlash = true;
        _shakeX = (_rng.nextDouble() - 0.5) * 26;
        _shakeY = (_rng.nextDouble() - 0.5) * 12;

      case 'counter':
        _spawnSpiral(hitX, hitY, color);
        _labels.add(_FloatLabel(
            text: 'COUNTER!', color: color,
            x: hitX - 0.05, y: hitY - 0.1));
    }

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() { _blueFlash = false; _redFlash = false; });
    });
  }

  // ── PARTÍCULAS CON SIGNIFICADO ────────────────────────────────────────────

  void _spawnBurst(double x, double y, Color color, int count) {
    for (int i = 0; i < count; i++) {
      final a = _rng.nextDouble() * 2 * pi;
      final s = 0.006 + _rng.nextDouble() * 0.010;
      _particles.add(ArenaParticle(
        x: x, y: y,
        vx: cos(a) * s, vy: sin(a) * s,
        color: _rng.nextBool() ? color : Colors.white,
        size: 3.5 + _rng.nextDouble() * 3,
        type: ParticleType.burst,
      ));
    }
  }

  void _spawnRing(double x, double y, Color color) {
    // Anillo expansivo — una sola partícula de tipo ring que crece
    for (int i = 0; i < 3; i++) {
      _particles.add(ArenaParticle(
        x: x, y: y, vx: 0, vy: 0,
        color: color,
        size: 8.0 + i * 6.0, // tamaños distintos para efecto de eco
        type: ParticleType.ring,
        life: 1.0 - i * 0.2,
      ));
    }
  }

  void _spawnFall(double x, double y, Color color) {
    // Partículas que caen — simulan el derribo
    for (int i = 0; i < 10; i++) {
      _particles.add(ArenaParticle(
        x: x + (_rng.nextDouble() - 0.5) * 0.06,
        y: y,
        vx: (_rng.nextDouble() - 0.5) * 0.004,
        vy: 0.005 + _rng.nextDouble() * 0.008, // solo hacia abajo
        color: color,
        size: 4 + _rng.nextDouble() * 3,
        type: ParticleType.fall,
      ));
    }
  }

  void _spawnSpiral(double x, double y, Color color) {
    // Espiral — el rival leyó el movimiento
    for (int i = 0; i < 8; i++) {
      final baseAngle = i * (2 * pi / 8);
      _particles.add(ArenaParticle(
        x: x, y: y,
        vx: cos(baseAngle) * 0.004,
        vy: sin(baseAngle) * 0.004,
        color: color,
        size: 3.5,
        type: ParticleType.spiral,
        angle: baseAngle,
      ));
    }
  }

  void _updateParticles(int dtMs) {
    final dt = dtMs / 16.0;
    for (final p in _particles) {
      switch (p.type) {
        case ParticleType.burst:
          p.x += p.vx * dt;
          p.y += p.vy * dt;
          p.vy += 0.00008 * dt; // gravedad leve
          p.life -= 0.030 * dt;
        case ParticleType.ring:
          p.size += 1.8 * dt;   // crece hacia afuera
          p.life -= 0.028 * dt;
        case ParticleType.fall:
          p.x += p.vx * dt;
          p.y += p.vy * dt;
          p.vy += 0.0003 * dt;  // gravedad fuerte
          p.life -= 0.025 * dt;
        case ParticleType.spiral:
          p.angle += 0.08 * dt;
          final r = (1 - p.life) * 0.06;
          p.x += cos(p.angle) * r * dt;
          p.y += sin(p.angle) * r * dt;
          p.life -= 0.025 * dt;
      }
    }
    _particles.removeWhere((p) => p.life <= 0);
  }

  // ── TRAILS ────────────────────────────────────────────────────────────────

  void _updateTrails(int dtMs) {
    _trailAccMs += dtMs;
    if (_trailAccMs >= _trailIntervalMs) {
      _trailAccMs = 0;

      _blueTrail.add(TrailPoint(x: _bx, y: _by));
      if (_blueTrail.length > _trailMax) _blueTrail.removeAt(0);

      _redTrail.add(TrailPoint(x: _rx, y: _ry));
      if (_redTrail.length > _trailMax) _redTrail.removeAt(0);

      // Fade de los puntos viejos
      for (int i = 0; i < _blueTrail.length; i++) {
        _blueTrail[i].opacity = i / _blueTrail.length * 0.5;
      }
      for (int i = 0; i < _redTrail.length; i++) {
        _redTrail[i].opacity = i / _redTrail.length * 0.5;
      }
    }
    final dt = dtMs / 16.0;
    for (final p in [..._blueTrail, ..._redTrail]) {
      p.opacity -= 0.012 * dt;
    }
    _blueTrail.removeWhere((p) => p.opacity <= 0);
    _redTrail.removeWhere((p) => p.opacity <= 0);
  }

  void _updateLabels(int dtMs) {
    final dt = dtMs / 16.0;
    for (final l in _labels) {
      l.y -= 0.0025 * dt;
      l.life -= 0.028 * dt;
    }
    _labels.removeWhere((l) => l.life <= 0);
  }

  void _lerpPositions(int dtMs) {
    final dt = dtMs / 16.0;

    // Velocidad varía según el estado del último snapshot
    final lastState = _tickIdx > 0 && _tickIdx <= _roundSim.snapshots.length
        ? _roundSim.snapshots[_tickIdx - 1].movementState
        : MovementState.circling;

    final speed = switch (lastState) {
      MovementState.circling    => 0.04,
      MovementState.approaching => 0.10,
      MovementState.clinch      => 0.16,
      MovementState.retreating  => 0.08,
    };

    _bx = _bx + (_tbx - _bx) * speed * dt;
    _by = _by + (_tby - _by) * speed * dt;
    _rx = _rx + (_trx - _rx) * speed * dt;
    _ry = _ry + (_try_ - _ry) * speed * dt;
  }

  void _endRound() {
    final blueWon = _roundSim.bluePoints > _roundSim.redPoints;
    final draw    = _roundSim.bluePoints == _roundSim.redPoints;
    if (blueWon) _blueWins++;
    else if (!draw) _redWins++;

    _blueStamina = _roundSim.blueStaminaAfter;
    _redStamina  = _roundSim.redStaminaAfter;

    if (_blueWins >= 2 || _redWins >= 2 || _currentRound >= 3) {
      _phase = _Phase.finished;
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) widget.onComplete(_blueWins, _redWins);
      });
    } else {
      _phase = _Phase.betweenRounds;
      _interRoundMs = 0;
      // Fighters vuelven a sus esquinas
      _tbx = 0.28; _tby = 0.5;
      _trx = 0.72; _try_ = 0.5;
    }
  }

  void _startNextRound() {
    _currentRound++;
    _countdown = 3;
    _countdownAccMs = 0;
    _phase = _Phase.countdown;
  }

  FightStrategy _aiStrategy() {
    final stats = widget.redFighter.stats;
    final dom = stats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return switch (dom) {
      'str' => FightStrategy.grappling,
      'spd' => FightStrategy.aggressive,
      'def' => FightStrategy.defensive,
      _     => FightStrategy.technical,
    };
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildArena()),
            _buildStaminaBars(),
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF0D0D0D),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: widget.blueColor, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                            color: widget.blueColor, blurRadius: 6)],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(widget.blueName,
                        style: GoogleFonts.rajdhani(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: widget.blueColor)),
                    const SizedBox(width: 4),
                    Text('(TÚ)',
                        style: GoogleFonts.rajdhani(
                            fontSize: 9, color: AppColors.textTertiary)),
                  ],
                ),
                Text('$_blueRoundScore',
                    style: GoogleFonts.cinzelDecorative(
                        fontSize: 26, fontWeight: FontWeight.bold,
                        color: widget.blueColor)),
              ],
            ),
          ),
          Column(
            children: [
              Text('ROUND $_currentRound/3',
                  style: GoogleFonts.rajdhani(
                      fontSize: 9, color: AppColors.textTertiary,
                      letterSpacing: 1.5, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(
                children: List.generate(3, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 9, height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _blueWins
                        ? widget.blueColor
                        : i < 3 - _redWins
                        ? AppColors.bgDivider
                        : widget.redColor,
                    boxShadow: i < _blueWins ? [BoxShadow(
                        color: widget.blueColor, blurRadius: 4)] : null,
                  ),
                )),
              ),
              const SizedBox(height: 4),
              Text('$_blueWins - $_redWins',
                  style: GoogleFonts.rajdhani(
                      fontSize: 11, fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary)),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: widget.redColor, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                            color: widget.redColor, blurRadius: 6)],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(widget.redName,
                        style: GoogleFonts.rajdhani(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: widget.redColor)),
                  ],
                ),
                Text('$_redRoundScore',
                    style: GoogleFonts.cinzelDecorative(
                        fontSize: 26, fontWeight: FontWeight.bold,
                        color: widget.redColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArena() {
    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      return Stack(
        children: [
          // Ring
          CustomPaint(
            size: Size(w, h),
            painter: ArenaPainter(shakeX: _shakeX, shakeY: _shakeY),
          ),
          // Trails
          CustomPaint(
            size: Size(w, h),
            painter: TrailPainter(
              blueTrail: _blueTrail,
              redTrail: _redTrail,
              blueColor: widget.blueColor,
              redColor: widget.redColor,
            ),
          ),
          // Partículas
          CustomPaint(
            size: Size(w, h),
            painter: ParticlePainter(_particles),
          ),

          // Fighter azul — HEXÁGONO
          Positioned(
            left: _bx * w - 24 + _shakeX * 0.3,
            top:  _by * h - 24 + _shakeY * 0.3,
            child: SizedBox(
              width: 48, height: 48,
              child: CustomPaint(
                painter: FighterPainter(
                  color: widget.blueColor,
                  isFlashing: _blueFlash,
                  pulse: _bluePulse,
                  shape: FighterShape.hexagon,
                  showLabel: true,
                  label: 'TÚ',
                ),
              ),
            ),
          ),

          // Fighter rojo — TRIÁNGULO
          Positioned(
            left: _rx * w - 24 + _shakeX * 0.3,
            top:  _ry * h - 24 + _shakeY * 0.3,
            child: SizedBox(
              width: 48, height: 48,
              child: CustomPaint(
                painter: FighterPainter(
                  color: widget.redColor,
                  isFlashing: _redFlash,
                  pulse: _redPulse,
                  shape: FighterShape.triangle,
                  showLabel: true,
                  label: 'RIVAL',
                ),
              ),
            ),
          ),

          // Float labels
          ..._labels.map((l) => Positioned(
            left: l.x * w - 24,
            top:  l.y * h,
            child: Opacity(
              opacity: l.life.clamp(0.0, 1.0),
              child: Text(
                l.text,
                style: GoogleFonts.cinzelDecorative(
                  fontSize: l.text.length > 3 ? 11 : 18,
                  fontWeight: FontWeight.bold,
                  color: l.color,
                  shadows: [Shadow(color: l.color, blurRadius: 10)],
                ),
              ),
            ),
          )),

          // Countdown
          if (_phase == _Phase.countdown)
            Center(
              child: Text(
                _countdown > 0 ? '$_countdown' : '¡PELEA!',
                style: GoogleFonts.cinzelDecorative(
                  fontSize: 72, fontWeight: FontWeight.bold,
                  color: AppColors.goldPrimary,
                  shadows: [Shadow(
                      color: AppColors.goldPrimary, blurRadius: 40)],
                ),
              ),
            ),

          // Resultado final
          if (_phase == _Phase.finished)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _blueWins > _redWins
                        ? 'VICTORIA'
                        : _redWins > _blueWins
                        ? 'DERROTA'
                        : 'EMPATE',
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 36, fontWeight: FontWeight.bold,
                      color: _blueWins > _redWins
                          ? AppColors.goldPrimary
                          : _redWins > _blueWins
                          ? widget.redColor
                          : AppColors.info,
                      shadows: [Shadow(
                        color: _blueWins > _redWins
                            ? AppColors.goldPrimary
                            : widget.redColor,
                        blurRadius: 30,
                      )],
                    ),
                  ),
                  Text(
                    '$_blueWins - $_redWins',
                    style: GoogleFonts.cinzelDecorative(
                        fontSize: 52, fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildStaminaBars() {
    return Container(
      color: const Color(0xFF0D0D0D),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Blue stamina — crece hacia la derecha desde la izquierda
          Expanded(
            child: RotatedBox(
              quarterTurns: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: (_blueStamina / 100).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: AppColors.bgDivider,
                  valueColor: AlwaysStoppedAnimation(widget.blueColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('STA',
              style: GoogleFonts.rajdhani(
                  fontSize: 8, fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary, letterSpacing: 1.5)),
          const SizedBox(width: 8),
          // Red stamina — crece hacia la derecha
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (_redStamina / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.bgDivider,
                valueColor: AlwaysStoppedAnimation(widget.redColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    if (_phase == _Phase.betweenRounds) {
      final timeLeft = ((_interRoundDurationMs - _interRoundMs) / 1000).ceil();
      final winnerLabel = _roundSim.bluePoints > _roundSim.redPoints
          ? 'Ganaste el round'
          : _roundSim.redPoints > _roundSim.bluePoints
          ? 'Perdiste el round'
          : 'Round empatado';
      final winnerColor = _roundSim.bluePoints > _roundSim.redPoints
          ? AppColors.success
          : _roundSim.redPoints > _roundSim.bluePoints
          ? widget.redColor
          : AppColors.info;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        color: const Color(0xFF0D0D0D),
        child: Column(
          children: [
            Row(
              children: [
                Text(winnerLabel,
                    style: GoogleFonts.rajdhani(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: winnerColor)),
                const Spacer(),
                Text('$timeLeft s',
                    style: GoogleFonts.rajdhani(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: AppColors.textTertiary)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('CAMBIAR ESTRATEGIA',
                    style: GoogleFonts.rajdhani(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        color: AppColors.goldPrimary, letterSpacing: 1.5)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: FightStrategy.values.map((s) {
                final isSelected = s == _playerStrategy;
                final sColor = _strategyColor(s);
                return GestureDetector(
                  onTap: () => setState(() => _playerStrategy = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? sColor.withValues(alpha: 0.18)
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? sColor : AppColors.bgDivider,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      _strategyName(s),
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? sColor
                            : AppColors.textTertiary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFF0D0D0D),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: _strategyColor(_playerStrategy),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: _strategyColor(_playerStrategy), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _strategyName(_playerStrategy).toUpperCase(),
            style: GoogleFonts.rajdhani(
                fontSize: 11, fontWeight: FontWeight.w800,
                color: _strategyColor(_playerStrategy),
                letterSpacing: 1),
          ),
          const Spacer(),
          if (_phase == _Phase.fighting)
            Text(
              'ROUND $_currentRound · TICK ${_tickIdx}/${_roundSim.snapshots.length}',
              style: GoogleFonts.rajdhani(
                  fontSize: 9, color: AppColors.textTertiary,
                  letterSpacing: 0.5),
            ),
        ],
      ),
    );
  }

  Color _strategyColor(FightStrategy s) => switch (s) {
    FightStrategy.aggressive => AppColors.redLight,
    FightStrategy.defensive  => AppColors.info,
    FightStrategy.technical  => AppColors.goldPrimary,
    FightStrategy.grappling  => AppColors.orange,
    FightStrategy.adaptive   => AppColors.success,
  };

  String _strategyName(FightStrategy s) => switch (s) {
    FightStrategy.aggressive => 'Agresivo',
    FightStrategy.defensive  => 'Defensivo',
    FightStrategy.technical  => 'Técnico',
    FightStrategy.grappling  => 'Grappling',
    FightStrategy.adaptive   => 'Adaptable',
  };
}
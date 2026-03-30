import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grand_dojo/core/utils/l10n_helper.dart';
import '../../../core/config/economy_config.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../domain/value_objects/martial_style.dart';

// ─── STATE ────────────────────────────────────────────────────────────────────

class OnboardingState {
  final int step;           // 0 = nombre, 1 = estilo, 2 = narrativa
  final String schoolName;
  final String? selectedStyleId;
  final bool isLoading;

  const OnboardingState({
    this.step = 0,
    this.schoolName = '',
    this.selectedStyleId,
    this.isLoading = false,
  });

  OnboardingState copyWith({
    int? step,
    String? schoolName,
    String? selectedStyleId,
    bool? isLoading,
  }) => OnboardingState(
    step: step ?? this.step,
    schoolName: schoolName ?? this.schoolName,
    selectedStyleId: selectedStyleId ?? this.selectedStyleId,
    isLoading: isLoading ?? this.isLoading,
  );
}

final _onboardingProvider =
StateNotifierProvider.autoDispose<_OnboardingNotifier, OnboardingState>(
      (_) => _OnboardingNotifier(),
);

class _OnboardingNotifier extends StateNotifier<OnboardingState> {
  _OnboardingNotifier() : super(const OnboardingState());

  void setName(String name)   => state = state.copyWith(schoolName: name);
  void setStyle(String id)    => state = state.copyWith(selectedStyleId: id);
  void nextStep()             => state = state.copyWith(step: state.step + 1);
  void setLoading(bool v)     => state = state.copyWith(isLoading: v);
}

// ─── FLOW CONTAINER ──────────────────────────────────────────────────────────

class OnboardingFlow extends ConsumerWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(_onboardingProvider).step;

    return switch (step) {
      0 => const _SchoolNameStep(),
      1 => const _StyleSelectionStep(),
      2 => const _NarrativeStep(),
      _ => const _SchoolNameStep(),
    };
  }
}

// ─── STEP 1: NOMBRE DE LA ESCUELA ────────────────────────────────────────────

class _SchoolNameStep extends ConsumerStatefulWidget {
  const _SchoolNameStep();

  @override
  ConsumerState<_SchoolNameStep> createState() => _SchoolNameStepState();
}

class _SchoolNameStepState extends ConsumerState<_SchoolNameStep> {
  final _controller = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Text(
                    loc.appName,
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFC9A84C),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  loc.onboardingSchoolNameTitle,
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 18,
                    color: const Color(0xFFF0F0F0),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.onboardingSchoolNameLabel,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: const Color(0xFF9099B0),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFFF0F0F0),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: loc.onboardingSchoolNameHint,
                    hintStyle: GoogleFonts.rajdhani(
                      color: const Color(0xFF4A5068),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF242B40),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: Color(0xFF2A3048)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                      const BorderSide(color: Color(0xFF2A3048)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color(0xFFC9A84C), width: 1.5),
                    ),
                    errorStyle: GoogleFonts.rajdhani(
                        color: const Color(0xFFE74C3C)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 3)
                      return loc.onboardingSchoolNameError;
                    if (v.trim().length > 30)
                      return loc.onboardingSchoolNameError;
                    return null;
                  },
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      ref
                          .read(_onboardingProvider.notifier)
                          .setName(_controller.text.trim());
                      ref.read(_onboardingProvider.notifier).nextStep();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A84C),
                      foregroundColor: const Color(0xFF0A0C12),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      loc.onboardingConfirmStyleCta,
                      style: GoogleFonts.rajdhani(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── STEP 2: SELECCIÓN DE ESTILO ─────────────────────────────────────────────

class _StyleSelectionStep extends ConsumerStatefulWidget {
  const _StyleSelectionStep();

  @override
  ConsumerState<_StyleSelectionStep> createState() =>
      _StyleSelectionStepState();
}

class _StyleSelectionStepState
    extends ConsumerState<_StyleSelectionStep> {
  final _pageController = PageController(viewportFraction: 0.82);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _styleDesc(String id, dynamic loc) {
    return switch (id) {
      'kung_fu'   => loc.styleKungFuDesc,
      'karate'    => loc.styleKarateDesc,
      'taekwondo' => loc.styleTaekwondoDesc,
      'judo'      => loc.styleJudoDesc,
      'muay_thai' => loc.styleMuayThaiDesc,
      'bjj'       => loc.styleBjjDesc,
      'boxing'    => loc.styleBoxingDesc,
      'mma'       => loc.styleMmaDesc,
      _           => '',
    };
  }

  String _styleName(String id, dynamic loc) {
    return switch (id) {
      'kung_fu'   => loc.styleKungFu,
      'karate'    => loc.styleKarate,
      'taekwondo' => loc.styleTaekwondo,
      'judo'      => loc.styleJudo,
      'muay_thai' => loc.styleMuayThai,
      'bjj'       => loc.styleBjj,
      'boxing'    => loc.styleBoxing,
      'mma'       => loc.styleMma,
      _           => id,
    };
  }

  @override
  Widget build(BuildContext context) {
    final loc    = l10n(context);
    const styles = MartialStyle.all;
    final selectedId =
        ref.watch(_onboardingProvider).selectedStyleId ??
            styles[_currentPage].id;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C12),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              loc.onboardingChooseStyleTitle,
              style: GoogleFonts.cinzelDecorative(
                fontSize: 18,
                color: const Color(0xFFF0F0F0),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              loc.onboardingChooseStyleSubtitle,
              style: GoogleFonts.rajdhani(
                fontSize: 13,
                color: const Color(0xFF9099B0),
              ),
            ),
            const SizedBox(height: 28),

            // Carousel
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                itemCount: styles.length,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  ref
                      .read(_onboardingProvider.notifier)
                      .setStyle(styles[i].id);
                },
                itemBuilder: (_, i) {
                  final style    = styles[i];
                  final isActive = i == _currentPage;

                  return AnimatedScale(
                    scale: isActive ? 1.0 : 0.92,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141824),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive
                              ? Color(style.colorHex)
                              : const Color(0xFF2A3048),
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(style.colorHex).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                _styleIcon(style.id),
                                color: Color(style.colorHex),
                                size: 38,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _styleName(style.id, loc),
                            style: GoogleFonts.cinzelDecorative(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? Color(style.colorHex)
                                  : const Color(0xFFF0F0F0),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Stats bars
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                            child: _StatsRow(style: style, loc: loc),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                styles.length,
                    (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _currentPage ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? const Color(0xFFC9A84C)
                        : const Color(0xFF3A3F52),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Descripción del estilo seleccionado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _styleDesc(
                    styles[_currentPage].id, loc),
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  color: const Color(0xFF9099B0),
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(_onboardingProvider.notifier)
                        .setStyle(styles[_currentPage].id);
                    ref.read(_onboardingProvider.notifier).nextStep();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A84C),
                    foregroundColor: const Color(0xFF0A0C12),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    loc.onboardingConfirmStyleCta,
                    style: GoogleFonts.rajdhani(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _styleIcon(String id) => switch (id) {
    'kung_fu'   => Icons.self_improvement,
    'karate'    => Icons.sports_martial_arts,
    'taekwondo' => Icons.directions_run,
    'judo'      => Icons.people,
    'muay_thai' => Icons.sports_mma,
    'bjj'       => Icons.accessibility_new,
    'boxing'    => Icons.sports_kabaddi,
    'mma'       => Icons.sports_mma,
    _           => Icons.sports_martial_arts,
  };
}

class _StatsRow extends StatelessWidget {
  final MartialStyle style;
  final dynamic loc;

  const _StatsRow({required this.style, required this.loc});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (loc.statStr, style.baseStr),
      (loc.statSpd, style.baseSpd),
      (loc.statTec, style.baseTec),
      (loc.statDef, style.baseDef),
      (loc.statMen, style.baseMen),
    ];

    return Column(
      children: stats
          .map((s) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                s.$1,
                style: GoogleFonts.rajdhani(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9099B0),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: s.$2 / 28.0,
                  backgroundColor: const Color(0xFF2A3048),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(style.colorHex),
                  ),
                  minHeight: 5,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${s.$2}',
              style: GoogleFonts.rajdhani(
                fontSize: 10,
                color: const Color(0xFF9099B0),
              ),
            ),
          ],
        ),
      ))
          .toList(),
    );
  }
}

// ─── STEP 3: NARRATIVA ───────────────────────────────────────────────────────

class _NarrativeStep extends ConsumerStatefulWidget {
  const _NarrativeStep();

  @override
  ConsumerState<_NarrativeStep> createState() => _NarrativeStepState();
}

class _NarrativeStepState extends ConsumerState<_NarrativeStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;
  late ScrollController    _listController;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _listController  = ScrollController();
    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..addListener(_onScroll)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() => _showButton = true);
        }
      })
      ..forward();
  }

  void _onScroll() {
    if (_listController.hasClients) {
      final maxExtent = _listController.position.maxScrollExtent;
      _listController.jumpTo(_scrollController.value * maxExtent);
    }
    if (_scrollController.value > 0.85 && !_showButton) {
      setState(() => _showButton = true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _finish(BuildContext context, WidgetRef ref) async {
    final state = ref.read(_onboardingProvider);
    final user  = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    ref.read(_onboardingProvider.notifier).setLoading(true);

    await ref.read(appStateProvider.notifier).completeOnboarding(
      userId: user.uid,
      schoolName: state.schoolName,
      styleId: state.selectedStyleId ?? 'karate',
      startingMD: EconomyConfig.onboardingGiftMD,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc       = l10n(context);
    final state     = ref.watch(_onboardingProvider);
    final schoolName = state.schoolName;
    final isLoading  = state.isLoading;

    final narrativeText = '''
In a world where honor is earned with sweat
and discipline forges destiny...

The ${schoolName.toUpperCase()} has opened its doors.

Your journey as Grand Master begins today.

Two young fighters crossed your threshold this morning.
They don't yet know what they can become.

You do.

ZHANG WEI — 22 years old
Intense. Explosive.
A volcano waiting to erupt.

KEIKO MORI — 22 years old
Calculated. Technical.
The patience of stone, the strike of lightning.

They are your first students.
They will be the first of many.

The path to the grand tournament starts now.

Are you ready, Master?
''';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo estrellado
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF000010), Color(0xFF000510), Color(0xFF0A0C12)],
              ),
            ),
          ),

          // Texto en scroll
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ListView(
              controller: _listController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 500),
                Text(
                  narrativeText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rajdhani(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE8C97A),
                    height: 1.9,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 300),
              ],
            ),
          ),

          // Gradient superior — oscurece el texto que entra
          Positioned(
            top: 0, left: 0, right: 0,
            height: 120,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
          ),

          // Gradient inferior
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: 200,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                ),
              ),
            ),
          ),

          // Botón comenzar
          if (_showButton)
            Positioned(
              bottom: 48,
              left: 40,
              right: 40,
              child: AnimatedOpacity(
                opacity: _showButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _finish(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A84C),
                    foregroundColor: const Color(0xFF000000),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0A0C12),
                    ),
                  )
                      : Text(
                    loc.narrativeStart,
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
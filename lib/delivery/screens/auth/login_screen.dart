import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/utils/l10n_helper.dart';
import 'auth_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  bool _obscurePassword     = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authViewModelProvider.notifier).submit(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);

    ref.listen<AuthState>(authViewModelProvider, (_, next) {
      if (next.isAuthenticated) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          ref.read(appStateProvider.notifier).checkUserState(user.uid);
        }
      }
    });

    final state   = ref.watch(authViewModelProvider);
    final isLogin = state.mode == AuthMode.login;

    return Scaffold(
      body: Stack(
        children: [
          // ── Fondo ──────────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgrounds/bg_login.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF8B0000),
                      Color(0xFF1A0A0A),
                      Color(0xFF0A0C12),
                    ],
                    stops: [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Overlay para legibilidad ────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xCC000000),
                    Color(0xEE000000),
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // ── Contenido ──────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    // ── Header ────────────────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 200,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(
                              loc.appName,
                              style: GoogleFonts.cinzelDecorative(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFC9A84C),
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isLogin ? loc.loginWelcomeBack : loc.loginBeginJourney,
                            style: GoogleFonts.rajdhani(
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 56),

                    // ── Email ─────────────────────────────────────────
                    _label(loc.loginEmailLabel),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFFF0F0F0),
                        fontSize: 15,
                      ),
                      decoration: _inputDecoration(loc.loginEmailHint),
                      validator: (v) {
                        if (v == null || v.isEmpty) return loc.loginEmailEmpty;
                        if (!v.contains('@')) return loc.loginEmailInvalid;
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Password ──────────────────────────────────────
                    _label(loc.loginPasswordLabel),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFFF0F0F0),
                        fontSize: 15,
                      ),
                      decoration: _inputDecoration(loc.loginPasswordHint).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFF9099B0),
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return loc.loginPasswordEmpty;
                        if (!isLogin && v.length < 6) return loc.loginPasswordShort;
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // ── Error ─────────────────────────────────────────
                    if (state.error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B241C).withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFC0392B).withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFE74C3C), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.error!,
                                style: GoogleFonts.rajdhani(
                                  color: const Color(0xFFE74C3C),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Submit ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC9A84C),
                          foregroundColor: const Color(0xFF0A0C12),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          shadowColor: const Color(0xFFC9A84C).withValues(alpha: 0.4),
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0A0C12),
                          ),
                        )
                            : Text(
                          isLogin
                              ? loc.loginEnterDojo
                              : loc.loginCreateAccount,
                          style: GoogleFonts.rajdhani(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Toggle login/signup ───────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            ref.read(authViewModelProvider.notifier).toggleMode(),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.rajdhani(
                              fontSize: 14,
                              color: Colors.white60,
                            ),
                            children: [
                              TextSpan(
                                text: isLogin
                                    ? loc.loginDontHaveAccount
                                    : loc.loginAlreadyHaveAccount,
                              ),
                              TextSpan(
                                text:
                                isLogin ? loc.loginSignUp : loc.loginLogIn,
                                style: const TextStyle(
                                  color: Color(0xFFC9A84C),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
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
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.rajdhani(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF9099B0),
      letterSpacing: 1.5,
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.rajdhani(
      color: const Color(0xFF4A5068),
      fontSize: 15,
    ),
    filled: true,
    fillColor: const Color(0xFF242B40),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF2A3048)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF2A3048)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:
      const BorderSide(color: Color(0xFFC9A84C), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFC0392B)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:
      const BorderSide(color: Color(0xFFC0392B), width: 1.5),
    ),
    errorStyle: GoogleFonts.rajdhani(
      color: const Color(0xFFE74C3C),
      fontSize: 12,
    ),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
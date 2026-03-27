import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../domain/use_cases/auth/reset_user_data_use_case.dart';
import '../auth/login_screen.dart';
import '../../../infrastructure/repositories/firebase_auth_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = l10n(context);
    final currentLocale  = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0C12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141824),
        title: Text(
          loc.settingsTitle,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 16,
            color: const Color(0xFFC9A84C),
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF9099B0)),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFF2A3048)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [

          // ── LANGUAGE ──────────────────────────────────────────────────
          _SectionHeader(label: loc.settingsLanguage),
          _LanguageTile(
            language: loc.settingsLanguageEnglish,
            locale: const Locale('en'),
            currentLocale: currentLocale,
            flag: '🇺🇸',
            onTap: () => ref.read(localeProvider.notifier).setLocale(
              const Locale('en'),
            ),
          ),
          _LanguageTile(
            language: loc.settingsLanguageSpanish,
            locale: const Locale('es'),
            currentLocale: currentLocale,
            flag: '🇪🇸',
            onTap: () => ref.read(localeProvider.notifier).setLocale(
              const Locale('es'),
            ),
          ),
          const _Divider(),

          // ── SOUND ────────────────────────────────────────────────────
          _SectionHeader(label: 'Audio'),
          _SwitchTile(
            label: loc.settingsSound,
            icon: PhosphorIconsRegular.speakerHigh,
            value: true,
            onChanged: (_) {},
          ),
          _SwitchTile(
            label: loc.settingsMusic,
            icon: PhosphorIconsRegular.musicNote,
            value: true,
            onChanged: (_) {},
          ),
          const _Divider(),



          // ── Reset de datos (solo desarrollo) ─────────────────────────
          const Divider(height: 32, color: AppColors.bgDivider),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.redAction.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.redAction.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_rounded,
                        color: AppColors.warning, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'ZONA DE DESARROLLO',
                      style: GoogleFonts.rajdhani(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmReset(context, ref, loc),
                    icon: const Icon(Icons.delete_forever_rounded,
                        color: AppColors.redLight, size: 18),
                    label: Text(
                      'Borrar todos los datos y reiniciar',
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.redLight,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.redAction.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          
          
          
          // ── ACCOUNT ──────────────────────────────────────────────────
          _SectionHeader(label: loc.settingsAccount),
          _ActionTile(
            label: loc.settingsSignOut,
            icon: PhosphorIconsRegular.signOut,
            color: AppColors.redAction,
            onTap: () => _confirmSignOut(context, ref, loc as AppLocalizations),
          ),
          const _Divider(),

          // ── VERSION ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                '${loc.settingsVersion} 1.0.0',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: const Color(0xFF4A5068),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _confirmReset(BuildContext context, WidgetRef ref, dynamic loc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded,
                color: AppColors.warning, size: 22),
            const SizedBox(width: 8),
            Text(
              '¿Borrar todo?',
              style: GoogleFonts.cinzelDecorative(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Se van a borrar el dojo, todos los estudiantes y el progreso de la cuenta. Esta acción no se puede deshacer.',
          style: GoogleFonts.rajdhani(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.rajdhani(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _doReset(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redAction,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'BORRAR TODO',
              style: GoogleFonts.rajdhani(
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _doReset(BuildContext context, WidgetRef ref) async {
    // Loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.redAction),
      ),
    );

    try {
      await ResetUserDataUseCase().execute();
      // El sign out dispara el AppStateProvider automáticamente
      // → redirige al login sin necesidad de Navigator
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // cierra el loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e',
              style: GoogleFonts.rajdhani(color: Colors.white)),
          backgroundColor: AppColors.redDark,
        ));
      }
    }
  }
  
  
  
  void _confirmSignOut(
      BuildContext context,
      WidgetRef ref,
      AppLocalizations loc,
      ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C2235),
        title: Text(
          loc.settingsSignOut,
          style: GoogleFonts.cinzelDecorative(
            color: const Color(0xFFF0F0F0),
            fontSize: 14,
          ),
        ),
        content: Text(
          loc.settingsSignOutConfirm,
          style: GoogleFonts.rajdhani(
            color: const Color(0xFF9099B0),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              loc.settingsSignOutCancel,
              style: GoogleFonts.rajdhani(
                color: const Color(0xFF9099B0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final repo = FirebaseAuthRepository();
              await repo.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
              );
            },
            child: Text(
              loc.settingsSignOutConfirmBtn,
              style: GoogleFonts.rajdhani(
                color: const Color(0xFFC0392B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SUB-WIDGETS ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.rajdhani(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9099B0),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String language;
  final Locale locale;
  final Locale currentLocale;
  final String flag;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.locale,
    required this.currentLocale,
    required this.flag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentLocale.languageCode == locale.languageCode;

    return ListTile(
      onTap: onTap,
      tileColor: Colors.transparent,
      leading: CountryFlag.fromCountryCode(
        locale.languageCode == 'en' ? 'US' : 'ES',
        width: 32,
        height: 24
      ),
      title: Text(
        language,
        style: GoogleFonts.rajdhani(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isSelected
              ? const Color(0xFFC9A84C)
              : const Color(0xFFF0F0F0),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle,
          color: Color(0xFFC9A84C), size: 20)
          : const Icon(Icons.radio_button_unchecked,
          color: Color(0xFF3A3F52), size: 20),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFC9A84C),
      secondary: Icon(icon, color: const Color(0xFF9099B0), size: 20),
      title: Text(
        label,
        style: GoogleFonts.rajdhani(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF0F0F0),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        label,
        style: GoogleFonts.rajdhani(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      color: Color(0xFF1C2235),
      indent: 20,
      endIndent: 20,
    );
  }
}
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/utils/l10n_helper.dart';
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
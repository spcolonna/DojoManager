import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/messages_provider.dart';
import '../../../core/providers/tournament_provider.dart';
import '../../../core/utils/l10n_helper.dart';
import '../../../domain/entities/message.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc      = l10n(context);
    final messages = ref.watch(messagesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        toolbarHeight: 44,
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.auto_stories_rounded,
                color: AppColors.goldPrimary, size: 16),
            const SizedBox(width: 8),
            Text(
              loc.messagesTitle,
              style: GoogleFonts.cinzelDecorative(
                  fontSize: 14, color: AppColors.goldLight,
                  letterSpacing: 1.2),
            ),
          ],
        ),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.bgDivider),
        ),
      ),
      body: messages.isEmpty
          ? _EmptyInbox(loc: loc)
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _MessageCard(
          message: messages[i],
          loc: loc,
        ),
      ),
    );
  }
}

// ─── BANDEJA VACÍA ────────────────────────────────────────────────────────────

class _EmptyInbox extends StatelessWidget {
  final dynamic loc;
  const _EmptyInbox({required this.loc});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pergamino decorativo
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.goldPrimary.withValues(alpha: 0.25),
                      width: 1.5),
                ),
                child: const Icon(Icons.auto_stories_rounded,
                    color: AppColors.goldMuted, size: 36),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            loc.messagesEmpty,
            style: GoogleFonts.cinzelDecorative(
                fontSize: 16, fontWeight: FontWeight.bold,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            loc.messagesEmptySubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.rajdhani(
                fontSize: 13, color: AppColors.textTertiary, height: 1.5),
          ),
          const SizedBox(height: 32),
          // Decoración de líneas tipo pergamino
          _ParchmentLines(),
        ],
      ),
    );
  }
}

class _ParchmentLines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(4, (i) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        width: 160 - i * 20.0,
        height: 2,
        decoration: BoxDecoration(
          color: AppColors.bgDivider,
          borderRadius: BorderRadius.circular(1),
        ),
      )),
    );
  }
}

// ─── CARD DE MENSAJE ──────────────────────────────────────────────────────────

class _MessageCard extends ConsumerWidget {
  final AppMessage message;
  final dynamic loc;
  const _MessageCard({required this.message, required this.loc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnread = !message.isRead;
    final config   = _configFor(message.type);

    return GestureDetector(
      onTap: () {
        if (isUnread) {
          ref.read(messagesProvider.notifier).markRead(message.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isUnread
              ? config.color.withValues(alpha: 0.06)
              : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread
                ? config.color.withValues(alpha: 0.35)
                : AppColors.bgDivider,
            width: isUnread ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  // Sello de tipo
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: config.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: config.color.withValues(alpha: 0.3)),
                    ),
                    child: Icon(config.icon, color: config.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _titleFor(message, loc),
                                style: GoogleFonts.cinzelDecorative(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isUnread
                                        ? config.color
                                        : AppColors.textSecondary),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: config.color,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(
                                      color: config.color, blurRadius: 6)],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(message.createdAt),
                          style: GoogleFonts.rajdhani(
                              fontSize: 10, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Separador decorativo ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Container(
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                          color: config.color.withValues(alpha: 0.4),
                          shape: BoxShape.circle)),
                  Expanded(child: Container(
                      height: 1,
                      color: AppColors.bgDivider.withValues(alpha: 0.5))),
                  Container(
                      width: 4, height: 4,
                      decoration: BoxDecoration(
                          color: config.color.withValues(alpha: 0.4),
                          shape: BoxShape.circle)),
                ],
              ),
            ),

            // ── Cuerpo ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _bodyFor(message, loc),
                    style: GoogleFonts.rajdhani(
                        fontSize: 13, color: AppColors.textSecondary,
                        height: 1.5),
                  ),

                  // ── Acción según tipo ──────────────────────────
                  if (message.type == MessageType.tournamentInvite &&
                      isUnread) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final notifier = ref.read(
                              tournamentProvider.notifier);
                          final msgNotifier = ref.read(
                              messagesProvider.notifier);
                          await notifier.initLeague();
                          await msgNotifier.markRead(message.id);
                        },
                        icon: Icon(config.icon, size: 14),
                        label: Text(
                          loc.tournamentInviteAccept,
                          style: GoogleFonts.rajdhani(
                              fontSize: 13, fontWeight: FontWeight.w800,
                              letterSpacing: 1),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: config.color,
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _titleFor(AppMessage msg, dynamic loc) => switch (msg.type) {
    MessageType.tournamentInvite => loc.msgLeagueInviteTitle,
    MessageType.cupInvite        => loc.msgCupInviteTitle,
    MessageType.devMessage       => loc.msgDevTitle,
    MessageType.system           => loc.msgSystemTitle,
  };

  String _bodyFor(AppMessage msg, dynamic loc) {
    final style  = msg.params['style']  as String? ?? '';
    final season = msg.params['season'] as int?    ?? 1;
    return switch (msg.type) {
      MessageType.tournamentInvite =>
          loc.msgLeagueInviteBody(style, season),
      MessageType.cupInvite        => loc.msgCupInviteBody,
      MessageType.devMessage       => msg.bodyKey,
      MessageType.system           => msg.bodyKey,
    };
  }

  String _formatDate(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60)  return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24)    return 'Hace ${diff.inHours}h';
    if (diff.inDays == 1)     return 'Ayer';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  _MessageConfig _configFor(MessageType type) => switch (type) {
    MessageType.tournamentInvite => const _MessageConfig(
        AppColors.goldPrimary, Icons.emoji_events_rounded),
    MessageType.cupInvite        => const _MessageConfig(
        AppColors.purple, Icons.public_rounded),
    MessageType.devMessage       => const _MessageConfig(
        AppColors.infoLight, Icons.auto_stories_rounded),
    MessageType.system           => const _MessageConfig(
        AppColors.textSecondary, Icons.info_outline_rounded),
  };
}

class _MessageConfig {
  final Color color;
  final IconData icon;
  const _MessageConfig(this.color, this.icon);
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/message.dart';
import '../../infrastructure/repositories/firebase_dojo_repository.dart';

class MessagesNotifier extends StateNotifier<List<AppMessage>> {
  final _repo = FirebaseDojoRepository();

  MessagesNotifier() : super([]) {
    load();
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) return;
    final msgs = await _repo.getMessages(uid);
    state = msgs;
  }

  Future<void> markRead(String messageId) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.markMessageRead(uid, messageId);
    state = state.map((m) =>
    m.id == messageId ? m.copyWith(isRead: true) : m).toList();
  }

  Future<void> sendTournamentInvite({
    required String styleId,
    required int season,
    required String styleName,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final msg = AppMessage(
      id: 'league_invite_s${season}_$styleId',
      type: MessageType.tournamentInvite,
      titleKey: 'msgLeagueInviteTitle',
      bodyKey: 'msgLeagueInviteBody',
      params: {'style': styleName, 'season': season},
      isRead: false,
      createdAt: DateTime.now(),
    );
    await _repo.addMessage(uid, msg);
    state = [msg, ...state];
  }

  int get unreadCount => state.where((m) => !m.isRead).length;
}

final messagesProvider =
StateNotifierProvider<MessagesNotifier, List<AppMessage>>((ref) {
  return MessagesNotifier();
});

final unreadMessagesProvider = Provider<int>((ref) {
  return ref.watch(messagesProvider.notifier).unreadCount;
});
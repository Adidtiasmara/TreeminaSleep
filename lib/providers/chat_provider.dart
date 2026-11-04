import 'package:flutter/foundation.dart';
import '../services/ai_chat_service.dart';

class ChatMessage {
  final bool isUser;
  final String text;

  const ChatMessage({required this.isUser, required this.text});
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  int _remainingQuota = 0;
  int _quotaLimit = 30;
  bool _quotaLoaded = false;
  bool _isSending = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  int get remainingQuota => _remainingQuota;
  int get quotaLimit => _quotaLimit;
  bool get quotaLoaded => _quotaLoaded;
  bool get isSending => _isSending;
  bool get isQuotaExhausted => _quotaLoaded && _remainingQuota <= 0;

  /// Ambil sisa kuota dari server saat halaman dibuka.
  Future<void> loadQuota() async {
    try {
      final quota = await AiChatService.fetchQuota();
      _remainingQuota = quota.remaining;
      _quotaLimit = quota.limit;
      _quotaLoaded = true;
    } on AiChatException catch (_) {
      // Kuota tetap ditampilkan sebagai tersedia; server yang memutus saat kirim.
      _quotaLoaded = true;
    } catch (_) {
      // Jaringan belum siap; coba lagi pada pengiriman pertama.
    }
    notifyListeners();
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending || isQuotaExhausted) return;

    _messages.add(ChatMessage(isUser: true, text: trimmed));
    _isSending = true;
    notifyListeners();

    try {
      final reply = await AiChatService.sendMessage(
        _messages.map((m) => (isUser: m.isUser, text: m.text)).toList(),
      );
      _messages.add(ChatMessage(isUser: false, text: reply.text));
      if (reply.remaining != null) {
        _remainingQuota = reply.remaining!;
        _quotaLoaded = true;
      }
      if (reply.limit != null) _quotaLimit = reply.limit!;
    } on AiChatException catch (error) {
      if (error.isQuotaExhausted) {
        _remainingQuota = 0;
        _quotaLoaded = true;
      }
      _messages.add(ChatMessage(isUser: false, text: error.message));
    } catch (_) {
      _messages.add(
        const ChatMessage(
          isUser: false,
          text: 'Asisten sedang tidak bisa dihubungi. Coba lagi sebentar.',
        ),
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}

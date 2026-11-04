import 'package:supabase_flutter/supabase_flutter.dart';

class AiChatException implements Exception {
  final String message;
  final bool isQuotaExhausted;

  const AiChatException(this.message, {this.isQuotaExhausted = false});

  @override
  String toString() => message;
}

class AiChatReply {
  final String text;
  final int? remaining;
  final int? limit;

  const AiChatReply({required this.text, this.remaining, this.limit});
}

/// Jembatan ke Edge Function `ai-chat`. Kunci AI tidak pernah disimpan di
/// aplikasi; semua pemanggilan model lewat Supabase dengan sesi user aktif.
class AiChatService {
  static const String _functionName = 'ai-chat';

  /// Sisa kuota dan limit harian dari server (untuk indikator di UI).
  static Future<({int remaining, int limit})> fetchQuota() async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        _functionName,
        method: HttpMethod.get,
      );
      final data = response.data;
      if (data is Map && data['remaining'] is num && data['limit'] is num) {
        return (
          remaining: (data['remaining'] as num).toInt(),
          limit: (data['limit'] as num).toInt(),
        );
      }
      throw const AiChatException('Kuota tidak bisa dibaca.');
    } on FunctionException catch (error) {
      throw AiChatException(_messageFor(error));
    }
  }

  /// Kirim riwayat percakapan, terima jawaban asisten + sisa kuota terbaru.
  static Future<AiChatReply> sendMessage(
    List<({bool isUser, String text})> history,
  ) async {
    // Batasi konteks ke 20 giliran terakhir agar request tetap ringan.
    final trimmed = history.length > 20
        ? history.sublist(history.length - 20)
        : history;

    try {
      final response = await Supabase.instance.client.functions.invoke(
        _functionName,
        body: {
          'messages': trimmed
              .map((turn) => {
                    'role': turn.isUser ? 'user' : 'assistant',
                    'text': turn.text,
                  })
              .toList(),
        },
      );
      final data = response.data;
      if (data is Map && data['reply'] is String) {
        return AiChatReply(
          text: data['reply'] as String,
          remaining: data['remaining'] is num
              ? (data['remaining'] as num).toInt()
              : null,
          limit: data['limit'] is num ? (data['limit'] as num).toInt() : null,
        );
      }
      throw const AiChatException('Respons asisten tidak bisa dibaca.');
    } on FunctionException catch (error) {
      if (error.status == 429) {
        throw const AiChatException(
          'Kuota harian habis. Kuota terreset tengah malam.',
          isQuotaExhausted: true,
        );
      }
      throw AiChatException(_messageFor(error));
    }
  }

  static String _messageFor(FunctionException error) {
    switch (error.status) {
      case 401:
        return 'Sesi berakhir. Silakan login ulang.';
      case 400:
        return 'Percakapan tidak valid.';
      default:
        return 'Asisten sedang tidak bisa dihubungi. Coba lagi sebentar.';
    }
  }
}

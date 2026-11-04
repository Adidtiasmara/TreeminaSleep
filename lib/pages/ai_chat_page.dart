import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/sleep_visuals.dart';

class AiChatPage extends StatelessWidget {
  const AiChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider()..loadQuota(),
      child: const _AiChatView(),
    );
  }
}

class _AiChatView extends StatefulWidget {
  const _AiChatView();

  @override
  State<_AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<_AiChatView> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _send(ChatProvider provider, String text) {
    provider.send(text);
    _inputCtrl.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(isDark: isDark),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, _) {
                  if (provider.messages.length != _lastMessageCount) {
                    _lastMessageCount = provider.messages.length;
                    _scrollToBottom();
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: provider.messages.isEmpty
                            ? _EmptyState(
                                isDark: isDark,
                                primaryColor: primaryColor,
                                onPromptTap: (prompt) => _send(provider, prompt),
                              )
                            : _MessageList(isDark: isDark),
                      ),
                      _QuotaBar(isDark: isDark),
                      _InputBar(
                        isDark: isDark,
                        inputCtrl: _inputCtrl,
                        onSend: () => _send(provider, _inputCtrl.text),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark;

  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: SizedBox(
        height: 96,
        width: double.infinity,
        child: NightScape(
          isDark: isDark,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Asisten Tidur',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Rekomendasi personal dari data tidurmu',
                              style: TextStyle(
                                color: Colors.white.withOpacity(.82),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.smart_toy_outlined,
                        color: Colors.white.withOpacity(.9),
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Color primaryColor;
  final ValueChanged<String> onPromptTap;

  const _EmptyState({
    required this.isDark,
    required this.primaryColor,
    required this.onPromptTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy_outlined, color: primaryColor, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              'Halo, ada yang bisa kubantu?',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Aku membaca riwayat tidurmu untuk memberi\nrekomendasi yang pas untukmu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryColor, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final prompt in _quickPromptsList)
                  _PromptChip(label: prompt, onTap: () => onPromptTap(prompt)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _quickPromptsList = [
    'Analisis tidurku minggu ini',
    'Kenapa aku sulit tidur?',
    'Buatkan rutinitas malam',
    'Apa itu siklus tidur?',
  ];
}

class _PromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PromptChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Material(
      color: primaryColor.withOpacity(.10),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Text(
            label,
            style: TextStyle(
              color: primaryColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Message list ─────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final bool isDark;

  const _MessageList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      itemCount: provider.messages.length + (provider.isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (provider.isSending && index == provider.messages.length) {
          return const _TypingBubble();
        }
        final message = provider.messages[index];
        return _MessageBubble(message: message, isDark: isDark);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;

  const _MessageBubble({required this.message, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final bubbleColor = message.isUser
        ? primaryColor
        : (isDark ? AppColors.cardDark : AppColors.cardLight);
    final textColor = message.isUser
        ? (isDark ? AppColors.backgroundDark : Colors.white)
        : (isDark ? AppColors.textDark : AppColors.textLight);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .78,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 5),
            bottomRight: Radius.circular(message.isUser ? 5 : 16),
          ),
          border: Border.all(
            color: message.isUser
                ? Colors.transparent
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: textColor,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(5),
          ),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: const SizedBox(
          width: 34,
          height: 14,
          child: _TypingDots(),
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 3; i++)
              Opacity(
                opacity: (0.3 + 0.7 *
                        (((_ctrl.value * 3 - i) % 1).abs().clamp(0.0, 1.0)))
                    .clamp(0.0, 1.0),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Quota indicator ──────────────────────────────────────────────────────────

class _QuotaBar extends StatelessWidget {
  final bool isDark;

  const _QuotaBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
      child: Row(
        children: [
          Icon(Icons.data_usage_rounded, size: 14, color: secondaryColor),
          const SizedBox(width: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              provider.quotaLoaded
                  ? 'Sisa ${provider.remainingQuota}/${provider.quotaLimit} pesan hari ini'
                  : 'Memeriksa kuota...',
              key: ValueKey(
                'quota-${provider.quotaLoaded}-${provider.remainingQuota}',
              ),
              style: TextStyle(
                color: provider.isQuotaExhausted
                    ? (isDark ? AppColors.badSleepDark : AppColors.badSleepLight)
                    : secondaryColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => provider.loadQuota(),
            child: Icon(
              Icons.refresh_rounded,
              size: 16,
              color: primaryColor.withOpacity(.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final bool isDark;
  final TextEditingController inputCtrl;
  final VoidCallback onSend;

  const _InputBar({
    required this.isDark,
    required this.inputCtrl,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    final exhausted = provider.isQuotaExhausted;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: exhausted
          ? Container(
              key: const ValueKey('exhausted'),
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: (isDark
                        ? AppColors.badSleepDark
                        : AppColors.badSleepLight)
                    .withOpacity(.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isDark
                          ? AppColors.badSleepDark
                          : AppColors.badSleepLight)
                      .withOpacity(.35),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_clock_rounded,
                    size: 18,
                    color: isDark ? AppColors.badSleepDark : AppColors.badSleepLight,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kuota harian habis. Aku menunggumu lagi tengah malam nanti.',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.badSleepDark
                            : AppColors.badSleepLight,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              key: const ValueKey('input'),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      enabled: !provider.isSending,
                      style: TextStyle(
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                        fontSize: 13.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tulis pertanyaanmu...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontSize: 13.5,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: provider.isSending ? null : onSend,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: provider.isSending
                          ? const Padding(
                              padding: EdgeInsets.all(11),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

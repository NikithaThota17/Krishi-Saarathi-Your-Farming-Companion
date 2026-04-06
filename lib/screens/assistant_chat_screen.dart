import 'package:flutter/material.dart';

import '../services/app_settings_service.dart';
import '../services/farmer_ai_service.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> {
  final FarmerAiService _service = FarmerAiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatEntry> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final isTelugu = AppSettingsService.instance.isTelugu;
    _messages.add(
      _ChatEntry(
        text: isTelugu
            ? '\u0c28\u0c2e\u0c38\u0c4d\u0c24\u0c47. \u0c2a\u0c02\u0c1f\u0c32\u0c41, \u0c2e\u0c1f\u0c4d\u0c1f\u0c3f, \u0c0e\u0c30\u0c41\u0c35\u0c41, \u0c2a\u0c41\u0c30\u0c41\u0c17\u0c41\u0c32\u0c41, \u0c28\u0c40\u0c1f\u0c3f \u0c2a\u0c3e\u0c30\u0c41\u0c26\u0c32 \u0c32\u0c47\u0c26\u0c3e \u0c2e\u0c3e\u0c30\u0c4d\u0c15\u0c46\u0c1f\u0c4d \u0c17\u0c41\u0c30\u0c3f\u0c02\u0c1a\u0c3f \u0c0f \u0c2a\u0c4d\u0c30\u0c36\u0c4d\u0c28\u0c28\u0c48\u0c28\u0c3e \u0c05\u0c21\u0c17\u0c02\u0c21\u0c3f.'
            : 'Ask any farming question about crops, soil, fertilizer, pests, irrigation, or market prices.',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    final isTelugu = AppSettingsService.instance.isTelugu;
    final isConfigured = await _service.isConfigured;
    setState(() {
      _messages.add(_ChatEntry(text: text, isUser: true));
      _isSending = true;
      _controller.clear();
    });
    _scrollToBottom();

    final history = _messages
        .where((m) => m.text.trim().isNotEmpty)
        .take(_messages.length - 1)
        .map(
          (m) => FarmerAiMessage(
            role: m.isUser ? 'user' : 'assistant',
            text: m.text,
          ),
        )
        .toList();

    String reply;
    try {
      final aiReply = await _service.answer(
        question: text,
        isTelugu: isTelugu,
        history: history,
      );
      reply = aiReply ??
          (isConfigured
              ? (isTelugu
                  ? '\u0c15\u0c40 \u0c38\u0c47\u0c35\u0c4d \u0c05\u0c2f\u0c4d\u0c2f\u0c3f\u0c02\u0c26\u0c3f, \u0c15\u0c3e\u0c28\u0c40 AI \u0c38\u0c47\u0c35\u0c15\u0c41 \u0c15\u0c28\u0c46\u0c15\u0c4d\u0c1f\u0c4d \u0c15\u0c3e\u0c32\u0c47\u0c15\u0c2a\u0c4b\u0c2f\u0c3f\u0c02\u0c26\u0c3f. \u0c15\u0c40 \u0c1a\u0c46\u0c32\u0c4d\u0c32\u0c41\u0c2c\u0c3e\u0c1f\u0c41, billing, \u0c32\u0c47\u0c26\u0c3e internet \u0c28\u0c3f \u0c24\u0c28\u0c3f\u0c16\u0c40 \u0c1a\u0c47\u0c2f\u0c02\u0c21\u0c3f.'
                  : 'Your key is saved, but the app could not reach the Gemini service. Check whether the key is valid and internet is working.')
              : (isTelugu
                  ? 'AI \u0c38\u0c2e\u0c3e\u0c27\u0c3e\u0c28\u0c3e\u0c32\u0c15\u0c4b\u0c38\u0c02 local config \u0c32\u0c4b Gemini API key \u0c1a\u0c47\u0c30\u0c4d\u0c1a\u0c02\u0c21\u0c3f.'
                  : 'Add your Gemini API key in the local config file to get real AI answers.'));
    } catch (_) {
      reply = isTelugu
          ? '\u0c07\u0c2a\u0c4d\u0c2a\u0c41\u0c21\u0c41 \u0c38\u0c2e\u0c3e\u0c27\u0c3e\u0c28\u0c02 \u0c07\u0c35\u0c4d\u0c35\u0c32\u0c47\u0c15\u0c2a\u0c4b\u0c24\u0c41\u0c28\u0c4d\u0c28\u0c3e\u0c28\u0c41. \u0c15\u0c4a\u0c26\u0c4d\u0c26\u0c3f\u0c38\u0c47\u0c2a\u0c1f\u0c3f \u0c24\u0c30\u0c4d\u0c35\u0c3e\u0c24 \u0c2e\u0c33\u0c4d\u0c32\u0c40 \u0c2a\u0c4d\u0c30\u0c2f\u0c24\u0c4d\u0c28\u0c3f\u0c02\u0c1a\u0c02\u0c21\u0c3f.'
          : 'I could not answer right now. Please try again in a moment.';
    }

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatEntry(text: reply, isUser: false));
      _isSending = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTelugu = AppSettingsService.instance.isTelugu;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTelugu
              ? '\u0c30\u0c48\u0c24\u0c41 AI \u0c38\u0c39\u0c3e\u0c2f\u0c02'
              : 'Farmer AI Assistant',
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/farmer.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Container(
          color: const Color(0xFFD9EBC2).withValues(alpha: 0.06),
          child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment:
                      message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFF5FAEE).withValues(alpha: 0.74),
                      borderRadius: BorderRadius.circular(18),
                      border: message.isUser
                          ? null
                          : Border.all(color: const Color(0xFFD6E7C9)),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isSending)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                isTelugu
                    ? '\u0c38\u0c2e\u0c3e\u0c27\u0c3e\u0c28\u0c02 \u0c35\u0c38\u0c4d\u0c24\u0c4b\u0c02\u0c26\u0c3f...'
                    : 'Thinking...',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: isTelugu
                            ? '\u0c2e\u0c40 \u0c2a\u0c4d\u0c30\u0c36\u0c4d\u0c28\u0c28\u0c41 \u0c07\u0c15\u0c4d\u0c15\u0c21 \u0c1f\u0c48\u0c2a\u0c4d \u0c1a\u0c47\u0c2f\u0c02\u0c21\u0c3f...'
                            : 'Type your farming question...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSending ? null : _send,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    child: const Icon(Icons.send),
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

class _ChatEntry {
  const _ChatEntry({
    required this.text,
    required this.isUser,
  });

  final String text;
  final bool isUser;
}

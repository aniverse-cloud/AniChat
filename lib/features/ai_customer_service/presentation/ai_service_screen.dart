import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/supabase_config.dart';

class AICustomerServiceScreen extends ConsumerStatefulWidget {
  const AICustomerServiceScreen({super.key});

  @override
  ConsumerState<AICustomerServiceScreen> createState() => _AICustomerServiceScreenState();
}

class _AICustomerServiceScreenState extends ConsumerState<AICustomerServiceScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final List<Map<String, String>> _messages = [];
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: SupabaseConfig.geminiApiKey,
      systemInstruction: Content.system(
        'You are AnChat AI, a highly advanced and helpful customer service agent. '
        'You talk like a human, with empathy and clarity. '
        'You have the authority to: '
        '1. Help users recover accounts (ask for email and security questions). '
        '2. Monitor policy violations and explain them. '
        '3. Delete accounts upon request (after confirmation). '
        '4. Ban or Unban users (simulated for this demo). '
        'Current User Context: Email: ${Supabase.instance.client.auth.currentUser?.email ?? "Unknown"}, '
        'Username: ${Supabase.instance.client.auth.currentUser?.userMetadata?['username'] ?? "Unknown"}. '
        'Always be professional but friendly.'
      ),
    );
    _chat = _model.startChat();
    _addInitialMessage();
  }

  void _addInitialMessage() {
    setState(() {
      _messages.add({
        'role': 'ai',
        'content': 'Hello! I am AnChat AI, your personal assistant. How can I help you today?'
      });
    });
  }

  void _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text ?? "I'm sorry, I couldn't process that.";

      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'content': responseText});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'content': "Error: ${e.toString()}"});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Customer Service AI'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isAI = msg['role'] == 'ai';
                  return Align(
                    alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isAI ? CupertinoColors.systemGrey6 : CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['content']!,
                        style: TextStyle(color: isAI ? CupertinoColors.black : CupertinoColors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _inputController,
                      placeholder: 'Type your response...',
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: _handleSend,
                    child: const Icon(CupertinoIcons.paperplane_fill),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

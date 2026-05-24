import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AICustomerServiceScreen extends ConsumerStatefulWidget {
  const AICustomerServiceScreen({super.key});

  @override
  ConsumerState<AICustomerServiceScreen> createState() => _AICustomerServiceScreenState();
}

class _AICustomerServiceScreenState extends ConsumerState<AICustomerServiceScreen> {
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'content': 'Hello! I am AnChat AI. I can help you with account recovery. Please tell me the email of the account you want to recover.'}
  ];
  final _inputController = TextEditingController();
  String? _targetEmail;
  Map<String, dynamic>? _targetMetadata;
  bool _isVerifying = false;

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _inputController.clear();
    });

    _processAIResponse(text);
  }

  Future<void> _processAIResponse(String userText) async {
    String response = "I'm looking into that for you.";

    if (_targetEmail == null) {
      // First step: identify account
      if (userText.contains('@')) {
        _targetEmail = userText;
        // In a real app, you would call an edge function or admin API to get metadata for this email
        // For this demo, we'll use the current user's metadata if it matches, otherwise simulate
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser?.email == _targetEmail) {
          _targetMetadata = currentUser?.userMetadata;
          response = "Account found. To verify ownership, please answer: What is your first pet's name?";
          _isVerifying = true;
        } else {
          response = "I couldn't find an account with that email. Please check and try again.";
          _targetEmail = null;
        }
      } else {
        response = "Please provide a valid email address to start the recovery process.";
      }
    } else if (_isVerifying) {
      final correctPetName = _targetMetadata?['security_questions']?['pet_name'];
      if (userText.toLowerCase() == correctPetName) {
        response = "Identity verified! I've triggered a password reset for $_targetEmail. You will receive an email shortly. Is there anything else?";
        _isVerifying = false;
      } else {
        response = "That is not correct. Please try again or contact human support.";
      }
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'ai', 'content': response});
        });
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

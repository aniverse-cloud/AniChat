import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminPanel extends ConsumerStatefulWidget {
  final String adminLevel;

  const AdminPanel({super.key, required this.adminLevel});

  @override
  ConsumerState<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends ConsumerState<AdminPanel> {
  final _userIdController = TextEditingController();

  Future<void> _banUser(String userId) async {
    // Logic to ban user in Supabase
  }

  Future<void> _generateAdminLink() async {
    // Logic to generate unique link for lower admins
    final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    final link = 'anchat://admin/join/$uniqueId';

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Admin Link Generated'),
        content: Text(link),
        actions: [
          CupertinoDialogAction(
            child: const Text('Copy'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Admin Panel (${widget.adminLevel})'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.adminLevel == 'Executive') ...[
              const Text('Executive Controls', style: TextStyle(fontWeight: FontWeight.bold)),
              CupertinoButton(
                onPressed: _generateAdminLink,
                child: const Text('Generate Lower Admin Link'),
              ),
              const SizedBox(height: 20),
            ],
            const Text('Moderation', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _userIdController,
              placeholder: 'User ID to Ban/Unban',
            ),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    onPressed: () => _banUser(_userIdController.text),
                    child: const Text('Ban', style: TextStyle(color: CupertinoColors.destructiveRed)),
                  ),
                ),
                Expanded(
                  child: CupertinoButton(
                    onPressed: () {},
                    child: const Text('Unban'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

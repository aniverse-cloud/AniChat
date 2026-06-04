import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../ui/widgets/glass_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};
    _usernameController.text = metadata['username'] ?? '';
    _phoneController.text = metadata['phone'] ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      await client.auth.updateUser(
        UserAttributes(
          data: {
            'username': _usernameController.text.trim(),
            'phone': _phoneController.text.trim(),
          },
        ),
      );
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text('Profile updated successfully'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: GlassmorphicBackground(
        child: CustomScrollView(
          slivers: [
            const CupertinoSliverNavigationBar(
              largeTitle: Text('Edit Profile', style: TextStyle(color: CupertinoColors.white)),
              backgroundColor: CupertinoColors.transparent,
              border: null,
              previousPageTitle: 'Settings',
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            CupertinoTextField(
                              controller: _usernameController,
                              placeholder: 'Username',
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(CupertinoIcons.person, color: CupertinoColors.white),
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              style: const TextStyle(color: CupertinoColors.white),
                              placeholderStyle: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)),
                            ),
                            const SizedBox(height: 16),
                            CupertinoTextField(
                              controller: _phoneController,
                              placeholder: 'Phone Number',
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(CupertinoIcons.phone, color: CupertinoColors.white),
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoColors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              style: const TextStyle(color: CupertinoColors.white),
                              placeholderStyle: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GlassCard(
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: CupertinoButton(
                          onPressed: _loading ? null : _updateProfile,
                          child: _loading
                            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                            : const Text('Save Changes', style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

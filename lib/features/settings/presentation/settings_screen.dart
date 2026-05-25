import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // Vibrant Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CupertinoColors.systemBlue,
                  CupertinoColors.systemPurple,
                  CupertinoColors.systemPink,
                ],
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              const CupertinoSliverNavigationBar(
                largeTitle: Text('Settings', style: TextStyle(color: CupertinoColors.white)),
                backgroundColor: CupertinoColors.transparent,
                border: null,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileSection(context),
                      const SizedBox(height: 20),
                      _buildGlassCard(
                        child: Column(
                          children: [
                            CupertinoListTile(
                              title: const Text('Edit Profile', style: TextStyle(color: CupertinoColors.white)),
                              leading: const Icon(CupertinoIcons.person_crop_circle_badge_plus, color: CupertinoColors.white),
                              trailing: const CupertinoListTileChevron(),
                              onTap: () => context.push('/edit-profile'),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 60.0),
                              child: Container(
                                height: 1,
                                color: CupertinoColors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            CupertinoListTile(
                              title: const Text('Customer Service AI', style: TextStyle(color: CupertinoColors.white)),
                              leading: const Icon(CupertinoIcons.ant_fill, color: CupertinoColors.white),
                              trailing: const CupertinoListTileChevron(),
                              onTap: () => context.push('/ai-service'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildGlassCard(
                        child: CupertinoButton(
                          child: const Text('Sign Out', style: TextStyle(color: CupertinoColors.systemRed, fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            try {
                              await Supabase.instance.client.auth.signOut();
                            } catch (_) {}
                            if (context.mounted) context.go('/login');
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onLongPress: () => context.push('/admin/Executive'),
                        child: const Text(
                          'AnChat v1.0.1',
                          style: TextStyle(color: CupertinoColors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};
    final username = metadata['username'] ?? 'User';
    final phone = metadata['phone'] ?? 'No phone number';

    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.white.withValues(alpha: 0.2),
                border: Border.all(color: CupertinoColors.white, width: 2),
              ),
              child: const Icon(CupertinoIcons.person_fill, size: 40, color: CupertinoColors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: TextStyle(
                      color: CupertinoColors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CupertinoColors.white.withValues(alpha: 0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}

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
                      _buildGlassCard(
                        child: Column(
                          children: [
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

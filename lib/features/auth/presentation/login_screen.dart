import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../ui/widgets/glass_widgets.dart';
import '../domain/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      if (mounted) context.go('/chats');
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: GlassmorphicBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'AnChat',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 40),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CupertinoTextField(
                        controller: _emailController,
                        placeholder: 'Email',
                        placeholderStyle: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)),
                        style: const TextStyle(color: CupertinoColors.white),
                        keyboardType: TextInputType.emailAddress,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CupertinoTextField(
                        controller: _passwordController,
                        placeholder: 'Password',
                        placeholderStyle: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)),
                        style: const TextStyle(color: CupertinoColors.white),
                        obscureText: true,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : SizedBox(
                              width: double.infinity,
                              child: CupertinoButton(
                                color: CupertinoColors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                onPressed: _login,
                                child: const Text('Sign In', style: TextStyle(color: CupertinoColors.white)),
                              ),
                            ),
                    ],
                  ),
                ),
                CupertinoButton(
                  onPressed: () => context.push('/register'),
                  child: const Text('Don\'t have an account? Sign Up', style: TextStyle(color: CupertinoColors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

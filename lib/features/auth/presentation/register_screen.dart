import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/auth_service.dart';
import '../../../ui/widgets/glass_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _petNameController = TextEditingController();
  final _birthCityController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        securityQuestions: {
          'pet_name': _petNameController.text.trim().toLowerCase(),
          'birth_city': _birthCityController.text.trim().toLowerCase(),
        },
      );

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text('Account created! Please check your email for verification.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/login');
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: GlassmorphicBackground(
        child: CustomScrollView(
          slivers: [
            const CupertinoSliverNavigationBar(
              largeTitle: Text('Create Account',
                  style: TextStyle(color: CupertinoColors.white)),
              backgroundColor: CupertinoColors.transparent,
              border: null,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CupertinoTextField(
                        controller: _usernameController,
                        placeholder: 'Username',
                        padding: const EdgeInsets.all(12),
                        style: const TextStyle(color: CupertinoColors.white),
                        placeholderStyle: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CupertinoTextField(
                        controller: _phoneController,
                        placeholder: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        padding: const EdgeInsets.all(12),
                        style: const TextStyle(color: CupertinoColors.white),
                        placeholderStyle: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CupertinoTextField(
                        controller: _emailController,
                        placeholder: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        padding: const EdgeInsets.all(12),
                        style: const TextStyle(color: CupertinoColors.white),
                        placeholderStyle: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CupertinoTextField(
                        controller: _passwordController,
                        placeholder: 'Password',
                        obscureText: true,
                        padding: const EdgeInsets.all(12),
                        style: const TextStyle(color: CupertinoColors.white),
                        placeholderStyle: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Security Questions (for AI Recovery)',
                    style: TextStyle(fontWeight: FontWeight.bold, color: CupertinoColors.white)),
                const SizedBox(height: 8),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CupertinoTextField(
                        controller: _petNameController,
                        placeholder: 'What is your first pet\'s name?',
                        padding: const EdgeInsets.all(12),
                        style: const TextStyle(color: CupertinoColors.white),
                        placeholderStyle: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoTextField(
                        controller: _birthCityController,
                        placeholder: 'What city were you born in?',
                        padding: const EdgeInsets.all(12),
                        style: const TextStyle(color: CupertinoColors.white),
                        placeholderStyle: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.5)),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : Container(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          onPressed: _register,
                          child: const Text('Sign Up'),
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

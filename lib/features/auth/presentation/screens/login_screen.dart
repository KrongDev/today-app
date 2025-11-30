import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Listen for state changes to navigate
    ref.listen(authProvider, (previous, next) {
      if (next.value != null) {
        context.go('/'); // Go to Home on success
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Today',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              if (authState.isLoading)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton(
                  onPressed: () {
                    // Mock Google Login
                    ref.read(authProvider.notifier).login('google', 'mock_token');
                  },
                  child: const Text('Sign in with Google'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.go('/'); // Guest Mode
                  },
                  child: const Text('Continue as Guest'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';

class AdminLoginScreen extends ConsumerWidget {
  AdminLoginScreen({Key? key}) : super(key: key);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider); // re-using from OTR

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.admin_panel_settings, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Admin Portal',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Nodal Officer Login (L1 / L2)',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: isLoading ? null : () => _handleLogin(ref, context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Login securely', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(WidgetRef ref, BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    ref.read(isLoadingProvider.notifier).state = true;

    try {
      // Simulate network delay for realism
      await Future.delayed(const Duration(seconds: 1));

      // Hardcoded secure credentials for hackathon demo
      // (works fully offline / on Vercel without a backend)
      final validCredentials = {
        'institute@mota.gov.in': {'password': 'Admin@123', 'role': 'L1_INSTITUTE', 'fullName': 'Institute Nodal Officer'},
        'district@mota.gov.in': {'password': 'Admin@123', 'role': 'L2_DISTRICT', 'fullName': 'District Nodal Officer'},
      };

      if (validCredentials.containsKey(email) &&
          validCredentials[email]!['password'] == password) {
        final fullName = validCredentials[email]!['fullName']!;
        await ref.read(authProvider.notifier).login('mock_jwt_token', 'ADMIN', fullName);
        if (context.mounted) {
          context.go('/admin-dashboard');
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Credentials'), backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }
}

// Re-using a simple loading provider for the UI
final isLoadingProvider = StateProvider<bool>((ref) => false);



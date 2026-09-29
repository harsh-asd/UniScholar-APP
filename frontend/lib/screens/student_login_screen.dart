import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class StudentLoginScreen extends ConsumerStatefulWidget {
  const StudentLoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends ConsumerState<StudentLoginScreen> {
  final _otrController = TextEditingController();
  final _otpController = TextEditingController();
  final _captchaController = TextEditingController();
  bool _otpSent = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Login'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Login using OTR'),
              Tab(text: 'Login using Aadhaar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLoginTab(context, isOtr: true),
            _buildLoginTab(context, isOtr: false),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab(BuildContext context, {required bool isOtr}) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isOtr ? 'Enter OTR Number*' : 'Enter Aadhaar No.*',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _otrController,
                  decoration: InputDecoration(
                    hintText: isOtr ? 'e.g. 20261234567890' : '12-digit Aadhaar',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() => _otpSent = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP sent to registered mobile number!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: const Text('Send OTP'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Enter OTP*', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _otpController,
            enabled: _otpSent,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              hintText: '6-digit OTP',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          // Captcha Mock UI
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'N S 1 U Y U',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 4,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Enter Captcha Code*', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _captchaController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Captcha Validation
              final enteredCaptcha = _captchaController.text.trim().toUpperCase();
              if (enteredCaptcha != 'NS1UYU') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Invalid Captcha Code. Please try again.'),
                    backgroundColor: Colors.red.shade800,
                  ),
                );
                return; // Stop login process
              }

              // Mock Login after successful validation
              ref.read(authProvider.notifier).login(
                'mock_jwt_token_123', 
                _otrController.text.isNotEmpty ? _otrController.text : '20265236276007', 
                'John Doe'
              );
              context.go('/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}


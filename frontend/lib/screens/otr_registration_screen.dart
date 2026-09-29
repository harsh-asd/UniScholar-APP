import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';

// Simple provider for step management (Step 1: EKYC, Step 2: Face Auth)
final currentStepProvider = StateProvider<int>((ref) => 1);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final referenceNumberProvider = StateProvider<String?>((ref) => null);

class OtrRegistrationScreen extends ConsumerWidget {
  OtrRegistrationScreen({Key? key}) : super(key: key);

  final TextEditingController _kycController = TextEditingController();
  // Use physical LAN IP for APK device testing
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.79.144.44:3000/api/otr'));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(currentStepProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('One-Time Registration (OTR)'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                currentStep == 1 
                    ? 'Enter your KYC ID (Aadhaar/EID) to initiate registration.'
                    : 'KYC verified. Complete Face Authentication to generate your OTR.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              if (currentStep == 1) ...[
                TextFormField(
                  controller: _kycController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  obscuringCharacter: 'X',
                  maxLength: 12, // Assuming 12 digit Aadhaar
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'KYC ID (Aadhaar / EID)',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : () => _initiateEkyc(ref, context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Generate OTP / Reference',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
              
              if (currentStep == 2) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.face_retouching_natural, size: 64, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(height: 16),
                      Text(
                        'Ref: ${ref.watch(referenceNumberProvider)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : () => _verifyFaceAuth(ref, context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Complete Face Authentication',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initiateEkyc(WidgetRef ref, BuildContext context) async {
    final kycId = _kycController.text.trim();
    if (kycId.isEmpty) return;

    ref.read(isLoadingProvider.notifier).state = true;
    try {
      final response = await _dio.post('/step1-ekyc', data: {'kycId': kycId});
      if (response.statusCode == 200) {
        ref.read(referenceNumberProvider.notifier).state = response.data['referenceNumber'];
        ref.read(currentStepProvider.notifier).state = 2; // Move to Step 2
      }
    } on DioException catch (e) {
      _showError(context, e.response?.data['error'] ?? 'Network Error');
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _verifyFaceAuth(WidgetRef ref, BuildContext context) async {
    final referenceNumber = ref.read(referenceNumberProvider);
    if (referenceNumber == null) return;

    ref.read(isLoadingProvider.notifier).state = true;
    try {
      // Mocking a successful face auth process from the mobile side
      final response = await _dio.post('/step2-verify', data: {
        'referenceNumber': referenceNumber,
        'faceAuthSuccess': true
      });
      
      if (response.statusCode == 201) {
        final otrId = response.data['otrId'];
        final token = response.data['token'];
        final fullName = response.data['user']['fullName'];
        
        // Save to secure storage via AuthNotifier
        await ref.read(authProvider.notifier).login(token, otrId, fullName);

        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Registration Successful!'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Your One-Time Registration (OTR) ID has been generated successfully. Please save it for future logins:'),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            otrId,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.secondary),
                            tooltip: 'Copy to Clipboard',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: otrId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('OTR ID copied to clipboard!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      context.go('/dashboard');    // Navigate
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Continue to Dashboard'),
                  ),
                ],
              );
            },
          );
        }
      }
    } on DioException catch (e) {
      if (context.mounted) {
        _showError(context, e.response?.data['error'] ?? 'Verification Failed');
      }
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade800),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green.shade800),
    );
  }
}




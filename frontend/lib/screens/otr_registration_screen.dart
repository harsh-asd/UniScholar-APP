import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

// Simple provider for step management (Step 1: EKYC, Step 2: Face Auth)
final currentStepProvider = StateProvider<int>((ref) => 1);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final referenceNumberProvider = StateProvider<String?>((ref) => null);

class OtrRegistrationScreen extends ConsumerWidget {
  OtrRegistrationScreen({Key? key}) : super(key: key);

  final TextEditingController _kycController = TextEditingController();
  // Ensure the baseUrl points to your running Node.js backend. 
  // Use 10.0.2.2 for Android emulator testing against localhost.
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:3000/api/otr'));

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
                    backgroundColor: Colors.blue.shade800,
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
                      const Icon(Icons.face_retouching_natural, size: 64, color: Colors.blue),
                      const SizedBox(height: 16),
                      Text(
                        'Ref: ${ref.watch(referenceNumberProvider)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
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
        _showSuccess(context, 'Registration Successful! OTR ID: $otrId');
        // Handle navigation to dashboard here using go_router
      }
    } on DioException catch (e) {
      _showError(context, e.response?.data['error'] ?? 'Verification Failed');
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

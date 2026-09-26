import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../providers/auth_provider.dart';

// Provide the current application (mocking fetching it for demo)
final activeApplicationProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // Normally this would hit a GET /api/scholarships/my-applications endpoint
  // We'll mock the response to represent a DISBURSED application for demo purposes
  return {
    'id': 'mock-app-id-123',
    'schemeName': 'National Fellowship for ST',
    'status': 'DISBURSED',
  };
});

// Provide DBT Status specifically
final dbtStatusProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, applicationId) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/schemes/dbt-status/$applicationId');
  return response.data['dbtData'];
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final activeAppAsync = ref.watch(activeApplicationProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Welcome back, ${authState.fullName?.split(' ')[0] ?? 'Student'}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('OTR ID: ${authState.otrId ?? 'N/A'}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),

            // Application Tracker
            Text('Application Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            
            activeAppAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading application: $err'),
              data: (app) {
                if (app == null) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No active applications found. Explore schemes to apply!'),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildApplicationStepper(context, app['status']),
                    const SizedBox(height: 24),
                    if (app['status'] == 'DISBURSED') _buildDbtCard(context, ref, app['id']),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open JAGO Chatbot
        },
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildApplicationStepper(BuildContext context, String currentStatus) {
    int currentStep = 0;
    if (currentStatus == 'L1_APPROVED') currentStep = 1;
    if (currentStatus == 'L2_APPROVED') currentStep = 2;
    if (currentStatus == 'SANCTIONED' || currentStatus == 'DISBURSED') currentStep = 3;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stepper(
          physics: const ClampingScrollPhysics(),
          currentStep: currentStep,
          controlsBuilder: (context, details) => const SizedBox.shrink(), // Hide buttons
          steps: [
            Step(
              title: const Text('Submitted (Pending L1)'),
              content: const Text('Your application is awaiting Institute verification.'),
              isActive: currentStep >= 0,
              state: currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('L1 Verified (Pending L2)'),
              content: const Text('Institute has approved. Awaiting District Nodal Officer.'),
              isActive: currentStep >= 1,
              state: currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('L2 Verified (Pending Sanction)'),
              content: const Text('District has approved. Awaiting State/Ministry sanction.'),
              isActive: currentStep >= 2,
              state: currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Sanctioned & Disbursed'),
              content: const Text('Funds have been released to your DBT linked account.'),
              isActive: currentStep >= 3,
              state: currentStep >= 3 ? StepState.complete : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDbtCard(BuildContext context, WidgetRef ref, String applicationId) {
    final dbtAsync = ref.watch(dbtStatusProvider(applicationId));

    return dbtAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
      data: (dbtData) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.green.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance, color: Colors.green, size: 32),
                    const SizedBox(width: 12),
                    Text('DBT Payment Receipt', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                const Divider(height: 32),
                _buildReceiptRow('Amount Disbursed', '₹${dbtData['disbursementAmount']}', isHighlight: true),
                const SizedBox(height: 12),
                _buildReceiptRow('Bank Account', dbtData['bankAccountMasked']),
                const SizedBox(height: 12),
                _buildReceiptRow('PFMS Reference', dbtData['pfmsTransactionId']),
                const SizedBox(height: 24),
                Center(
                  child: Chip(
                    avatar: const Icon(Icons.check_circle, color: Colors.white),
                    label: Text(
                      dbtData['dbtStatus'].replaceAll('_', ' '),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 20 : 16,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? Colors.green.shade800 : Colors.black87,
          ),
        ),
      ],
    );
  }
}

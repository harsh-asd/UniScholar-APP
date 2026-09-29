import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ApplicationWizardScreen extends StatefulWidget {
  final String schemeName;

  const ApplicationWizardScreen({Key? key, required this.schemeName}) : super(key: key);

  @override
  State<ApplicationWizardScreen> createState() => _ApplicationWizardScreenState();
}

class _ApplicationWizardScreenState extends State<ApplicationWizardScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitApplication();
    }
  }

  Future<void> _submitApplication() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 24),
              const Text('Application Submitted!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text(
                'Your application has been successfully routed to your Institute Nodal Officer for L1 Verification.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/dashboard'); // Go back to dashboard
                    
                    // Simulate FCM Push Notification arriving 5 seconds later
                    Future.delayed(const Duration(seconds: 5), () {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(top: 50, left: 16, right: 16),
                            duration: const Duration(seconds: 6),
                            content: Row(
                              children: [
                                const Icon(Icons.notifications_active, color: Colors.amber),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Gov-Push Alert (FCM)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                      Text('Your application for ${widget.schemeName} was L1 Verified!', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    });
                  },
                  child: const Text('Back to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Apply for Scholarship'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selected Scheme:', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  widget.schemeName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _nextStep,
              onStepCancel: () {
                if (_currentStep > 0) setState(() => _currentStep--);
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSubmitting && _currentStep == 2
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(_currentStep == 2 ? 'Submit Application' : 'Confirm & Continue'),
                        ),
                      ),
                      if (_currentStep > 0 && !_isSubmitting) ...[
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        )
                      ]
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('OTR Profile Sync', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: _buildOtrSyncCard(),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('DigiLocker Document Verification', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: _buildDigiLockerVerificationCard(),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Final Review & Declaration', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: _buildDeclarationCard(),
                  isActive: _currentStep >= 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtrSyncCard() {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sync, color: Theme.of(context).colorScheme.secondary),
                SizedBox(width: 8),
                Text('Data Auto-filled from OTR', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            _buildProfileRow('Applicant Name', 'John Doe'),
            _buildProfileRow('Gender', 'Male'),
            _buildProfileRow('Category', 'Scheduled Tribe (ST)'),
            _buildProfileRow('Aadhaar Number', 'XXXX-XXXX-1234'),
            _buildProfileRow('Annual Income', 'â‚¹ 2,50,000'),
          ],
        ),
      ),
    );
  }

  Widget _buildDigiLockerVerificationCard() {
    return Card(
      elevation: 0,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified_user, color: Colors.green),
                SizedBox(width: 8),
                Text('All mandatory documents fetched via API', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            _buildDocRow('Caste Certificate', 'Verified (State e-District)'),
            _buildDocRow('Income Certificate', 'Verified (State Revenue Dept)'),
            _buildDocRow('Previous Marksheet', 'Verified (CBSE API)'),
            _buildDocRow('Bank Account', 'Aadhaar Seeded (NPCI Status Active)'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('AI Camera Scanner started for manual document upload.')),
                );
              },
              icon: const Icon(Icons.document_scanner),
              label: const Text('Missing Document? Scan Manually'),
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildDeclarationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'I hereby declare that all information provided is true and correct. I understand that my scholarship application will be processed based on my OTR and DigiLocker data.',
              style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDocRow(String doc, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(doc, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(status, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import '../services/api_client.dart';
import '../providers/auth_provider.dart';

// Provider to hold the list of pending applications
final pendingApplicationsProvider = StateNotifierProvider<PendingApplicationsNotifier, List<dynamic>>((ref) {
  return PendingApplicationsNotifier(ref.watch(apiClientProvider));
});

class PendingApplicationsNotifier extends StateNotifier<List<dynamic>> {
  final ApiClient apiClient;
  PendingApplicationsNotifier(this.apiClient) : super([]) {
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    try {
      final response = await apiClient.get('/admin/applications/pending');
      if (response.statusCode == 200) {
        state = response.data['applications'] ?? [];
      }
    } catch (e) {
      print('Error fetching applications: $e');
    }
  }

  void removeApplication(String id) {
    state = state.where((app) => app['id'] != id).toList();
  }
}

// Provider to manage the currently selected application in the split view
final selectedApplicationProvider = StateProvider<dynamic>((ref) => null);

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applications = ref.watch(pendingApplicationsProvider);
    final selectedApp = ref.watch(selectedApplicationProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/welcome');
            },
            tooltip: 'Back to Welcome',
          ),
          title: const Text('Nodal Officer Verification Dashboard'),
          backgroundColor: Colors.blueGrey.shade900,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.tealAccent,
            tabs: [
              Tab(icon: Icon(Icons.verified_user), text: 'Manual Scrutiny Queue'),
              Tab(icon: Icon(Icons.radar), text: 'AI Outreach (UDISE+)'),
              Tab(icon: Icon(Icons.support_agent), text: 'Grievance Tickets'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(pendingApplicationsProvider.notifier).fetchApplications(),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/welcome');
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Existing Split View
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: applications.isEmpty
                        ? const Center(child: Text("No pending applications."))
                        : ListView(
                            children: [
                              DataTable(
                                showCheckboxColumn: false,
                                headingRowColor: MaterialStateProperty.all(Colors.blueGrey.shade50),
                                columns: const [
                                  DataColumn(label: Text('Applicant')),
                                  DataColumn(label: Text('OTR ID')),
                                  DataColumn(label: Text('Scheme')),
                                  DataColumn(label: Text('Status')),
                                ],
                                rows: applications.map((app) {
                                  final isSelected = selectedApp?['id'] == app['id'];
                                  return DataRow(
                                    selected: isSelected,
                                    onSelectChanged: (_) {
                                      ref.read(selectedApplicationProvider.notifier).state = app;
                                    },
                                    cells: [
                                      DataCell(Text(app['user']?['fullName'] ?? 'Unknown')),
                                      DataCell(Text(app['otrId'] ?? '')),
                                      DataCell(Text(app['schemeName'] ?? '')),
                                      DataCell(Chip(
                                        label: Text(app['status']),
                                        backgroundColor: Colors.orange.shade100,
                                      )),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: selectedApp == null
                      ? const Center(
                          child: Text('Select an application from the list to review',
                              style: TextStyle(fontSize: 18, color: Colors.grey)),
                        )
                      : _buildDetailPanel(context, ref, selectedApp),
                ),
              ],
            ),
            // Tab 2: Smart Discovery (UDISE+ & APAAR)
            _buildSmartDiscoveryTab(context),
            // Tab 3: Grievance Tickets
            _buildGrievanceTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartDiscoveryTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar, color: Colors.teal, size: 36),
              const SizedBox(width: 16),
              Text('Smart Outreach Engine', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Cross-referencing enrolled ST students in UDISE+ and APAAR with national OTR scholarship databases.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              _buildStatCard('UDISE+ Matches', '3,402', 'Eligible ST students found', Colors.blue),
              const SizedBox(width: 24),
              _buildStatCard('Already Availing', '1,105', 'Currently on MoTA scholarships', Colors.green),
              const SizedBox(width: 24),
              _buildStatCard('Unreached Gap', '2,297', 'Target outreach pool', Colors.orange),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Unreached Target Pool (Preview)', style: Theme.of(context).textTheme.titleLarge),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Triggering automated SMS campaigns to 2,297 students...')),
                  );
                },
                icon: const Icon(Icons.sms),
                label: const Text('Send Bulk Application SMS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: ListView(
                children: [
                  ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
                    title: const Text('Priya Gond'),
                    subtitle: const Text('APAAR ID: 9012-XXXX-3456 | Class 10 (UDISE+: 09120XXXX)'),
                    trailing: const Text('Eligible: Pre-Matric', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person, color: Colors.white)),
                    title: const Text('Amit Munda'),
                    subtitle: const Text('APAAR ID: 4123-XXXX-7890 | Class 11 (UDISE+: 09121XXXX)'),
                    trailing: const Text('Eligible: Post-Matric', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, MaterialColor color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 6)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color.shade800)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel(BuildContext context, WidgetRef ref, dynamic app) {
    final user = app['user'] ?? {};
    final documents = (user['documents'] as List<dynamic>?) ?? [];

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Application Review', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          
          // Applicant Details Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Demographic Data', style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  ListTile(
                    title: const Text('Full Name'),
                    subtitle: Text(user['fullName'] ?? 'N/A'),
                    leading: const Icon(Icons.person),
                  ),
                  ListTile(
                    title: const Text('OTR ID'),
                    subtitle: Text(app['otrId'] ?? 'N/A'),
                    leading: const Icon(Icons.badge),
                  ),
                  ListTile(
                    title: const Text('Gender / ST Status'),
                    subtitle: Text('${user['gender'] ?? 'N/A'} - ST: ${user['stStatus'] == true ? 'Yes' : 'No'}'),
                    leading: const Icon(Icons.wc),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Document Wallet Status
          Text('Document Wallet Verification', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: documents.map((doc) {
              final isVerified = doc['isVerified'] == true;
              return Chip(
                avatar: Icon(
                  isVerified ? Icons.verified : Icons.warning,
                  color: isVerified ? Colors.green : Colors.orange,
                ),
                label: Text(doc['documentType'] ?? 'Unknown Document'),
                backgroundColor: isVerified ? Colors.green.shade50 : Colors.orange.shade50,
              );
            }).toList(),
          ),
          
          const Spacer(),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showRemarksDialog(context, ref, app['id'], 'REJECT'),
                icon: const Icon(Icons.cancel, color: Colors.red),
                label: const Text('Reject', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showRemarksDialog(context, ref, app['id'], 'APPROVE'),
                icon: const Icon(Icons.check_circle),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showRemarksDialog(BuildContext context, WidgetRef ref, String applicationId, String action) {
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${action == 'APPROVE' ? 'Approve' : 'Reject'} Application'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter mandatory remarks for this action:'),
            const SizedBox(height: 16),
            TextField(
              controller: remarksController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., Verified income certificate and caste validity...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final remarks = remarksController.text.trim();
              if (remarks.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Remarks are mandatory!')),
                );
                return;
              }
              
              Navigator.pop(ctx);
              await _submitVerification(context, ref, applicationId, action, remarks);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'APPROVE' ? Colors.green : Colors.red,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitVerification(BuildContext context, WidgetRef ref, String id, String action, String remarks) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        '/admin/applications/$id/verify',
        data: {
          'action': action,
          'remarks': remarks,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message']), backgroundColor: Colors.green),
        );
        
        // Remove from list and clear detail view
        ref.read(pendingApplicationsProvider.notifier).removeApplication(id);
        ref.read(selectedApplicationProvider.notifier).state = null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification Failed'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildGrievanceTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent, color: Colors.orange, size: 36),
              const SizedBox(width: 16),
              Text('Grievance Ticketing System', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Manage and resolve disputes submitted by students regarding verification rejections.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildGrievanceCard('GRV-8821', 'Ramesh ST', 'Document Rejection Dispute', 'Pending Resolution', Colors.red),
                _buildGrievanceCard('GRV-8822', 'Sita Kumari', 'Aadhaar Seeded Bank Account Error', 'In Progress', Colors.orange),
                _buildGrievanceCard('GRV-8819', 'Rahul Munda', 'Institute Nodal Officer Unresponsive', 'Resolved', Colors.green),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGrievanceCard(String ticketId, String studentName, String issue, String status, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(Icons.assignment_late, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$ticketId: $issue', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Student: $studentName', style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor),
              ),
              child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {},
              child: const Text('View Ticket'),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/api_client.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/jago_chatbot.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    
    // Read Settings
    final currentLang = ref.watch(languageProvider);
    final fontScale = ref.watch(fontSizeMultiplierProvider);

    final List<Widget> pages = [
      _buildHomeTab(context, authState, theme, currentLang),
      _buildDigiLockerVault(context, theme, currentLang),
      _buildSchemesCatalog(context, theme, currentLang), _buildPassbookTab(context, theme, currentLang), _buildProfileTab(context, theme, currentLang),
    ];

    return Transform.scale(
      scale: fontScale,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(currentLang == 'hi' ? 'छात्र डैशबोर्ड' : 'Student Dashboard'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(currentLang == 'hi' ? 'कोई नई सूचना नहीं' : 'No new notifications')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: currentLang == 'hi' ? 'लॉग आउट' : 'Sign Out',
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/welcome');
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 8, type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home), label: currentLang == 'hi' ? 'होम' : 'Home'),
            BottomNavigationBarItem(icon: const Icon(Icons.security), label: currentLang == 'hi' ? 'डिजिलॉकर' : 'DigiLocker'),
            BottomNavigationBarItem(icon: const Icon(Icons.list_alt), label: 'Schemes'),
            BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet), label: 'Passbook'),
            BottomNavigationBarItem(icon: const Icon(Icons.person), label: 'Profile'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const JagoChatbot(),
            );
          },
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.chat_bubble_outline),
          label: Text(currentLang == 'hi' ? 'जागो से पूछें' : 'Ask JAGO', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context, dynamic authState, ThemeData theme, String currentLang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentLang == 'hi' ? 'वापसी पर स्वागत है, ${authState.fullName ?? 'छात्र'}!' : 'Welcome back, ${authState.fullName ?? 'Student'}!',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'OTR ID: ${authState.otrId ?? 'N/A'}',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          // Offline Mode Banner Simulator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300)
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                SizedBox(width: 8),
                Text('Offline Mode: Displaying locally cached data.', style: TextStyle(fontSize: 12, color: Colors.orange)),
              ],
            ),
          ),
          
          Text(currentLang == 'hi' ? 'सक्रिय आवेदन स्थिति' : 'Active Application Status', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildStatusStepper(context),
          const SizedBox(height: 12),
          
          // Grievance Redressal Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Grievance Ticketing System to contact Nodal Officer...')),
                );
              },
              icon: const Icon(Icons.support_agent, color: Colors.red),
              label: Text(currentLang == 'hi' ? 'शिकायत दर्ज करें' : 'Raise a Grievance Ticket'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildDbtCard(context),
          const SizedBox(height: 80), // Padding for FAB
        ],
      ),
    );
  }

  Widget _buildDigiLockerVault(BuildContext context, ThemeData theme, String currentLang) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Icon(Icons.cloud_done, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(currentLang == 'hi' ? 'डिजिलॉकर दस्तावेज़ वॉल्ट' : 'DigiLocker Document Vault', style: theme.textTheme.titleLarge)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          currentLang == 'hi' ? 'आपके दस्तावेज़ OTR एकीकरण के माध्यम से स्वचालित रूप से सत्यापित होते हैं।' : 'Your documents are digitally fetched and verified via OTR integration, eliminating the need to upload PDFs.', 
          style: TextStyle(color: Colors.grey.shade600)
        ),
        const SizedBox(height: 24),
        _buildDocumentTile('Aadhaar / eKYC', 'Verified on 26 Sept 2026', Icons.person),
        _buildDocumentTile('ST Caste Certificate', 'Verified via State e-District API', Icons.verified_user),
        _buildDocumentTile('Income Certificate', 'Verified via State API (Valid till 2027)', Icons.account_balance_wallet),
        _buildDocumentTile('10th & 12th Marksheets', 'Verified via CBSE / State Board API', Icons.school),
      ],
    );
  }

  Widget _buildDocumentTile(String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(icon, color: Colors.blue.shade800)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }

  Widget _buildSchemesCatalog(BuildContext context, ThemeData theme, String currentLang) {
    final schemes = [
      'Pre-Matric Scholarship for ST Students',
      'Post-Matric Scholarship for ST Students',
      'National Fellowship and Scholarship for Higher Education of ST Students (Top Class)',
      'National Overseas Scholarship (NOS) for ST Students'
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schemes.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          // AI Recommendation Engine Card (Inspired by Buddy4Study)
          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade700, Colors.deepPurple.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      currentLang == 'hi' ? 'AI स्मार्ट मैच' : 'AI Smart Match', 
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentLang == 'hi' ? 'आपकी OTR प्रोफ़ाइल के आधार पर, आप इसके लिए 98% पात्र हैं:' : 'Based on your OTR Profile, you are a 98% match for:',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'National Fellowship for ST Students (NFST)',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/apply', extra: 'National Fellowship for ST Students (NFST)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.purple.shade900,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(currentLang == 'hi' ? '1-क्लिक अप्लाई' : '1-Click Apply (Auto-Fill)'),
                  ),
                )
              ],
            ),
          );
        }
        
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(currentLang == 'hi' ? 'अन्य उपलब्ध योजनाएं' : 'Other Available Schemes', style: theme.textTheme.titleLarge),
          );
        }

        final schemeName = schemes[index - 2];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(schemeName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(currentLang == 'hi' ? 'पात्रता की जाँच की जा रही है...' : 'Checking eligibility against OTR...'),
            trailing: OutlinedButton(
              onPressed: () => context.push('/apply', extra: schemeName),
              child: Text(currentLang == 'hi' ? 'विवरण' : 'Details'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusStepper(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Color(0xFF1A334D), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF1A334D),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Text('APPLICATION VERIFICATION STATUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStepRow(context, '1. Application Submitted (L1 Pending)', true, isFirst: true),
                _buildStepRow(context, '2. Institute (L1) Verified', true),
                _buildStepRow(context, '3. District (L2) Verified', true),
                _buildStepRow(context, '4. Sanctioned & Disbursed via PFMS', true, isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(BuildContext context, String title, bool isCompleted, {bool isFirst = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 20,
                  color: isFirst ? Colors.transparent : (isCompleted ? Colors.green.shade700 : Colors.grey.shade300),
                ),
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green.shade700 : Colors.grey.shade400,
                  size: 20,
                ),
                Container(
                  width: 2,
                  height: 20,
                  color: isLast ? Colors.transparent : (isCompleted ? Colors.green.shade700 : Colors.grey.shade300),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.shade50 : Colors.grey.shade100,
                border: Border.all(color: isCompleted ? Colors.green.shade200 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isCompleted ? Colors.green.shade900 : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDbtCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFFC85237),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: const Text('DIRECT BENEFIT TRANSFER (DBT) STATUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDbtRow('PFMS Token:', 'TXN-847291-MOTA', true),
                const Divider(),
                _buildDbtRow('Amount Sanctioned:', '₹ 45,000.00', true),
                const Divider(),
                _buildDbtRow('Credit Status:', 'SUCCESS (Credited on 26-Sep-2026)', true),
                const Divider(),
                _buildDbtRow('Aadhaar Seeded Bank:', 'STATE BANK OF INDIA (****1234)', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDbtRow(String label, String value, bool isSuccess) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isSuccess ? Colors.green.shade700 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassbookTab(BuildContext context, ThemeData theme, String currentLang) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(currentLang == 'hi' ? 'DBT पासबुक' : 'DBT Digital Passbook', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Track your Public Financial Management System (PFMS) credits', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 24),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.green.shade200)),
          color: Colors.green.shade50,
          child: const ListTile(
            leading: Icon(Icons.account_balance, color: Colors.green),
            title: Text('Aadhaar Seeded Bank Account', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('STATE BANK OF INDIA (****1234)\nNPCI Status: Active', style: TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        _buildTransactionRow('NFST Fellowship (AY 2026-27)', '26 Sep 2026', '₹ 45,000', true),
        _buildTransactionRow('Pre-Matric Scholarship (AY 2025-26)', '14 Nov 2025', '₹ 15,000', true),
        _buildTransactionRow('Book Grant Allowance', '10 Aug 2025', '₹ 5,000', true),
      ],
    );
  }

  Widget _buildTransactionRow(String title, String date, String amount, bool isCredit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCredit ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? Colors.green : Colors.red),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(date, style: const TextStyle(fontSize: 12)),
        trailing: Text(
          (isCredit ? '+' : '-') + amount,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isCredit ? Colors.green.shade700 : Colors.red.shade700),
        ),
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context, ThemeData theme, String currentLang) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(radius: 50, backgroundColor: theme.colorScheme.primary, child: const Icon(Icons.person, size: 50, color: Colors.white)),
                  const CircleAvatar(radius: 16, backgroundColor: Colors.green, child: Icon(Icons.verified, color: Colors.white, size: 16)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Harsh ST', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
                child: const Text('eKYC Verified via FaceAuth', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildProfileSectionTitle('One-Time Registration (OTR) Data'),
        _buildProfileField('OTR ID', 'OTR-9988-7766-5544'),
        _buildProfileField('Aadhaar Number', 'XXXX-XXXX-1234'),
        _buildProfileField('Gender', 'Male'),
        _buildProfileField('Category', 'Scheduled Tribe (ST)'),
        _buildProfileField('Annual Family Income', '₹ 2,50,000'),
        const SizedBox(height: 24),
        _buildProfileSectionTitle('Preferences & Support'),
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Tutorials & FAQs'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Data Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildProfileSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A334D))),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

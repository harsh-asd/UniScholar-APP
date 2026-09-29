import 'package:flutter/material.dart';

class JagoChatbot extends StatefulWidget {
  const JagoChatbot({Key? key}) : super(key: key);

  @override
  State<JagoChatbot> createState() => _JagoChatbotState();
}

class _JagoChatbotState extends State<JagoChatbot> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'JAGO',
      'text': 'Hello! I am JAGO, your AI-powered Smart Assistant designed for Tribal Students. \n\nI can assist you with:\n• Scheme Eligibility\n• Application Tracking\n• OTR & Document Queries\n\nHow can I help you today?'
    }
  ];

  final List<String> _quickReplies = [
    "Check My Status",
    "What is OTR?",
    "Required Documents?",
    "Am I eligible for NOS?"
  ];

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({'sender': 'USER', 'text': text});
      _isTyping = true;
    });
    
    _controller.clear();
    _scrollToBottom();
    
    // Simulate Advanced AI Processing Delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      _handleBotResponse(text);
    });
  }

  void _handleBotResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    // Advanced NLP simulated keyword mapping
    String response = "I couldn't perfectly understand that. I'm trained specifically on MoTA scholarships (Pre-Matric, Post-Matric, Top Class, NFST, NOS). Could you rephrase your question?";
    
    if (lowerQuery.contains('status') || lowerQuery.contains('track')) {
      response = "🔍 **Application Status Tracking:**\nBased on your secure OTR profile, your 'National Fellowship (NFST)' application is currently at 'L1 Verified' (District Level).\n\nEstimated time for State Node approval: 4-6 days.";
    } else if (lowerQuery.contains('otr') || lowerQuery.contains('one time')) {
      response = "🛡️ **One-Time Registration (OTR):**\nOTR is our new unified system. You only register once using Aadhaar Face-Auth. We pull all your details (Caste, Income, Domicile) directly from DigiLocker. No more filling out the same forms every year!";
    } else if (lowerQuery.contains('nos') || lowerQuery.contains('overseas')) {
      response = "✈️ **National Overseas Scholarship (NOS):**\nThis scheme provides financial assistance to ST students pursuing Master's or Ph.D. abroad.\n\n**Eligibility:**\n• Minimum 55% in Master's/Bachelors\n• Family income below ₹6,00,000 p.a.\n\nYour OTR currently shows you meet these criteria!";
    } else if (lowerQuery.contains('document') || lowerQuery.contains('upload')) {
      response = "📄 **Document Requirements:**\nGreat news! Because you are logged in via OTR, your Caste and Income certificates are automatically fetched via API. \n\nYou only need to upload your 'Fee Receipt' for this specific disbursement.";
    } else if (lowerQuery.contains('hi') || lowerQuery.contains('hello')) {
      response = "Hi there! Feel free to ask me anything about MoTA scholarships, eligibility, or how to use the portal.";
    } else if (lowerQuery.contains('pre-matric') || lowerQuery.contains('post-matric') || lowerQuery.contains('matric')) {
      response = "🏫 **Matric Scholarships:**\nPre-Matric is for classes 9-10, while Post-Matric is for class 11 to Ph.D. \n\nSince your APAAR ID reflects you are in Class 11, the system has automatically highlighted the Post-Matric scheme for you on the dashboard.";
    }

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({'sender': 'JAGO', 'text': response});
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.auto_awesome, color: Colors.white),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                          )
                        )
                      ],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('JAGO AI', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        const Text('Always Online', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    )
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isBot = _messages[index]['sender'] == 'JAGO';
                return Align(
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isBot ? theme.colorScheme.primary.withOpacity(0.08) : theme.colorScheme.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isBot ? const Radius.circular(0) : const Radius.circular(16),
                        bottomRight: isBot ? const Radius.circular(16) : const Radius.circular(0),
                      ),
                      boxShadow: [
                        if (!isBot) BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                      ]
                    ),
                    child: Text(
                      _messages[index]['text']!,
                      style: TextStyle(
                        color: isBot ? Colors.black87 : Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.secondary)),
                    const SizedBox(width: 8),
                    Text('JAGO is analyzing...', style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),

          // Quick Replies
          if (!_isTyping)
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _quickReplies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      label: Text(_quickReplies[index], style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.3)),
                      onPressed: () => _sendMessage(_quickReplies[index]),
                    ),
                  );
                },
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask JAGO anything...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.secondary,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
}

}


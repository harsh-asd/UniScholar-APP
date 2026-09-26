import 'package:flutter/material.dart';

class JagoChatbot extends StatefulWidget {
  const JagoChatbot({Key? key}) : super(key: key);

  @override
  State<JagoChatbot> createState() => _JagoChatbotState();
}

class _JagoChatbotState extends State<JagoChatbot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'JAGO',
      'text': 'Hello! I am JAGO, your Smart Assistant. I can help you with eligibility, application status, or document requirements. How can I help you today?'
    }
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({'sender': 'USER', 'text': text});
    });
    
    _controller.clear();
    
    // Simulate AI Response Delay
    Future.delayed(const Duration(seconds: 1), () {
      _handleBotResponse(text);
    });
  }

  void _handleBotResponse(String query) {
    final lowerQuery = query.toLowerCase();
    
    // Default fallback for unexpected questions
    String response = "I'm currently assisting thousands of students with the new OTR rollout. For specific issues outside your application status, eligibility, or documents, please contact your District Nodal Officer directly through the portal!";
    
    if (lowerQuery.contains('status')) {
      response = "Based on your OTR profile, your National Fellowship (NFST) application is currently 'L1 Verified' and is pending review at the District level.";
    } else if (lowerQuery.contains('eligibil') || lowerQuery.contains('nos')) {
      response = "To apply for the National Overseas Scholarship (NOS), you need a minimum of 55% in your Master's degree and an annual family income below ₹6,00,000. Your OTR currently shows you are eligible!";
    } else if (lowerQuery.contains('document')) {
      response = "Because you used OTR, your Caste and Income certificates were automatically fetched via DigiLocker. No manual upload is required!";
    } else if (lowerQuery.contains('hi') || lowerQuery.contains('hello')) {
      response = "Hi there! How can I assist you with MoTA scholarships today?";
    }

    if (mounted) {
      setState(() {
        _messages.add({'sender': 'JAGO', 'text': response});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
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
                    const Icon(Icons.smart_toy, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('JAGO AI Assistant', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isBot = _messages[index]['sender'] == 'JAGO';
                return Align(
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.blue.shade50 : theme.colorScheme.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isBot ? const Radius.circular(0) : const Radius.circular(16),
                        bottomRight: isBot ? const Radius.circular(16) : const Radius.circular(0),
                      ),
                    ),
                    child: Text(
                      _messages[index]['text']!,
                      style: TextStyle(color: isBot ? Colors.black87 : Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
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
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
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

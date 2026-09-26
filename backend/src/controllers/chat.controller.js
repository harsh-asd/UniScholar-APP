const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Basic Natural Language Processing intent matcher (Mocked for Phase 4)
 */
const determineIntent = (message) => {
  const text = message.toLowerCase();
  
  if (text.includes('status') || text.includes('where is my money') || text.includes('track')) {
    return 'check_status';
  }
  
  if (text.includes('income limit') || text.includes('eligibility') || text.includes('who can apply')) {
    return 'faq_eligibility';
  }

  if (text.includes('documents') || text.includes('upload') || text.includes('certificate')) {
    return 'faq_documents';
  }

  return 'unknown';
};

/**
 * POST /api/chat/jago
 * JAGO Chatbot endpoint
 */
const handleChat = async (req, res) => {
  try {
    const { otrId } = req.user;
    const { message } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    // Fetch user context
    const user = await prisma.userOTR.findUnique({
      where: { otrId }
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const intent = determineIntent(message);
    let reply = "I am JAGO, your scholarship assistant! How can I help you today?";

    switch (intent) {
      case 'check_status':
        // Query active applications
        const application = await prisma.scholarshipApplication.findFirst({
          where: { otrId },
          orderBy: { appliedAt: 'desc' }
        });

        if (application) {
          reply = `Hi ${user.fullName.split(' ')[0]}, your ${application.schemeName} application is currently: **${application.status}**.`;
        } else {
          reply = `Hi ${user.fullName.split(' ')[0]}, it looks like you haven't applied for any scholarships yet. Check the Dashboard for eligible schemes!`;
        }
        break;

      case 'faq_eligibility':
        reply = "For Post-Matric ST scholarships, the family income limit is generally ₹2.5 Lakhs per annum. You also need a valid ST Certificate.";
        break;

      case 'faq_documents':
        reply = "You will need: \n1. Aadhaar Card\n2. Income Certificate\n3. Caste Certificate\n4. Previous Year Marksheet\n5. Bank Passbook\nYou can easily fetch your Income and Caste certificates from DigiLocker in the Document Wallet tab!";
        break;

      default:
        reply = "I'm still learning! I can help you check your application status, explain eligibility, or tell you about required documents.";
        break;
    }

    return res.status(200).json({
      success: true,
      reply,
      intent
    });

  } catch (error) {
    console.error('JAGO Chatbot Error:', error);
    return res.status(500).json({ error: 'Chatbot service temporarily unavailable.' });
  }
};

module.exports = {
  handleChat
};

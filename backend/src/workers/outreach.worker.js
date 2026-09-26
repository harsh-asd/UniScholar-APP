const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Mock UDISE+ (Unified District Information System for Education) Database Check
 * Returns dummy enrollment data to simulate the API cross-reference.
 */
const checkUdiseDatabase = async (kycId) => {
  // Simulate network delay
  await new Promise((resolve) => setTimeout(resolve, 500));
  
  // Mock logic: randomly simulate that this KYC ID is enrolled in school as ST
  return {
    isEnrolled: true,
    schoolName: 'Govt. Senior Secondary School',
    currentClass: 'Class 11'
  };
};

/**
 * Simulates sending an SMS alert
 */
const sendSmsAlert = async (phoneNumber, message) => {
  console.log(`\n[OUTREACH SMS -> ${phoneNumber}]: ${message}\n`);
};

/**
 * Gap Identification & Smart Outreach Engine
 * Periodically run (e.g., via node-cron) to find unreached ST students
 */
const identifyUnreachedStudents = async () => {
  console.log('[Worker] Starting Gap Identification Outreach...');

  try {
    // 1. Fetch all OTR users who are ST
    const stUsers = await prisma.userOTR.findMany({
      where: { stStatus: true }
    });

    for (const user of stUsers) {
      // 2. Check if they have an active application
      const hasApplication = await prisma.scholarshipApplication.findFirst({
        where: { otrId: user.otrId }
      });

      // 3. If no application exists, cross-reference with UDISE+
      if (!hasApplication) {
        const udiseData = await checkUdiseDatabase(user.maskedKycId);

        // 4. If enrolled but haven't applied, trigger outreach
        if (udiseData.isEnrolled) {
          const smsText = `Hi ${user.fullName.split(' ')[0]}, you may be eligible for a MoTA Post-Matric scholarship for your studies in ${udiseData.currentClass} at ${udiseData.schoolName}. Apply now on the MoTA Unified App!`;
          
          // In real implementation, you'd have their phone number from OTR registration
          const mockPhone = '+919876543210'; 
          
          await sendSmsAlert(mockPhone, smsText);
          
          // Optionally, flag the user in the database as "Outreach Attempted"
          console.log(`[Worker] Flagged user ${user.otrId} for gap intervention.`);
        }
      }
    }
    
    console.log('[Worker] Gap Identification Outreach completed successfully.');
  } catch (error) {
    console.error('[Worker] Error during Outreach Engine run:', error);
  }
};

// Export the function so it can be scheduled (e.g., in a cron job in index.js)
module.exports = {
  identifyUnreachedStudents
};

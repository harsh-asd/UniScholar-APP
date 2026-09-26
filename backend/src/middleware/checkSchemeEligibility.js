const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const checkSchemeEligibility = async (req, res, next) => {
  try {
    const { otrId } = req.user; // Assumes authMiddleware has run
    
    // Check for any active or approved application
    const activeApplication = await prisma.scholarshipApplication.findFirst({
      where: {
        otrId: otrId,
        status: {
          in: ['SUBMITTED', 'L1_APPROVED', 'L2_APPROVED', 'SANCTIONED', 'DISBURSED']
        }
      }
    });

    if (activeApplication) {
      return res.status(403).json({
        error: 'DUAL_BENEFIT_NOT_PERMITTED',
        message: 'You already have an active or sanctioned application. Cross-scheme multiple benefits are not permitted for the current academic cycle.',
        activeApplicationId: activeApplication.id
      });
    }

    next();
  } catch (error) {
    console.error('Eligibility Middleware Error:', error);
    return res.status(500).json({ error: 'Failed to verify scheme eligibility' });
  }
};

module.exports = checkSchemeEligibility;

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Calculate age based on Date of Birth
 */
const calculateAge = (dob) => {
  const diff_ms = Date.now() - dob.getTime();
  const age_dt = new Date(diff_ms); 
  return Math.abs(age_dt.getUTCFullYear() - 1970);
};

/**
 * GET /api/schemes/eligible
 * Fetch eligible schemes for the authenticated user based on demographic logic
 */
const getEligibleSchemes = async (req, res) => {
  try {
    const { otrId } = req.user;

    // Fetch user details from DB
    const user = await prisma.userOTR.findUnique({
      where: { otrId }
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found in OTR records' });
    }

    const age = calculateAge(user.dob);
    const eligibleSchemes = [];

    // Mock Eligibility Rules Engine
    if (user.stStatus) {
      if (age < 16) {
        eligibleSchemes.push({
          id: 'SCH-PRE-01',
          schemeName: 'Pre-Matric Scholarship for ST Students',
          description: 'Financial assistance for ST students studying in classes IX and X.',
          deadline: '2026-11-30',
          status: 'Open'
        });
      } else {
        eligibleSchemes.push({
          id: 'SCH-POST-01',
          schemeName: 'Post-Matric Scholarship for ST Students',
          description: 'Financial assistance for ST students pursuing higher education (Class XI and above).',
          deadline: '2026-12-15',
          status: 'Open'
        });
        
        // Additional higher education scheme
        if (age >= 18) {
          eligibleSchemes.push({
            id: 'SCH-HE-02',
            schemeName: 'National Fellowship and Scholarship for Higher Education of ST Students',
            description: 'Financial support for pursuing MPhil, PhD, and professional degree courses.',
            deadline: '2026-12-31',
            status: 'Open'
          });
        }
      }
    }

    // A generic scheme for all registered OTR students
    eligibleSchemes.push({
      id: 'SCH-GEN-03',
      schemeName: 'Unified Digital Incentive Program',
      description: 'One-time incentive for students registering via the unified OTR portal.',
      deadline: '2026-10-31',
      status: 'Open'
    });

    return res.status(200).json({
      success: true,
      demographics: {
        age,
        gender: user.gender,
        stStatus: user.stStatus
      },
      eligibleSchemes
    });

  } catch (error) {
    console.error('Eligibility Engine Error:', error);
    return res.status(500).json({ error: 'Internal Server Error while evaluating schemes' });
  }
};

/**
 * GET /api/schemes/dbt-status/:applicationId
 * Return mock DBT payment metadata from PFMS
 */
const getDbtStatus = async (req, res) => {
  try {
    const { applicationId } = req.params;

    // Verify application exists and belongs to the user
    const application = await prisma.scholarshipApplication.findUnique({
      where: { id: applicationId }
    });

    if (!application) {
      return res.status(404).json({ error: 'Application not found' });
    }

    if (application.status !== 'DISBURSED' && application.status !== 'SANCTIONED') {
      return res.status(400).json({ error: 'Payment has not been processed for this application yet' });
    }

    // Mock PFMS Data
    const mockPfmsData = {
      pfmsTransactionId: `PFMS-TXN-${Math.floor(Math.random() * 900000) + 100000}`,
      bankAccountMasked: 'XXXX-XXXX-1234',
      disbursementAmount: 25000,
      dbtStatus: application.status === 'DISBURSED' ? 'CREDITED_TO_ACCOUNT' : 'PROCESSED',
      creditedAt: new Date().toISOString()
    };

    return res.status(200).json({
      success: true,
      dbtData: mockPfmsData
    });

  } catch (error) {
    console.error('DBT Status Error:', error);
    return res.status(500).json({ error: 'Failed to retrieve DBT status' });
  }
};

/**
 * POST /api/schemes/apply
 * Applies for a scholarship scheme
 */
const applyForScheme = async (req, res) => {
  try {
    const { otrId } = req.user;
    const { schemeName } = req.body;

    if (!schemeName) {
      return res.status(400).json({ error: 'schemeName is required' });
    }

    const application = await prisma.scholarshipApplication.create({
      data: {
        otrId,
        schemeName,
        status: 'SUBMITTED'
      }
    });

    return res.status(201).json({
      success: true,
      message: 'Application submitted successfully',
      application
    });
  } catch (error) {
    console.error('Apply Scheme Error:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

module.exports = {
  getEligibleSchemes,
  getDbtStatus,
  applyForScheme
};

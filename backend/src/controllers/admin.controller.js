const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * GET /api/admin/applications/pending
 * Fetch pending applications based on Admin Role
 */
const getPendingApplications = async (req, res) => {
  try {
    const { role } = req.admin;
    
    let targetStatus;
    if (role === 'L1_INSTITUTE') {
      targetStatus = 'SUBMITTED';
    } else if (role === 'L2_DISTRICT') {
      targetStatus = 'L1_APPROVED';
    } else if (role === 'MOTA_ADMIN') {
      targetStatus = 'L2_APPROVED';
    } else {
      return res.status(403).json({ error: 'Invalid admin role' });
    }

    const applications = await prisma.scholarshipApplication.findMany({
      where: { status: targetStatus },
      include: {
        user: {
          include: {
            documents: true // Include DocumentWallet records
          }
        }
      }
    });

    return res.status(200).json({ success: true, applications });
  } catch (error) {
    console.error('Fetch Pending Applications Error:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

/**
 * POST /api/admin/applications/:applicationId/verify
 * Approve or Reject an application with remarks
 */
const verifyApplication = async (req, res) => {
  try {
    const { applicationId } = req.params;
    const { action, remarks } = req.body;
    const { role } = req.admin;

    if (!action || !['APPROVE', 'REJECT'].includes(action)) {
      return res.status(400).json({ error: 'Valid action (APPROVE/REJECT) is required' });
    }
    
    if (!remarks) {
      return res.status(400).json({ error: 'Remarks are mandatory for verification' });
    }

    const application = await prisma.scholarshipApplication.findUnique({
      where: { id: applicationId }
    });

    if (!application) {
      return res.status(404).json({ error: 'Application not found' });
    }

    let nextStatus;
    const updateData = {};

    if (role === 'L1_INSTITUTE') {
      if (application.status !== 'SUBMITTED') return res.status(400).json({ error: 'Application not in SUBMITTED state' });
      nextStatus = action === 'APPROVE' ? 'L1_APPROVED' : 'L1_REJECTED';
      updateData.l1Remarks = remarks;
    } else if (role === 'L2_DISTRICT') {
      if (application.status !== 'L1_APPROVED') return res.status(400).json({ error: 'Application not in L1_APPROVED state' });
      nextStatus = action === 'APPROVE' ? 'L2_APPROVED' : 'L2_REJECTED';
      updateData.l2Remarks = remarks;
    } else if (role === 'MOTA_ADMIN') {
      if (application.status !== 'L2_APPROVED') return res.status(400).json({ error: 'Application not in L2_APPROVED state' });
      nextStatus = action === 'APPROVE' ? 'SANCTIONED' : 'L2_REJECTED'; // Depending on logic
    } else {
      return res.status(403).json({ error: 'Invalid admin role' });
    }

    updateData.status = nextStatus;

    const updatedApp = await prisma.scholarshipApplication.update({
      where: { id: applicationId },
      data: updateData
    });

    return res.status(200).json({
      success: true,
      message: `Application ${action}D successfully`,
      application: updatedApp
    });

  } catch (error) {
    console.error('Verify Application Error:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) return res.status(400).json({ error: 'Email and password required' });
    
    // For Hackathon, hardcode the verification so we don't need a DB seed for admins
    // Real app would fetch from prisma.adminUser
    let role;
    if (email === 'institute@mota.gov.in' && password === 'Admin@123') role = 'L1_INSTITUTE';
    else if (email === 'district@mota.gov.in' && password === 'Admin@123') role = 'L2_DISTRICT';
    else return res.status(401).json({ error: 'Invalid credentials' });

    const token = jwt.sign(
      { adminId: email, role, email },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '2h' }
    );
    
    return res.status(200).json({ success: true, token, role, fullName: email.split('@')[0].toUpperCase() });
  } catch (error) {
    return res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = {
  getPendingApplications,
  verifyApplication,
  login
};

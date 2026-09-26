const { PrismaClient } = require('@prisma/client');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const prisma = new PrismaClient();

// In-memory store for step 1 temporary data (use Redis in production)
const tempOtrStore = new Map();

/**
 * Step 1: Initialize OTR with KYC ID
 * POST /api/otr/step1-ekyc
 */
const initiateEkyc = async (req, res) => {
  try {
    const { kycId } = req.body;
    
    if (!kycId) {
      return res.status(400).json({ error: 'KYC ID is required' });
    }

    // Mask the KYC ID (e.g., keep only last 4 digits)
    const maskedKycId = 'XXXXXXXX' + kycId.slice(-4);
    
    // Hash the raw KYC ID for security (do not store raw ID)
    const hashedKycId = crypto.createHash('sha256').update(kycId).digest('hex');

    // Generate a temporary Reference Number
    const referenceNumber = 'REF' + crypto.randomBytes(6).toString('hex').toUpperCase();

    // Mock demographic data (in a real app, this comes from eKYC provider)
    const mockData = {
      hashedKycId,
      maskedKycId,
      fullName: 'John Doe',
      dob: new Date('2000-01-01'),
      gender: 'Male',
      stStatus: true
    };

    // Store temporarily
    tempOtrStore.set(referenceNumber, mockData);

    // Set expiration for reference number (e.g., 10 minutes)
    setTimeout(() => {
      tempOtrStore.delete(referenceNumber);
    }, 10 * 60 * 1000);

    return res.status(200).json({
      success: true,
      referenceNumber,
      demographics: {
        fullName: mockData.fullName,
        maskedKycId: mockData.maskedKycId
      }
    });
  } catch (error) {
    console.error('eKYC Initiation Error:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

/**
 * Step 2: Verify Face Auth and Generate OTR
 * POST /api/otr/step2-verify
 */
const verifyAndGenerateOtr = async (req, res) => {
  try {
    const { referenceNumber, faceAuthSuccess } = req.body;

    if (!referenceNumber || faceAuthSuccess === undefined) {
      return res.status(400).json({ error: 'Reference Number and Face Auth Status are required' });
    }

    if (!faceAuthSuccess) {
      return res.status(401).json({ error: 'Face Authentication Failed' });
    }

    const userData = tempOtrStore.get(referenceNumber);
    if (!userData) {
      return res.status(404).json({ error: 'Invalid or expired Reference Number' });
    }

    // Generate 14-digit OTR ID (Format: YYYY + 10 random digits)
    const year = new Date().getFullYear().toString();
    const randomDigits = Math.floor(1000000000 + Math.random() * 9000000000).toString();
    const otrId = year + randomDigits;

    // Save to PostgreSQL
    const newUser = await prisma.userOTR.create({
      data: {
        otrId,
        maskedKycId: userData.maskedKycId,
        fullName: userData.fullName,
        dob: userData.dob,
        gender: userData.gender,
        stStatus: userData.stStatus
      }
    });

    // Remove from temporary store
    tempOtrStore.delete(referenceNumber);

    // Generate JWT Session Token
    const token = jwt.sign(
      { id: newUser.id, otrId: newUser.otrId },
      process.env.JWT_SECRET || 'fallback_secret',
      { expiresIn: '24h' }
    );

    return res.status(201).json({
      success: true,
      otrId: newUser.otrId,
      token,
      user: {
        fullName: newUser.fullName,
        maskedKycId: newUser.maskedKycId
      }
    });
  } catch (error) {
    console.error('OTR Generation Error:', error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
};

module.exports = {
  initiateEkyc,
  verifyAndGenerateOtr
};

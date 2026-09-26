const { PrismaClient } = require('@prisma/client');
const digilockerService = require('../services/digilocker.service');
const prisma = new PrismaClient();

/**
 * GET /api/documents/sync-wallet
 * Syncs user's documents from DigiLocker and saves to DB
 */
const syncDocumentWallet = async (req, res) => {
  try {
    const { otrId } = req.user;

    // Call DigiLocker service to fetch verified documents
    const fetchedDocs = await digilockerService.fetchDigiLockerDocuments(otrId);

    // Save or update documents in PostgreSQL
    const savedDocuments = [];
    
    for (const doc of fetchedDocs) {
      const savedDoc = await prisma.documentWallet.upsert({
        where: {
          otrId_documentType: {
            otrId: otrId,
            documentType: doc.documentType
          }
        },
        update: {
          digilockerUri: doc.digilockerUri,
          isVerified: doc.isVerified,
          fetchedAt: doc.fetchedAt
        },
        create: {
          otrId: otrId,
          documentType: doc.documentType,
          digilockerUri: doc.digilockerUri,
          isVerified: doc.isVerified,
          fetchedAt: doc.fetchedAt
        }
      });
      savedDocuments.push(savedDoc);
    }

    return res.status(200).json({
      success: true,
      message: 'DigiLocker sync successful',
      documents: savedDocuments
    });

  } catch (error) {
    console.error('DigiLocker Sync Error:', error);
    return res.status(500).json({ error: 'Failed to sync documents from DigiLocker' });
  }
};

/**
 * GET /api/documents
 * Fetch user's document wallet from DB
 */
const getDocumentWallet = async (req, res) => {
  try {
    const { otrId } = req.user;
    
    const documents = await prisma.documentWallet.findMany({
      where: { otrId }
    });
    
    return res.status(200).json({
      success: true,
      documents
    });
  } catch (error) {
    console.error('Get Documents Error:', error);
    return res.status(500).json({ error: 'Failed to retrieve document wallet' });
  }
}

module.exports = {
  syncDocumentWallet,
  getDocumentWallet
};

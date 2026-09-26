const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth.middleware');
const documentsController = require('../controllers/documents.controller');

// Protect routes with JWT middleware
router.get('/sync-wallet', authMiddleware, documentsController.syncDocumentWallet);
router.get('/', authMiddleware, documentsController.getDocumentWallet);

module.exports = router;

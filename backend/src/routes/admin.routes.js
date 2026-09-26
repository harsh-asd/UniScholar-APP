const express = require('express');
const router = express.Router();
const verifyAdminToken = require('../middleware/admin.middleware');
const adminController = require('../controllers/admin.controller');

// Protect routes with Admin JWT middleware
router.get('/applications/pending', verifyAdminToken, adminController.getPendingApplications);
router.post('/applications/:applicationId/verify', verifyAdminToken, adminController.verifyApplication);

module.exports = router;

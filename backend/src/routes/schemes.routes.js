const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth.middleware');
const checkSchemeEligibility = require('../middleware/checkSchemeEligibility');
const schemesController = require('../controllers/schemes.controller');

// Protect this route with authMiddleware
router.get('/eligible', authMiddleware, schemesController.getEligibleSchemes);
router.get('/dbt-status/:applicationId', authMiddleware, schemesController.getDbtStatus);

// Application Submission
router.post('/apply', authMiddleware, checkSchemeEligibility, schemesController.applyForScheme);

module.exports = router;

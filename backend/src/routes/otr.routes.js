const express = require('express');
const router = express.Router();
const otrController = require('../controllers/otr.controller');

router.post('/step1-ekyc', otrController.initiateEkyc);
router.post('/step2-verify', otrController.verifyAndGenerateOtr);

module.exports = router;

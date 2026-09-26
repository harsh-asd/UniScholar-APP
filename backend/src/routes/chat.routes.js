const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/auth.middleware');
const chatController = require('../controllers/chat.controller');

// Protect route with JWT middleware
router.post('/jago', authMiddleware, chatController.handleChat);

module.exports = router;

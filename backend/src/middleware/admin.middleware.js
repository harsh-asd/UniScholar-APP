const jwt = require('jsonwebtoken');

const verifyAdminToken = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized: No token provided' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback_secret');
    
    // Ensure the token belongs to an admin
    if (!decoded.role) {
      return res.status(403).json({ error: 'Forbidden: Admin access required' });
    }

    req.admin = decoded; // { id, email, role, assignedInstitutionCode }
    next();
  } catch (error) {
    console.error('Admin JWT Verification Error:', error);
    return res.status(401).json({ error: 'Unauthorized: Invalid token' });
  }
};

module.exports = verifyAdminToken;

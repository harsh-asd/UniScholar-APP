const express = require('express');
const cors = require('cors');
require('dotenv').config();
const otrRoutes = require('./routes/otr.routes');
const schemesRoutes = require('./routes/schemes.routes');
const documentsRoutes = require('./routes/documents.routes');
const chatRoutes = require('./routes/chat.routes');
const adminRoutes = require('./routes/admin.routes');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/otr', otrRoutes);
app.use('/api/schemes', schemesRoutes);
app.use('/api/documents', documentsRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/admin', adminRoutes);

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

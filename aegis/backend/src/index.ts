import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import syncRoutes from './routes/sync.routes';
import authRoutes from './routes/auth.routes';

dotenv.config();

const app = express();

// Security Middlewares
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '50mb' })); // Support for large encrypted blobs
app.use(morgan('dev'));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/sync', syncRoutes);

// Health Check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'Aegis Zero-Knowledge API is running' });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
});

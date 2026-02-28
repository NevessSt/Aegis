import { Router } from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();
const JWT_SECRET = process.env.JWT_SECRET || 'aegis-super-secret-fallback';

/**
 * Register a new user
 * Note: passwordHash here is for server authentication ONLY.
 * The client's MasterKey / encryption keys NEVER touch this endpoint.
 */
router.post('/register', async (req: any, res: any) => {
    try {
        const { email, password } = req.body;

        // Hash password for authentication
        const passwordHash = await bcrypt.hash(password, 12);

        const user = await prisma.user.create({
            data: {
                email,
                passwordHash,
            }
        });

        const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '7d' });
        res.status(201).json({ token, isPremium: user.isPremium });
    } catch (error) {
        res.status(500).json({ error: 'Registration failed' });
    }
});

/**
 * Login existing user
 */
router.post('/login', async (req: any, res: any) => {
    try {
        const { email, password } = req.body;

        const user = await prisma.user.findUnique({ where: { email } });
        if (!user) return res.status(401).json({ error: 'Invalid credentials' });

        const isValid = await bcrypt.compare(password, user.passwordHash);
        if (!isValid) return res.status(401).json({ error: 'Invalid credentials' });

        const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '7d' });

        res.status(200).json({
            token,
            isPremium: user.isPremium,
            wrappedSyncKey: user.wrappedSyncKey
        });
    } catch (error) {
        res.status(500).json({ error: 'Login failed' });
    }
});

/**
 * Endpoint to save the user's WrappedSyncKey (SyncKey encrypted with MasterKey)
 */
router.post('/sync-key', async (req: any, res: any) => {
    try {
        const userId = req.headers['authorization']?.split(' ')[1]; // mock extraction
        // In real app, standard JWT middleware will attach req.userId
        const { wrappedSyncKey } = req.body;

        await prisma.user.update({
            where: { id: userId as string },
            data: { wrappedSyncKey }
        });

        res.status(200).json({ success: true });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update wrapped sync key' });
    }
});

export default router;

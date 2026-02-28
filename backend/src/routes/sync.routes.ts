import { Router } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// In a real implementation this would be a proper middleware using jsonwebtoken
// Stub for demonstration
const authMiddleware = (req: any, res: any, next: any) => {
    req.userId = req.headers['authorization']?.split(' ')[1]; // mock userId extraction
    if (!req.userId) return res.status(401).json({ error: 'Unauthorized' });
    next();
};

/**
 * Upload an encrypted blob to the server.
 * The server stores it exactly as received.
 */
router.post('/blob', authMiddleware, async (req: any, res: any) => {
    try {
        const { id, iv, mac, ciphertext } = req.body;

        // Server has zero knowledge of the contents
        const blob = await prisma.encryptedBlob.upsert({
            where: { id },
            update: { iv, mac, ciphertext },
            create: {
                id,
                userId: req.userId,
                iv,
                mac,
                ciphertext
            }
        });

        res.status(200).json({ success: true, timestamp: blob.lastModified });
    } catch (error) {
        res.status(500).json({ error: 'Failed to sync blob' });
    }
});

/**
 * Fetch all encrypted blobs modified after a certain timestamp for diff syncing
 */
router.get('/blobs', authMiddleware, async (req: any, res: any) => {
    try {
        const after = req.query.after ? new Date(req.query.after as string) : new Date(0);

        const blobs = await prisma.encryptedBlob.findMany({
            where: {
                userId: req.userId,
                lastModified: { gt: after }
            },
            select: { id: true, iv: true, mac: true, ciphertext: true, lastModified: true }
        });

        res.status(200).json({ blobs });
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch blobs' });
    }
});

export default router;

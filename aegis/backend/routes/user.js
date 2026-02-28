const express = require('express');
const router = express.Router();

// In a real app, this would use MongoDB. 
// For demonstration, we'll use an in-memory dictionary to track 'sentSharesCount'.
const userStats = {};

const MAX_FREE_SHARES = 3;

router.post('/share', async (req, res) => {
    try {
        const { senderId, targetPublicKey, encryptedPayload } = req.body;

        // Ensure user exists in tracker
        if (!userStats[senderId]) {
            userStats[senderId] = { sharesCount: 0, isPremium: false };
        }

        const user = userStats[senderId];

        // Check Monetization Limits
        if (!user.isPremium && user.sharesCount >= MAX_FREE_SHARES) {
            return res.status(402).json({
                error: 'PAYMENT_REQUIRED',
                message: 'You have exhausted your 3 free secure shares. Please upgrade to Aegis Premium.'
            });
        }

        // Logic to push the `encryptedPayload` to the target user's inbox
        // The server cannot read it, as it is encrypted with `targetPublicKey`

        // Increment the counter upon successful share
        user.sharesCount += 1;

        res.status(200).json({
            message: 'Payload securely transferred.',
            sharesRemaining: user.isPremium ? 'Unlimited' : (MAX_FREE_SHARES - user.sharesCount)
        });

    } catch (error) {
        res.status(500).json({ error: 'Secure Share Transfer Failed' });
    }
});

// Mock endpoint to upgrade user
router.post('/upgrade', async (req, res) => {
    const { senderId } = req.body;
    if (!userStats[senderId]) {
        userStats[senderId] = { sharesCount: 0, isPremium: false };
    }

    // In reality, this endpoint would be securely called by a Stripe/RevenueCat Webhook
    userStats[senderId].isPremium = true;

    res.status(200).json({ message: 'Upgraded to Aegis Premium!' });
});

module.exports = router;

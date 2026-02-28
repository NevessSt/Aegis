# Project Aegis - Stripe Monetization Architecture

## Overview
Aegis uses a freemium model.
- **Free**: Unlimited local encrypted notes.
- **Premium**: Cloud sync, cross-device restore, advanced vault.

## Architecture

1. **Flutter App (Client)**
   - Display a Premium Paywall (Pricing: $4.99/mo or $49.99/yr).
   - Use `flutter_stripe` or `purchases_flutter` (RevenueCat) to handle Apple App Store & Google Play Store native in-app subscriptions.
   - For web/desktop or direct billing, integrate Stripe Payment Sheets.

2. **Backend (Node.js)**
   - `stripe.routes.ts` to create Checkout Sessions.
   - `webhook.routes.ts` listening to Stripe events.
   
3. **Webhook Flow**
   - Stripe sends `checkout.session.completed` event.
   - Endpoint `/api/webhooks/stripe` verifies the signature.
   - Updates PostgreSQL `User.isPremium = true`.
   - Sends real-time notification (via WebSockets/FCM) to client to unlock Premium features (Cloud Sync).

4. **Zero-Knowledge Dependency**
   - If user downgrades or payment fails (`customer.subscription.deleted`), backend sets `isPremium = false`. 
   - Backend STOPS accepting new Sync blobs.
   - Existing encrypted blobs are held for an X-day grace period, and client is notified to export or resubscribe, after which the encrypted blobs are purged from PostgreSQL.

## Endpoint Stubs

```typescript
// Create Checkout Session
router.post('/create-checkout-session', authMiddleware, async (req, res) => {
  const session = await stripe.checkout.sessions.create({
    payment_method_types: ['card'],
    line_items: [{ price: 'price_ premium_id', quantity: 1 }],
    mode: 'subscription',
    client_reference_id: req.userId, // Link Stripe sub to User ID
    success_url: `${process.env.FRONTEND_URL}/success`,
    cancel_url: `${process.env.FRONTEND_URL}/cancel`,
  });
  res.json({ url: session.url });
});

// Webhook
router.post('/webhook', express.raw({type: 'application/json'}), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, STRIPE_WEBHOOK_SECRET);
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    await prisma.user.update({
      where: { id: session.client_reference_id },
      data: { isPremium: true, stripeCustId: session.customer }
    });
  }
  
  res.json({received: true});
});
```

# Project Aegis - App Store Compliance Notes

## Apple App Store Compliance
### 1. Data Collection & Privacy
- **App Privacy Details**: Must declare "Data Not Collected" or "Data Linked to You: None" for encrypted notes. The server only sees ciphertext. We only link email for account management.
- **Export Compliance**: Because we use AES-256 for data-at-rest and transport, we must submit an Annual Self Classification Report (ASCR) to the US government (BIS) for exporting cryptography.
- **App Store Review Data**: Reviewers need an active login. We must provide a test account. However, since encryption is tied strictly to the test account's password, give reviewers the explicit password.

### 2. Monetization
- All Premium feature upgrades (Cloud Sync) MUST go through Apple In-App Purchases (`StoreKit`). We cannot link out to Stripe natively in the iOS app without violating section 3.1.1. 
- Stripe is ONLY permitted for Web/Android (if allowed) versions. (Update: Stripe Architecture must be swapped to RevenueCat/Purchases for mobile apps).

### 3. Hidden Features (Vault)
- Apple guidelines generally discourage "Hidden Apps" or apps that falsely represent their primary purpose (e.g., a fake calculator that hides photos). 
- **Mitigation**: The app is actively marketed as an Encrypted Notes App with a "Secure Vault" feature. The calculator disguise is an opt-in *mode* inside an already secure app, rather than the entire point of the app on the App Store listing.

## Google Play Store Compliance
- Similar restrictions on crypto export (requires minimal declarations).
- Must use Google Play Billing for in-app subscriptions.
- `FLAG_SECURE` strictly enforced to block screenshots natively respects Android security guidelines.

import 'package:flutter/material.dart';
import 'dart:ui';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({Key? key}) : super(key: key);

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  // Simulating payment processing state
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Premium Gold/Dark Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF452B09), Color(0xFF0F172A)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Aegis Premium',
                    style: TextStyle(
                      fontSize: 36, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have exhausted your 3 free secure shares. Upgrade to unlock unlimited Zero-Knowledge transfers.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  _buildBenefitRow(Icons.all_inclusive, 'Unlimited Secure Peer-to-Peer Shares'),
                  const SizedBox(height: 24),
                  _buildBenefitRow(Icons.cloud_done, '10GB Off-device Encrypted Cloud Sync'),
                  const SizedBox(height: 24),
                  _buildBenefitRow(Icons.auto_awesome, 'Priority Access to AI Digest Models'),
                  
                  // Pricing Tiers
                  Row(
                    children: [
                      Expanded(
                        child: _buildSubscriptionCard(
                          title: 'Monthly',
                          price: '₦1,000',
                          duration: '/ month',
                          onTap: () => _processPayment('Monthly Subscription - ₦1,000'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSubscriptionCard(
                          title: 'Lifetime',
                          price: '₦10,000',
                          duration: ' forever',
                          isPopular: true,
                          onTap: () => _processPayment('Lifetime Access - ₦10,000'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Payment Info
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'International Cards Accepted. Your card will be charged in your local currency.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Settlements route securely to:\\nUnited Bank of Africa (UBA)\\nAcct: 1029851512 • nevess nig ltd',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.credit_card, color: Colors.white.withOpacity(0.5), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'PayPal & BTC integrations coming soon.',
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Restore Purchases', 
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required String title,
    required String price,
    required String duration,
    bool isPopular = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPopular ? const Color(0xFFFFD700).withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPopular ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.1),
            width: isPopular ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isPopular)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('BEST VALUE', style: TextStyle(color: Color(0xFF0F172A), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            Text(title, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
            const SizedBox(height: 8),
            Text(price, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(duration, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _processPayment(String planName) async {
    setState(() => _isProcessing = true);
    
    // Simulating call to payment gateway (e.g. Flutterwave / Paystack)
    // The gateway handles international currency conversion and settles to UBA (1029851512).
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isProcessing = false);
      context.read<PremiumProvider>().upgradeToPremium();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Successful for \$planName! Welcome to Aegis Premium 👑'),
          backgroundColor: const Color(0xFFFFD700),
        ),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFFFD700), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

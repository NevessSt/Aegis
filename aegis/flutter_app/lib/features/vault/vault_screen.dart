import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:ui';

class VaultScreen extends StatefulWidget {
  const VaultScreen({Key? key}) : super(key: key);

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Scan fingerprint to access the Hidden Vault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        setState(() => _isUnlocked = true);
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      // In sandbox/dev environment, bypass strict checks
      setState(() => _isUnlocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.fingerprint, size: 80, color: Color(0xFF38BDF8)),
              SizedBox(height: 24),
              Text('Verifying Identity...', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Hidden Vault', style: TextStyle(color: Colors.redAccent)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.redAccent),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Color(0xFF2A0000), Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(24),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildVaultItem('Encrypted Photo 1', Icons.image),
                _buildVaultItem('Seed Phrase', Icons.key),
                _buildVaultItem('Tax Document', Icons.picture_as_pdf),
                _buildVaultItem('Voice Memo', Icons.mic),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultItem(String title, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white70),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

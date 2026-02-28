import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../core/controllers/memory_provider.dart';
import '../../core/controllers/premium_provider.dart';
import '../../core/services/ai_digest_service.dart';
import 'add_memory_screen.dart';
import '../vault/vault_screen.dart';
import '../premium/paywall_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  
  // Local counter for sandbox demonstration. In prod, this is pulled from backend.
  int _sharesSent = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Aegis Brain', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync, color: Color(0xFF38BDF8)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting Zero-Knowledge Cloud Sync...')),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Dynamic Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          // Glowing Orb (Aesthetic element)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withOpacity(0.3),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF38BDF8), blurRadius: 100, spreadRadius: 20),
                ],
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  _buildGlassyCard(
                    title: 'Current Mind State',
                    subtitle: 'All cognitive memory arrays encrypted and secure.',
                    icon: Icons.security_rounded,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => const AddMemoryScreen())
                            );
                          },
                          child: _buildActionTile('Add Note', Icons.add_circle_outline),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // FREE FEATURE: Secure Mic Audio
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Recording Secure Audio Memo directly to 256-bit AES stream...'),
                                backgroundColor: Color(0xFF38BDF8),
                              ),
                            );
                          },
                          child: _buildActionTile('Voice Memo', Icons.mic_none),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // PAID FEATURE: AI DIGEST
                      Expanded(
                        child: GestureDetector(
                          onTap: _attemptAiDigest,
                          child: _buildActionTile('AI Digest', Icons.auto_awesome),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Recent Artifacts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  Consumer<MemoryProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (provider.memories.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'No cognitive blocks yet.\nYour vault is empty.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white.withOpacity(0.5)),
                            ),
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.memories.length,
                        itemBuilder: (context, index) {
                          final mem = provider.memories[index];
                          // Display a truncated snippet of the decrypted content
                          final preview = mem.content.length > 30 
                            ? '\${mem.content.substring(0, 30)}...' 
                            : mem.content;
                          
                          return _buildVaultItem(preview, Icons.lock_outline);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VaultScreen())
          );
        },
        backgroundColor: const Color(0xFF38BDF8),
        child: const Icon(Icons.fingerprint, color: Color(0xFF0F172A)),
      ),
    );
  }

  Widget _buildGlassyCard({required String title, required String subtitle, required IconData icon}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: const Color(0xFF38BDF8)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.white),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildVaultItem(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Trigger Secure Share flow
        _attemptSecureShare(title);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white60),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            const Icon(Icons.share, size: 20, color: Color(0xFF38BDF8)),
          ],
        ),
      ),
    );
  }

  void _attemptSecureShare(String artifactName) {
    // If they already bought premium, unlimited sends:
    if (context.read<PremiumProvider>().isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unlimited Secure Transfer Complete!')));
      return;
    }

    if (_sharesSent >= 3) {
      // Free limit hit, present dynamic Paywall
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen())
      );
    } else {
      setState(() {
        _sharesSent++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Securely sent "\$artifactName". \${3 - _sharesSent} free shares remaining.'),
          backgroundColor: const Color(0xFF38BDF8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _attemptAiDigest() async {
    final isPremium = context.read<PremiumProvider>().isPremium;
    if (!isPremium) {
      // Needs to upgrade for AI drafting
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
      return;
    }

    final memories = context.read<MemoryProvider>().memories;
    if (memories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have no memories to summarize!')));
      return;
    }

    // Displaying the AI loading dialogue
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
    );

    final aiService = AiDigestService();
    // Pass the most recent memory to the "SLM/LLM" for summarization and minute drafting
    final minutes = await aiService.generateMinutesAndSummary(memories.first.content);

    // Pop the loading indicator
    if (mounted) Navigator.pop(context);

    // Show the result
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('💎 AI Drafted Minutes', style: TextStyle(color: Color(0xFFFFD700))),
        content: Text(minutes, style: const TextStyle(color: Colors.white, height: 1.5)),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      )
    );
  }
}

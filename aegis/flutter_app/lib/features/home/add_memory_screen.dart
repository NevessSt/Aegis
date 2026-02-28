import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/controllers/memory_provider.dart';
import 'dart:ui';

class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({Key? key}) : super(key: key);

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final TextEditingController _contentController = TextEditingController();
  bool _isSaving = false;

  void _saveMemory() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) return;

    setState(() { _isSaving = true; });

    // The Provider calls DatabaseHelper which automatically Encrypts
    // the text before storing it in SQLite.
    await context.read<MemoryProvider>().addMemory(text);

    setState(() { _isSaving = false; });
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('New Cognitive Block'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(
                    child: _buildGlassyTextField(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveMemory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving 
                        ? const CircularProgressIndicator(color: Color(0xFF0F172A))
                        : const Text(
                            'Encrypt & Save', 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassyTextField() {
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
          child: TextField(
            controller: _contentController,
            maxLines: null,
            expands: true,
            style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Record a secure thought...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            ),
          ),
        ),
      ),
    );
  }
}

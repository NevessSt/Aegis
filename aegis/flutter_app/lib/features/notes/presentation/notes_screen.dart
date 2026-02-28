import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NotesScreen extends HookConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, this watches an AsyncValue covering the LocalDatabaseService
    // and decrypts notes on the fly just-in-time for display.
    final notes = [
      {'title': 'Secret Mission', 'preview': 'The coordinates are...'},
      {'title': 'AI Ideas', 'preview': 'Vector search using...'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Aegis Brain', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync, color: Colors.blueAccent),
            onPressed: () {
              // Trigger Zero-Knowledge Sync manually
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Encrypting & Syncing to Cloud...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calculate, color: Colors.grey),
            onPressed: () {
              Navigator.pushNamed(context, '/vault_calculator');
            },
            tooltip: 'Secret Vault',
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                note['title']!, 
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  note['preview']!, 
                  style: const TextStyle(color: Colors.white70)
                ),
              ),
              trailing: const Icon(Icons.lock, color: Colors.greenAccent, size: 20),
              onTap: () {
                // Open note details, fetch raw encrypted payload, decrypt via Animation transition
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          // Open new note screen
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

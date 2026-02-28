import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'encryption_service.dart';

/// Service responsible for handling sensitive Audio Memos.
/// Ensures that raw audio is NEVER written to standard unencrypted storage.
class AudioMemoService {
  final EncryptionService _encryptionService;

  AudioMemoService(this._encryptionService);

  /// Mocks recording audio directly into a memory buffer.
  /// In a full production app, you would use a package like `record` to stream 
  /// mic data directly to bytes.
  Future<Uint8List> recordAudioToBuffer(int durationSeconds) async {
    debugPrint('Recording audio for \$durationSeconds seconds...');
    // Simulating capturing audio data (PCM/WAV formatting)
    await Future.delayed(Duration(seconds: durationSeconds));
    
    // Mock audio bytes
    return Uint8List.fromList(List.generate(1024 * durationSeconds, (i) => i % 255));
  }

  /// Takes raw audio bytes, converts to base64, and encrypts using AES-256
  Future<String> secureAndEncryptAudio(Uint8List rawAudioData) async {
    final base64Audio = base64Encode(rawAudioData);
    final encryptedAudio = await _encryptionService.encryptData(base64Audio);
    return encryptedAudio;
  }
}

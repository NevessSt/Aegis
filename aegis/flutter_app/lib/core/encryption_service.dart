import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';

/// Military-grade encryption service using AES-256 for local data security.
/// Keys are stored in the platform's secure enclave / keychain.
class EncryptionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _keyStorageKey = 'aegis_master_key';

  /// Ensure we have a master key stored in the secure enclave
  Future<void> _ensureKeyExists() async {
    final existingKey = await _secureStorage.read(key: _keyStorageKey);
    if (existingKey == null) {
      // Generate a strong, cryptographically secure 256-bit key
      final secureRandom = Random.secure();
      final keyBytes = List<int>.generate(32, (i) => secureRandom.nextInt(256));
      final base64Key = base64UrlEncode(keyBytes);
      await _secureStorage.write(key: _keyStorageKey, value: base64Key);
    }
  }

  /// Retrieves the current master key
  Future<Key> _getMasterKey() async {
    await _ensureKeyExists();
    final base64Key = await _secureStorage.read(key: _keyStorageKey);
    return Key.fromBase64(base64Key!);
  }

  /// Encrypts plaintext data using AES-256 in CBC mode
  Future<String> encryptData(String plaintext) async {
    if (plaintext.isEmpty) return plaintext;
    
    final key = await _getMasterKey();
    // Unique IV for every encryption operation ensures high entropy
    final iv = IV.fromSecureRandom(16);
    
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    
    // Combine IV and Ciphertext so it can be extracted during decryption
    // Format: base64(IV):base64(Ciphertext)
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts ciphertext back to plaintext
  Future<String> decryptData(String encryptedPayload) async {
    if (encryptedPayload.isEmpty || !encryptedPayload.contains(':')) {
      return encryptedPayload;
    }
    
    final parts = encryptedPayload.split(':');
    if (parts.length != 2) throw Exception('Invalid encrypted payload format');
    
    final ivBase64 = parts[0];
    final ciphertextBase64 = parts[1];
    
    final key = await _getMasterKey();
    final iv = IV.fromBase64(ivBase64);
    
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    try {
      final decrypted = encrypter.decrypt64(ciphertextBase64, iv: iv);
      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed, potential data tampering detected.');
    }
  }
}

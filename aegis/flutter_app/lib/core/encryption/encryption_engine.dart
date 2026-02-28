import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class EncryptionEngine {
  final AesGcm algorithm = AesGcm.with256bits();

  /// Encrypts plaintext string using AES-256-GCM
  /// Returns a base64 string combining IV + Ciphertext + MAC
  Future<String> encrypt(String plaintext, SecretKey secretKey) async {
    final utf8Encoder = utf8.encoder;
    final clearText = utf8Encoder.convert(plaintext);
    
    // Generate secure random IV
    final nonce = algorithm.newNonce();
    
    final secretBox = await algorithm.encrypt(
      clearText,
      secretKey: secretKey,
      nonce: nonce,
    );

    // Combine nonce, ciphertext, and MAC into a single buffer
    final combined = BytesBuilder();
    combined.add(secretBox.nonce);
    combined.add(secretBox.mac.bytes);
    combined.add(secretBox.cipherText);

    return base64Encode(combined.toBytes());
  }

  /// Decrypts AES-256-GCM encrypted base64 payload
  Future<String> decrypt(String encryptedData, SecretKey secretKey) async {
    final combined = base64Decode(encryptedData);
    
    // Extract nonce (12 bytes for GCM)
    final nonce = combined.sublist(0, 12);
    // Extract MAC (16 bytes for GCM)
    final macBytes = combined.sublist(12, 28);
    // Extract Ciphertext
    final cipherText = combined.sublist(28);

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final clearText = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    return utf8.decode(clearText);
  }
}

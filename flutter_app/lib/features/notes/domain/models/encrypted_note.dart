import 'package:isar/isar.dart';

part 'encrypted_note.g.dart'; // Isar generator

@collection
class EncryptedNote {
  Id id = Isar.autoIncrement; // Auto-incrementing ID

  @Index(unique: true)
  late String uuid;

  /// The AES-256-GCM encrypted base64 string containing:
  /// Nonce (12 bytes) + MAC (16 bytes) + Ciphertext
  late String encryptedPayload;

  /// Timestamp of creation
  late DateTime createdAt;

  /// Timestamp of last modification, used for Sync diffing
  late DateTime updatedAt;

  /// Has this note been synced to the Zero-Knowledge Cloud?
  bool isSynced = false;
  
  /// Is this note hidden in the secret Vault?
  bool isVaulted = false;
}

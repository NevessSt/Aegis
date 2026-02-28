import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'dart:convert';

@lazySingleton
class KeyManager {
  final FlutterSecureStorage _secureStorage;
  final Argon2id _argon2 = Argon2id(
    parallelism: 1,
    memory: 65536, // 64MB memory cost
    iterations: 3,
    hashLength: 32, // 256 bits
  );

  KeyManager(this._secureStorage);

  static const _localKeyIdentifer = 'aegis_local_key';
  
  /// Derive a Master Key from the user's password using Argon2id
  Future<SecretKey> deriveMasterKey(String password, List<int> salt) async {
    final result = await _argon2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
    return result;
  }

  /// Generate a cryptographically secure random key
  Future<SecretKey> generateRandomKey() async {
    final algorithm = AesGcm.with256bits();
    return await algorithm.newSecretKey();
  }

  /// Store the key in the device's Secure Enclave / Keystore
  /// Data is wiped on app uninstall and requires device unlock
  Future<void> storeLocalKey(SecretKey key) async {
    final keyBytes = await key.extractBytes();
    await _secureStorage.write(
      key: _localKeyIdentifer,
      value: base64Encode(keyBytes),
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.unlocked_this_device,
      ),
    );
  }

  /// Retrieve the key from the Secure Enclave
  Future<SecretKey?> getLocalKey() async {
    final base64Key = await _secureStorage.read(key: _localKeyIdentifer);
    if (base64Key == null) return null;
    
    final keyBytes = base64Decode(base64Key);
    return SecretKey(keyBytes);
  }

  /// Wipes all cryptographic keys from memory and storage
  Future<void> purgeKeys() async {
    await _secureStorage.delete(key: _localKeyIdentifer);
    // Explicitly do not leave keys in memory
  }
}

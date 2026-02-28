import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:injectable/injectable.dart';
import '../features/notes/domain/models/encrypted_note.dart';
import 'core/encryption/key_manager.dart';

@singleton
class LocalDatabaseService {
  late Isar _isar;
  final KeyManager _keyManager;

  LocalDatabaseService(this._keyManager);

  /// Initializes the local secure database.
  /// If the database file needs to be wiped or encrypted, it is handled here.
  Future<void> initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    
    // In Isar, we can use the LocalKey from Secure Enclave for DB-level encryption (if supported on platform)
    // or rely on our `EncryptionEngine` for field-level encryption (used here via EncryptedNote).
    
    _isar = await Isar.open(
      [EncryptedNoteSchema],
      directory: dir.path,
      name: 'aegis_secure_db',
    );
  }

  Isar get db => _isar;

  /// Triggered via the Panic Vault feature. 
  /// Instantly shreds the local database file.
  Future<void> shredDatabase() async {
    await _isar.close(deleteFromDisk: true);
    await _keyManager.purgeKeys();
  }

  // --- CRUD for Notes ---

  Future<void> saveNote(EncryptedNote note) async {
    await _isar.writeTxn(() async {
      await _isar.encryptedNotes.put(note);
    });
  }

  Future<List<EncryptedNote>> getAllNotes({bool includeVaulted = false}) async {
    if (includeVaulted) {
      return await _isar.encryptedNotes.where().findAll();
    } else {
      return await _isar.encryptedNotes.filter().isVaultedEqualTo(false).findAll();
    }
  }

  Future<EncryptedNote?> getNoteByUuid(String uuid) async {
    return await _isar.encryptedNotes.filter().uuidEqualTo(uuid).findFirst();
  }
}

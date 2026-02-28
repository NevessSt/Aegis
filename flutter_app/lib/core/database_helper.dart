import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'encryption_service.dart';

/// Database Helper class establishing the offline-first architecture.
/// All sensitive data fields are encrypted before resting in the database.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  final EncryptionService _cryptoService = EncryptionService();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aegis_brain.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Structure for storing memories/notes
    await db.execute('''
      CREATE TABLE memories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        encryptedPayload TEXT NOT NULL,
        isSynced INTEGER NOT NULL DEFAULT 0,
        syncSignature TEXT
      )
    ''');
    
    // Vault mode specific hidden storage
    await db.execute('''
      CREATE TABLE vault_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hiddenType TEXT NOT NULL,
        encryptedPayload TEXT NOT NULL
      )
    ''');
  }

  /// Inserts a new piece of data securely
  Future<int> insertMemory(String sensitiveContent) async {
    final db = await instance.database;
    final encryptedContent = await _cryptoService.encryptData(sensitiveContent);
    
    return await db.insert('memories', {
      'timestamp': DateTime.now().toIso8601String(),
      'encryptedPayload': encryptedContent,
      'isSynced': 0, // 0 = False, 1 = True
    });
  }

  /// Retrieves all memories, decrypting them in-memory
  Future<List<Map<String, dynamic>>> getDecryptedMemories() async {
    final db = await instance.database;
    final result = await db.query('memories', orderBy: 'timestamp DESC');
    
    List<Map<String, dynamic>> decryptedResults = [];
    
    for (var row in result) {
      final decryptedContent = await _cryptoService.decryptData(row['encryptedPayload'] as String);
      decryptedResults.add({
        'id': row['id'],
        'timestamp': row['timestamp'],
        'content': decryptedContent,
        'isSynced': row['isSynced'],
      });
    }
    
    return decryptedResults;
  }
}

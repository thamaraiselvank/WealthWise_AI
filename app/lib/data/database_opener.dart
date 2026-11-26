import 'dart:io';
import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'database.dart';

const _dbFileName = 'wealthwise.db';
const _keyName = 'wealthwise_db_key_v1';

/// Generates and keeps the database encryption key in the platform keystore
/// (Android Keystore / iOS Keychain). The key never leaves the device.
class DatabaseKeyStore {
  final FlutterSecureStorage _storage;
  const DatabaseKeyStore([this._storage = const FlutterSecureStorage()]);

  Future<String> getOrCreate() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) return existing;
    final key = generateKey();
    await _storage.write(key: _keyName, value: key);
    return key;
  }

  Future<void> delete() => _storage.delete(key: _keyName);

  /// 256-bit random key as 64 hex characters.
  static String generateKey() {
    final r = Random.secure();
    return List.generate(32, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }
}

/// Applies the key and fails fast if the SQLite build has no encryption or
/// the key is wrong. Runs on the database isolate.
void applyEncryptionKey(Database db, String hexKey) {
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(hexKey)) {
    throw ArgumentError('Invalid database key format');
  }
  final cipher = db.select('PRAGMA cipher');
  if (cipher.isEmpty) {
    throw StateError('SQLite build has no encryption support (expected sqlite3mc).');
  }
  db.execute("PRAGMA key = '$hexKey'");
  // Throws "file is not a database" if the key does not match.
  db.select('SELECT count(*) FROM sqlite_master');
}

Future<File> databaseFile() async {
  final dir = await getApplicationSupportDirectory();
  return File(p.join(dir.path, _dbFileName));
}

/// Opens the encrypted app database on a background isolate.
Future<AppDatabase> openAppDatabase({
  DatabaseKeyStore keyStore = const DatabaseKeyStore(),
}) async {
  final file = await databaseFile();
  final key = await keyStore.getOrCreate();
  final db = AppDatabase(NativeDatabase.createInBackground(
    file,
    setup: (raw) => applyEncryptionKey(raw, key),
  ));
  // Force the open now so key problems surface at startup, not mid-use.
  await db.customSelect('SELECT 1').get();
  return db;
}

/// Last-resort recovery when the database cannot be opened (e.g. key lost):
/// removes the database file(s) and the key. All local data is lost.
Future<void> resetLocalData({DatabaseKeyStore keyStore = const DatabaseKeyStore()}) async {
  final file = await databaseFile();
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    final f = File('${file.path}$suffix');
    if (await f.exists()) await f.delete();
  }
  await keyStore.delete();
}

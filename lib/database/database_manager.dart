import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  Database? _database;

  DatabaseManager._internal();

  factory DatabaseManager() {
    return _instance;
  }

  Future<void> initDatabase() async {
    if (_database != null) return;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'ssh_list.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ssh_list (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hostName TEXT,
            userName TEXT,
            password TEXT,
            port INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertSSH(Map<String, dynamic> sshInfo) async {
    if (_database == null) throw Exception("Database not initialized");
    await _database!.insert('ssh_list', sshInfo);
  }

  Future<List<Map<String, dynamic>>> getSSHList() async {
    if (_database == null) throw Exception("Database not initialized");
    return await _database!.query('ssh_list');
  }

  Future<void> printDatabasePath() async {
    final databasePath = await getDatabasesPath();
    final fullPath = join(databasePath, 'ssh_list.db');
    print('Database Path: $fullPath');
  }
}
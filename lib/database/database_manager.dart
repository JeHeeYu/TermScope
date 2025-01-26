import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  Database? _database;

  DatabaseManager._internal();

  factory DatabaseManager() => _instance;

  Future<void> initDatabase() async {
    if (_database != null) return;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'ssh_list.db');

    print('Database initialized at path: $path');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print('Creating database...');
        await db.execute('''
          CREATE TABLE ssh_list (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hostName TEXT NOT NULL,
            userName TEXT NOT NULL,
            password TEXT NOT NULL,
            port INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertSSH(Map<String, dynamic> sshInfo) async {
    if (_database == null) {
      print('Database is not initialized');
      return;
    }

    final existingData = await _database!.query(
      'ssh_list',
      where: 'hostName = ? AND userName = ? AND password = ? AND port = ?',
      whereArgs: [
        sshInfo['hostName'],
        sshInfo['userName'],
        sshInfo['password'],
        sshInfo['port']
      ],
    );

    if (existingData.isNotEmpty) {
      print('Duplicate data detected: $sshInfo');
      return;
    }

    await _database!.insert('ssh_list', sshInfo);
    print('Inserted data: $sshInfo');
  }

  Future<List<Map<String, dynamic>>> getSSHList() async {
    if (_database == null) {
      print('Database is not initialized');
      return [];
    }
    return await _database!.query('ssh_list');
  }

  Future<void> printDatabasePath() async {
    final databasePath = await getDatabasesPath();
    final fullPath = join(databasePath, 'ssh_list.db');
    print('Database Path: $fullPath');
  }
}

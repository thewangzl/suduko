import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sudoku.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE best_times (
            difficulty TEXT PRIMARY KEY,
            seconds INTEGER,
            date TEXT
          )
        ''');
      },
    );
  }

  static Future<void> updateBestTime(String difficulty, int seconds) async {
    final db = await database;
    final currentBest = await getBestTime(difficulty);
    
    if (currentBest == null || seconds < currentBest) {
      await db.insert(
        'best_times',
        {
          'difficulty': difficulty,
          'seconds': seconds,
          'date': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<int?> getBestTime(String difficulty) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'best_times',
      where: 'difficulty = ?',
      whereArgs: [difficulty],
    );

    if (maps.isEmpty) return null;
    return maps.first['seconds'] as int;
  }
}
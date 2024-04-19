import 'package:workshop_mobile_uts/models/timer.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TimerDatabase {
  static final TimerDatabase instance = TimerDatabase._init();

  TimerDatabase._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('timers.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    const sql = '''
    CREATE TABLE $tableTimers(
    ${TimerFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
    ${TimerFields.title} TEXT NOT NULL,
    ${TimerFields.description} TEXT NOT NULL,
    ${TimerFields.durationTime} INTEGER NOT NULL
    )
    ''';

    await db.execute(sql);
  }

  Future<Timer> create(Timer timer) async {
    final db = await instance.database;
    final id = await db.insert(tableTimers, timer.toJson());
    return timer.copy(id: id);
  }

  Future<List<Timer>> getAllTimers() async {
    final db = await instance.database;
    final result = await db.query(tableTimers);
    return result.map((json) => Timer.fromJson(json)).toList();
  }

  Future<Timer> getTimerById(int id) async {
    final db = await instance.database;
    final result = await db
        .query(tableTimers, where: '${TimerFields.id} = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Timer.fromJson(result.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<int> deleteTimerById(int id) async {
    final db = await instance.database;
    return await db
        .delete(tableTimers, where: '${TimerFields.id} = ?', whereArgs: [id]);
  }

  Future<int> updateTimer(Timer timer) async {
    final db = await instance.database;
    return await db.update(tableTimers, timer.toJson(),
        where: '${TimerFields.id} = ?', whereArgs: [timer.id]);
  }
}

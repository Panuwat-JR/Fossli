import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const _dbName = 'fossli.db';
  static const _dbVersion = 2;

  static const table = 'fossli';

  Database? _db;
  Future<Database> get database async => _db ??= await _initDB();

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title   TEXT NOT NULL,
        species TEXT NOT NULL,
        era     TEXT NOT NULL,
        foundAt TEXT NOT NULL,
        rarity  INTEGER NOT NULL CHECK(rarity BETWEEN 1 AND 5),
        history TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('CREATE INDEX idx_${table}_title   ON $table(title);');
    await db.execute('CREATE INDEX idx_${table}_species ON $table(species);');
    await db.execute('CREATE INDEX idx_${table}_era     ON $table(era);');
    await db.execute('CREATE INDEX idx_${table}_foundAt ON $table(foundAt);');
    await db.execute('CREATE INDEX idx_${table}_rarity  ON $table(rarity);');
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute("ALTER TABLE $table ADD COLUMN history TEXT NOT NULL DEFAULT ''");
      await db.execute('CREATE INDEX IF NOT EXISTS idx_${table}_rarity ON $table(rarity);');
    }
  }

  Future<void> close() async {
    final d = _db;
    if (d != null) {
      await d.close();
      _db = null;
    }
  }
}

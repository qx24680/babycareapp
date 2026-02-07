import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'babycare_mvp.db');
    return await openDatabase(
      path,
      version: 6, // Bump version for reminder table
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Handle migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE chat_session (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          created_at INTEGER,
          updated_at INTEGER
        )
      ''');
      await db.execute('''
        CREATE TABLE chat_message (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id INTEGER NOT NULL,
          is_user INTEGER DEFAULT 0,
          message TEXT,
          timestamp INTEGER,
          FOREIGN KEY (session_id) REFERENCES chat_session (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE measurement (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          baby_id INTEGER NOT NULL,
          time INTEGER NOT NULL,
          weight REAL,
          weight_unit TEXT,
          height REAL,
          height_unit TEXT,
          head_circumference REAL,
          head_circumference_unit TEXT,
          notes TEXT,
          FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE daily_streak (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          baby_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          log_count INTEGER DEFAULT 0,
          FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 5) {
      // Add Health and Grooming fields to activity table
      await db.execute('ALTER TABLE activity ADD COLUMN temperature REAL');
      await db.execute('ALTER TABLE activity ADD COLUMN symptom TEXT');
      await db.execute('ALTER TABLE activity ADD COLUMN severity INTEGER');
      await db.execute('ALTER TABLE activity ADD COLUMN medication TEXT');
      await db.execute('ALTER TABLE activity ADD COLUMN dosage TEXT');
      await db.execute('ALTER TABLE activity ADD COLUMN grooming_type TEXT');
    }
    if (oldVersion < 6) {
      // Add reminder table
      await db.execute('''\n        CREATE TABLE reminder (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          activity_type TEXT NOT NULL,
          mode TEXT NOT NULL,
          interval_hours INTEGER,
          scheduled_date INTEGER,
          scheduled_time TEXT,
          repeat_enabled INTEGER DEFAULT 0,
          repeat_type TEXT,
          repeat_interval INTEGER,
          weekdays TEXT,
          do_not_disturb INTEGER DEFAULT 0,
          group_id TEXT,
          is_active INTEGER DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          title TEXT,
          message TEXT,
          baby_id INTEGER,
          FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE baby_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        gender TEXT

      )
    ''');

    // Unified Activity Table (Version 4+)
    await db.execute('''
      CREATE TABLE activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baby_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        duration INTEGER,
        amount REAL,
        unit TEXT,
        side TEXT,
        milk_type TEXT,
        pump_side TEXT,
        potty_type TEXT,
        is_wet INTEGER DEFAULT 0,
        is_dry INTEGER DEFAULT 0,
        hair_wash INTEGER DEFAULT 0,
        temperature REAL,
        symptom TEXT,
        severity INTEGER,
        medication TEXT,
        dosage TEXT,
        grooming_type TEXT,
        notes TEXT,
        FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE
      )
    ''');
    // Chat Tables (Version 2+)
    await db.execute('''
      CREATE TABLE chat_session (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_message (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        is_user INTEGER DEFAULT 0,
        message TEXT,
        timestamp INTEGER,
        FOREIGN KEY (session_id) REFERENCES chat_session (id) ON DELETE CASCADE
      )
    ''');

    // Measurement Table (Version 3+)
    await db.execute('''
      CREATE TABLE measurement (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baby_id INTEGER NOT NULL,
        time INTEGER NOT NULL,
        weight REAL,
        weight_unit TEXT,
        height REAL,
        height_unit TEXT,
        head_circumference REAL,
        head_circumference_unit TEXT,
        notes TEXT,
        FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE
      )
    ''');

    // Daily Streak Table (Version 4+)
    await db.execute('''
      CREATE TABLE daily_streak (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baby_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        log_count INTEGER DEFAULT 0,
        FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE
      )
    ''');

    // Reminder Table (Version 6+)
    await db.execute('''
      CREATE TABLE reminder (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_type TEXT NOT NULL,
        mode TEXT NOT NULL,
        interval_hours INTEGER,
        scheduled_date INTEGER,
        scheduled_time TEXT,
        repeat_enabled INTEGER DEFAULT 0,
        repeat_type TEXT,
        repeat_interval INTEGER,
        weekdays TEXT,
        do_not_disturb INTEGER DEFAULT 0,
        group_id TEXT,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        title TEXT,
        message TEXT,
        baby_id INTEGER,
        FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE
      )
    ''');
  }

  // Helper to close DB (useful for debugging/testing)
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

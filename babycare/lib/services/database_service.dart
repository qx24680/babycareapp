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
      version: 4, // Bump version for user_id in activity_log
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Handle migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration for Version 2: Chat Features
      await db.execute('''
        CREATE TABLE chat_conversation (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          baby_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          archived INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE chat_message (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          conversation_id INTEGER NOT NULL,
          sender_role TEXT NOT NULL,
          guardian_id INTEGER,
          message_text TEXT NOT NULL,
          topic TEXT,
          baby_age_days INTEGER,
          created_at TEXT NOT NULL,
          FOREIGN KEY (conversation_id) REFERENCES chat_conversation (id) ON DELETE CASCADE,
          FOREIGN KEY (guardian_id) REFERENCES guardian (id) ON DELETE SET NULL
        )
      ''');

      await db.execute(
        'CREATE INDEX idx_chat_message_conversation ON chat_message (conversation_id)',
      );
    }

    if (oldVersion < 3) {
      // Migration for Version 3: User Authentication
      await db.execute('''
        CREATE TABLE user (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL,
          full_name TEXT NOT NULL,
          phone_number TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute(
        'CREATE INDEX idx_user_email ON user (email)',
      );
    }

    if (oldVersion < 4) {
      // Migration for Version 4: Add user_id to activity_log
      await db.execute('ALTER TABLE activity_log ADD COLUMN user_id INTEGER');
      await db.execute(
        'CREATE INDEX idx_activity_log_user ON activity_log (user_id)',
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // User table for authentication
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        phone_number TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_user_email ON user (email)',
    );

    await db.execute('''
      CREATE TABLE baby_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dob TEXT NOT NULL,
        feeding_type TEXT NOT NULL,
        birth_weight REAL NOT NULL,
        height REAL NOT NULL,
        gender TEXT,
        country TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE guardian (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        baby_id INTEGER NOT NULL,
        FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE activity_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baby_id INTEGER NOT NULL,
        user_id INTEGER,
        activity_type TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT,
        details TEXT,
        FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE SET NULL
      )
    ''');

    // Index for faster queries on timeline
    await db.execute(
      'CREATE INDEX idx_activity_log_baby_time ON activity_log (baby_id, start_time)',
    );
    await db.execute(
      'CREATE INDEX idx_activity_log_type ON activity_log (activity_type)',
    );

    await db.execute('''
      CREATE TABLE reminder (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baby_id INTEGER NOT NULL,
        activity_type TEXT NOT NULL,
        reminder_time TEXT NOT NULL,
        repeat_rule TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE notification_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_type TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        quiet_hours_start TEXT,
        quiet_hours_end TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_streak (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baby_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        log_count INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE,
        UNIQUE(baby_id, date)
      )
    ''');

    // Chat Tables
    await db.execute('''
      CREATE TABLE chat_conversation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        baby_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        archived INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (baby_id) REFERENCES baby_profile (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_message (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id INTEGER NOT NULL,
        sender_role TEXT NOT NULL,
        guardian_id INTEGER,
        message_text TEXT NOT NULL,
        topic TEXT,
        baby_age_days INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (conversation_id) REFERENCES chat_conversation (id) ON DELETE CASCADE,
        FOREIGN KEY (guardian_id) REFERENCES guardian (id) ON DELETE SET NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_chat_message_conversation ON chat_message (conversation_id)',
    );
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

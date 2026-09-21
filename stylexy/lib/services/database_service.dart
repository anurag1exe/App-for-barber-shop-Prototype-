import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._();

  DatabaseService._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'stylexy.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE,
        photoPath TEXT,
        role TEXT NOT NULL DEFAULT 'customer',
        referralCode TEXT NOT NULL UNIQUE,
        hasUsedReferral INTEGER NOT NULL DEFAULT 0,
        appliedReferralCode TEXT,
        passwordHash TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE wallet_transactions (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE barbers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        photoPath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE time_slots (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        barberId TEXT NOT NULL,
        barberName TEXT NOT NULL,
        isBooked INTEGER NOT NULL DEFAULT 0,
        bookedByUserId TEXT,
        bookingId TEXT,
        FOREIGN KEY (barberId) REFERENCES barbers(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        serviceId TEXT NOT NULL,
        serviceName TEXT NOT NULL,
        servicePrice REAL NOT NULL,
        barberId TEXT NOT NULL,
        barberName TEXT NOT NULL,
        slotId TEXT NOT NULL,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'confirmed',
        isRated INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (barberId) REFERENCES barbers(id),
        FOREIGN KEY (slotId) REFERENCES time_slots(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ratings (
        id TEXT PRIMARY KEY,
        bookingId TEXT NOT NULL UNIQUE,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        barberId TEXT NOT NULL,
        barberName TEXT NOT NULL,
        serviceId TEXT NOT NULL,
        serviceName TEXT NOT NULL,
        stars REAL NOT NULL,
        comment TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (bookingId) REFERENCES bookings(id),
        FOREIGN KEY (userId) REFERENCES users(id),
        FOREIGN KEY (barberId) REFERENCES barbers(id)
      )
    ''');

    // Seed default barbers
    for (final barber in [
      {'id': 'barber_1', 'name': 'Rahul'},
      {'id': 'barber_2', 'name': 'Vikram'},
      {'id': 'barber_3', 'name': 'Amit'},
    ]) {
      await db.insert('barbers', barber);
    }

    // Seed admin account (password: admin123)
    await db.insert('users', {
      'id': 'admin_001',
      'name': 'Shop Owner',
      'phone': '9999999999',
      'role': 'admin',
      'referralCode': 'ADMIN000',
      'hasUsedReferral': 0,
      'passwordHash': '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', // admin123
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // Generic CRUD helpers
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
}

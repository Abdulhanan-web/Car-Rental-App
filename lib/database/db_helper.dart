// ============= lib/database/db_helper.dart =============
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'car_rental.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Users table
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            phone TEXT,
            memberSince TEXT
          )
        ''');

        // Cars table
        await db.execute('''
          CREATE TABLE cars (
            id TEXT PRIMARY KEY,
            brand TEXT,
            model TEXT,
            year TEXT,
            pricePerDay REAL,
            type TEXT,
            pickupLocation TEXT,
            description TEXT,
            imageUrl TEXT,
            ownerId TEXT,
            mileage TEXT,
            fuelType TEXT,
            transmission TEXT,
            registeredIn TEXT,
            exteriorColor TEXT,
            assembly TEXT,
            engineCapacity TEXT,
            isFavorite INTEGER
          )
        ''');

        // Chats table
        await db.execute('''
          CREATE TABLE chats (
            id TEXT PRIMARY KEY,
            userName TEXT,
            timestamp TEXT
          )
        ''');

        // Messages table
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            chatId TEXT,
            text TEXT,
            isMe INTEGER,
            time TEXT,
            FOREIGN KEY (chatId) REFERENCES chats (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // --- User Operations ---
  Future<void> insertUser(Map<String, dynamic> user) async {
    final dbClient = await db;
    await dbClient.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(String id) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  // --- Car Operations ---
  Future<void> insertCar(Map<String, dynamic> car) async {
    final dbClient = await db;
    await dbClient.insert('cars', car, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getCars() async {
    final dbClient = await db;
    return await dbClient.query('cars');
  }

  Future<void> deleteCar(String id) async {
    final dbClient = await db;
    await dbClient.delete('cars', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateCar(Map<String, dynamic> car) async {
    final dbClient = await db;
    await dbClient.update('cars', car, where: 'id = ?', whereArgs: [car['id']]);
  }

  // --- Chat Operations ---
  Future<void> insertChat(Map<String, dynamic> chat) async {
    final dbClient = await db;
    await dbClient.insert('chats', chat, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getChats() async {
    final dbClient = await db;
    return await dbClient.query('chats');
  }

  Future<void> insertMessage(Map<String, dynamic> message) async {
    final dbClient = await db;
    await dbClient.insert('messages', message);
  }

  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    final dbClient = await db;
    return await dbClient.query('messages', where: 'chatId = ?', whereArgs: [chatId], orderBy: 'time ASC');
  }
}

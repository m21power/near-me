import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

import '../../../domain/entities/connection_model.dart';

class DatabaseHelper {
  static Database? _database;

  // Singleton pattern to ensure only one database instance
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('connections.db');
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB(String path) async {
    final dbPath = await getDatabasesPath();
    final dbLocation = join(dbPath, path);

    return await openDatabase(
      dbLocation,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create the connection table
  Future _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE connections(
      id TEXT PRIMARY KEY,
      name TEXT,
      profilePic TEXT,
      gender TEXT,
      isOnline INTEGER,
      lastSeen TEXT
    )''');
  }

  // Insert a new connection into the database
  Future<void> insertConnection(ConnectionModel connection) async {
    final db = await instance.database;

    // Convert the object to map and insert into the database
    await db.insert(
      'connections',
      connection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if id exists
    );
  }

  // Update a connection if it exists (like changing name or profile pic)
  Future<void> updateConnection(ConnectionModel connection) async {
    final db = await instance.database;

    await db.update(
      'connections',
      connection.toMap(),
      where: 'id = ?',
      whereArgs: [connection.id],
    );
  }

  // Get all connections
  Future<List<ConnectionModel>> getAllConnections() async {
    final db = await instance.database;
    final result = await db.query('connections');

    return result.map((map) => ConnectionModel.fromMap(map)).toList();
  }

  // Get a single connection by ID
  Future<ConnectionModel?> getConnectionById(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'connections',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return ConnectionModel.fromMap(result.first);
    } else {
      return null;
    }
  }

  // Delete a connection by ID
  Future<void> deleteConnection(String id) async {
    final db = await instance.database;

    await db.delete(
      'connections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Method to delete all data from the database
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('connections'); // Clears the connections table
  }

  // Close the database
  Future<void> closeDatabase() async {
    final db = await instance.database;
    db.close();
  }
}

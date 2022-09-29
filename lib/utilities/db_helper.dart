import 'dart:developer';

import 'package:sqflite/sqflite.dart';

class DbHelper {
  // Initial db
  static Future<Database> db() async {
    return openDatabase(
      'cashflow_app.db',
      version: 1,
      onCreate: (Database database, int version) async {
        await createTableTransaction(database);
        await createTableUser(database);
        await insertDataUser(database);
      },
    );
  }

  // Create table transaction
  static Future<void> createTableTransaction(Database database) async {
    await database.execute("""
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        date TEXT,
        nominal INTEGER,
        description TEXT,
        category TEXT
      )
    """);
  }

  // Create table user
  static Future<void> createTableUser(Database database) async {
    await database.execute("""
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        username TEXT,
        email TEXT,
        password TEXT,
        photo TEXT
      )
    """);
  }

  // Insert single data user
  static Future<void> insertDataUser(Database database) async {
    await database.execute("""
      INSERT INTO users (name, username, email, password, photo) VALUES 
      ('Farlan', 'farlan', 'farlan@gmail.com', 'secret123', 'assets/images/profil.jpg'),
      ('Farid Maulana', 'faridmaulana', 'farid@gmail.com', 'secret123', 'assets/images/profile.jpg')
    """);
  }

  // Login
  static Future<List<Map<String, dynamic>>> login(
      String username, String password) async {
    final db = await DbHelper.db();
    final data = db.query('users',
        columns: ['id'],
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
        limit: 1);
        
    return data;
  }

  // Create new transaction
  static Future<int> createTransaction(
    String date,
    int nominal,
    String description,
    String category,
  ) async {
    final db = await DbHelper.db();

    final data = {
      'date': date,
      'nominal': nominal,
      'description': description,
      'category': category,
    };

    final id = await db.insert(
      'transactions',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  // Fetch all data
  static Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final db = await DbHelper.db();
    return db.query('transactions', orderBy: 'id DESC');
  }
}

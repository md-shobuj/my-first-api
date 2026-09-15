import 'package:sqlite3/sqlite3.dart';

Database openDb() {
  final db = sqlite3.open('products.db');

  db.execute('''
    CREATE TABLE IF NOT EXISTS products
    (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, price REAL NOT NULL)
  ''');

  db.execute('''Create Table if Not Exists users
  (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT NOT NULL UNIQUE, password TEXT NOT NULL)''');

  return db;
}
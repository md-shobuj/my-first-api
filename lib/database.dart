import 'package:postgres/postgres.dart';

Future<Connection> openDb(String databaseUrl) async {
  final uri = Uri.parse(databaseUrl);

  final connection = await Connection.open(
    Endpoint(
      host: uri.host,
      port: 5432,
      database: uri.path.substring(1),
      username: uri.userInfo.split(':')[0],
      password: uri.userInfo.split(':')[1],
    ),
    settings: const ConnectionSettings(sslMode: SslMode.require),
  );

  await connection.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL
    )
  ''');

  await connection.execute('''
    CREATE TABLE IF NOT EXISTS products (
      id SERIAL PRIMARY KEY,
      name TEXT NOT NULL,
      price REAL NOT NULL
    )
  ''');

  await connection.execute('''
    CREATE TABLE IF NOT EXISTS orders (
      id SERIAL PRIMARY KEY,
      user_id INT REFERENCES users(id)
    )
  ''');

  await connection.execute('''
    CREATE TABLE IF NOT EXISTS order_items (
      id SERIAL PRIMARY KEY,
      order_id INT REFERENCES orders(id),
      product_id INT REFERENCES products(id),
      quantity INT NOT NULL
    )
  ''');

  return connection;
}
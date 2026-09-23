import 'package:my_first_api/models/products.dart' show Products;
import 'package:postgres/postgres.dart';

class Productrepositories {
  final Connection _db;

  Productrepositories(this._db);

  Future<List<Products>> getAllProducts({
    int limit = 10,
    int offset = 0,
  }) async {
    final result = await _db.execute(
      r'SELECT * FROM products LIMIT $1 OFFSET $2',
      parameters: [limit, offset],
    );

    return result.map((row) => Products.fromMap(row.toColumnMap())).toList();
  }

  Future<Products?> getProductById(int id) async {
    final result = await _db.execute(
      r'SELECT * FROM products WHERE id = $1',
      parameters: [id],
    );
    if (result.isEmpty) {
      return null;
    }
    return Products.fromMap(result.first.toColumnMap());
  }

  Future<Products> createProduct(String name, double price, int userId) async {
    final result = await _db.execute(
      r'INSERT INTO products (name, price,user_id) VALUES ($1, $2,$3) RETURNING *',
      parameters: [name, price, userId],
    );
    final id = result.first.toColumnMap()['id'] as int;
    return Products(id: id, name: name, price: price, userId: userId);
  }

  Future<Products?> updateProduct(int id, String name, double price) async {
    final existing = await getProductById(id);
    if (existing == null) {
      return null;
    }

    await _db.execute(
      r'UPDATE products SET name = $1, price = $2 WHERE id = $3',
      parameters: [name, price, id],
    );

    return Products(id: id, name: name, price: price, userId: existing.userId);
  }

  Future<Products?> deleteProduct(int id) async {
    final existing = await getProductById(id);
    if (existing == null) {
      return null;
    }

    await _db.execute(
      r'DELETE FROM products WHERE id = $1',
      parameters: [id],
    );

    return existing;
  }
}

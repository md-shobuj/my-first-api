import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final db = await context.read<Future<Connection>>();

  switch (context.request.method) {
    case HttpMethod.put:
      return _handlePut(context, db, id);
    case HttpMethod.delete:
      return _handleDelete(db, id);
    default:
      return Response(statusCode: 405, body: 'Method Not Allowed');
  }
}

Future<Response> _handlePut(
  RequestContext context,
  Connection db,
  String id,
) async {
  final body = await context.request.json() as Map<String, dynamic>;

  final existing = await db.execute(
    r'SELECT * FROM products WHERE id = $1',
    parameters: [int.parse(id)],
  );

  if (existing.isEmpty) {
    return Response(statusCode: 404, body: 'Product Not Found');
  }

  await db.execute(
    r'UPDATE products SET name = $1, price = $2 WHERE id = $3',
    parameters: [body['name'], body['price'], int.parse(id)],
  );

  final result = await db.execute(
    r'SELECT * FROM products WHERE id = $1',
    parameters: [int.parse(id)],
  );

  final updated = result.first.toColumnMap();

  return Response(
    body: jsonEncode(updated),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<Response> _handleDelete(Connection db, String id) async {
  final existing = await db.execute(
    r'SELECT * FROM products WHERE id = $1',
    parameters: [int.parse(id)],
  );

  if (existing.isEmpty) {
    return Response(statusCode: 404, body: 'Product Not Found');
  }

  final removed = existing.first.toColumnMap();

  await db.execute(
    r'DELETE FROM products WHERE id = $1',
    parameters: [int.parse(id)],
  );

  return Response(
    statusCode: 200,
    body: jsonEncode(removed),
    headers: {'Content-Type': 'application/json'},
  );
}
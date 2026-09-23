import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = await context.read<Future<Connection>>();
  final userId = context.read<int>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGetOrders(userId, db);
    case HttpMethod.post:
      return _handlePostOrder(userId, db, context);
    default:
      return Response(statusCode: 405, body: 'Method Not Allowed');
  }
}

Future<Response> _handleGetOrders(int userId, Connection db) async {
  final orderResult = await db.execute(
    r'SELECT id FROM orders WHERE user_id = $1',
    parameters: [userId],
  );

  final orders = <Map<String, dynamic>>[];

  for (final orderRow in orderResult) {
    final orderId = orderRow.toColumnMap()['id'];

    final itemsResult = await db.execute(
      r'''
      SELECT products.id, products.name, products.price, order_items.quantity
      FROM order_items
      JOIN products ON order_items.product_id = products.id
      WHERE order_items.order_id = $1
      ''',
      parameters: [orderId],
    );

    final items = itemsResult.map((row) => row.toColumnMap()).toList();

    orders.add({'order_id': orderId, 'items': items});
  }

  return Response(
    body: jsonEncode({'success': true, 'data': orders}),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<Response> _handlePostOrder(
  int userId,
  Connection db,
  RequestContext context,
) async {
  final body = await context.request.json() as Map<String, dynamic>;

  final items = body['items'];
  if (items == null || items is! List || items.isEmpty) {
    return Response(statusCode: 400, body: 'Items list is required');
  }

  final orderResult = await db.execute(
    r'INSERT INTO orders (user_id) VALUES ($1) RETURNING id',
    parameters: [userId],
  );
  final orderId = orderResult.first.toColumnMap()['id'];

  for (final item in items) {
    final productId = item['product_id'];
    final quantity = item['quantity'];

    if (productId == null || quantity == null) {
      continue;
    }

    await db.execute(
      r'INSERT INTO order_items (order_id, product_id, quantity) VALUES ($1, $2, $3)',
      parameters: [orderId, productId, quantity],
    );
  }

  return Response(
    statusCode: 201,
    body: jsonEncode({'success': true, 'data': {'order_id': orderId}}),
    headers: {'Content-Type': 'application/json'},
  );
}
import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:my_first_api/repositories/product_repositories.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = await context.read<Future<Connection>>();
  final repo = Productrepositories(db);

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGet(repo, context);
    case HttpMethod.post:
      return _handlePost(context, repo);
    default:
      return Response(statusCode: 405, body: 'Method Not Allowed');
  }
}

Future<Response> _handleGet(
  Productrepositories repo,
  RequestContext context,
) async {
  final queryParameters = context.request.uri.queryParameters;

  final page = int.tryParse(queryParameters['page'] ?? '1') ?? 1;
  final limit = int.tryParse(queryParameters['limit'] ?? '10') ?? 10;
  final offset = (page - 1) * limit;

  final products = await repo.getAllProducts(limit: limit, offset: offset);

  return Response(
    body: jsonEncode({
      'success': true,
      'data': products.map((p) => p.toJson()).toList(), // 💡 Model -> JSON
      'meta': {'page': page, 'limit': limit},
    }),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<Response> _handlePost(
  RequestContext context,
  Productrepositories repo,
) async {
  final Map<String, dynamic> body;
  try {
    body = await context.request.json() as Map<String, dynamic>;
  } catch (e) {
    return Response(statusCode: 400, body: 'Invalid JSON');
  }

  if (body['name'] == null || body['name'] is! String) {
    return Response(statusCode: 400, body: 'Name is required');
  }
  if (body['price'] == null || body['price'] is! num) {
    return Response(statusCode: 400, body: 'Price is required');
  }

  final userId = context.read<int>();

  final newProduct = await repo.createProduct(
    body['name'] as String,
    (body['price'] as num).toDouble(),
    userId,
  );

  return Response(
    statusCode: 201,
    body: jsonEncode({
      'success': true,
      'data': newProduct.toJson(),
    }),
    headers: {'Content-Type': 'application/json'},
  );
}

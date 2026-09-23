import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:my_first_api/repositories/product_repositories.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final db = await context.read<Future<Connection>>();
  final repo = Productrepositories(db);

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGet(repo, id);
    case HttpMethod.put:
      return _handlePut(context, repo, id);
    case HttpMethod.delete:
      return _handleDelete(context, repo, id);
    default:
      return Response(statusCode: 405, body: 'Method Not Allowed');
  }
}

Future<Response> _handleGet(Productrepositories repo, String id) async {
  final productId = int.tryParse(id);
  if (productId == null) {
    return Response(statusCode: 400, body: 'Invalid Product ID');
  }
  final product = await repo.getProductById(productId);

  if (product == null) {
    return Response(statusCode: 404, body: 'Product Not Found');
  }

  return Response(
    body: jsonEncode({
      'success': true,
      'data': product.toJson(),
    }),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<Response> _handlePut(
  RequestContext context,
  Productrepositories repo,
  String id,
) async {
  final productId = int.tryParse(id);
  if (productId == null) {
    return Response(statusCode: 400, body: 'Invalid Product ID');
  }

  // 🔒 ১. প্রোডাক্ট পাওয়া যাচ্ছে কিনা চেক
  final existing = await repo.getProductById(productId);
  if (existing == null) {
    return Response(statusCode: 404, body: 'Product Not Found');
  }

  // 🔒 ২. OWNERSHIP CHECK (মালিকানা যাচাই): যদি বর্তমান ইউজারের আইডি এবং প্রোডাক্টের মালিক এক না হয়
  final currentUserId = context.read<int>();
  if (existing.userId != currentUserId) {
    return Response(
      statusCode: 403,
      body: jsonEncode({'message': 'Forbidden: You do not own this product'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final body = await context.request.json() as Map<String, dynamic>;

  if (body['name'] == null ||
      body['name'] is! String ||
      (body['name'] as String).isEmpty) {
    return Response(statusCode: 400, body: 'Valid product name is required');
  }
  if (body['price'] == null ||
      body['price'] is! num ||
      (body['price'] as num) <= 0) {
    return Response(statusCode: 400, body: 'Valid product price is required');
  }

  final updatedProduct = await repo.updateProduct(
    productId,
    body['name'] as String,
    (body['price'] as num).toDouble(),
  );

  return Response(
    body: jsonEncode({
      'success': true,
      'data': updatedProduct?.toJson(),
    }),
    headers: {'Content-Type': 'application/json'},
  );
}

Future<Response> _handleDelete(
  RequestContext context,
  Productrepositories repo,
  String id,
) async {
  final productId = int.tryParse(id);
  if (productId == null) {
    return Response(statusCode: 400, body: 'Invalid Product ID');
  }

  // 🔒 ১. প্রোডাক্ট পাওয়া যাচ্ছে কিনা চেক
  final existing = await repo.getProductById(productId);
  if (existing == null) {
    return Response(statusCode: 404, body: 'Product Not Found');
  }

  // 🔒 ২. OWNERSHIP CHECK (মালিকানা যাচাই): যদি বর্তমান ইউজারের আইডি এবং প্রোডাক্টের মালিক এক না হয়
  final currentUserId = context.read<int>();
  if (existing.userId != currentUserId) {
    return Response(
      statusCode: 403,
      body: jsonEncode({'message': 'Forbidden: You do not own this product'}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  final deletedProduct = await repo.deleteProduct(productId);

  return Response(
    statusCode: 200,
    body: jsonEncode({
      'success': true,
      'data': deletedProduct?.toJson(),
    }),
    headers: {'Content-Type': 'application/json'},
  );
}

import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:my_first_api/database.dart';
import 'package:postgres/postgres.dart';
import '../main.dart';

Handler middleware(Handler handler) {
  FutureOr<Response> handlerWithAuth(RequestContext context) {
    final path = context.request.uri.path;

 
    if (path == '/register' || path == '/login') {
      return handler(context);
    }

    final authHeader = context.request.headers['Authorization'];

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response(statusCode: 401, body: 'Missing or invalid token');
    }

    final token = authHeader.substring(7);

    final JWT jwt;
    try {
      jwt = JWT.verify(token, SecretKey(env['JWT_SECRET']!));
    } catch (e) {
      return Response(statusCode: 401, body: 'Invalid or expired token');
    }

    final userId = jwt.payload['userId'] as int;
    final newContext = context.provide<int>(() => userId);

    return handler(newContext);
  }

  return handlerWithAuth.use(
    provider<Future<Connection>>((context) => openDb(env['DATABASE_URL']!)),
  );
}
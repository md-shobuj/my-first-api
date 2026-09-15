



import 'dart:async';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../main.dart';

Handler middleware(Handler handler) {
  FutureOr<Response> handlerWithAuth(RequestContext context) {
    final authHeader = context.request.headers['Authorization'];

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response(statusCode: 401, body: 'Missing or invalid token');
    }

    final token = authHeader.substring(7);
    final secret =env['JWT_SECRET']!;

    try {
      JWT.verify(token, SecretKey(secret));
    } catch (e) {
      return Response(statusCode: 401, body: 'Invalid or expired token');
    }

    return handler(context);
  }

  FutureOr<Response> handlerWithLogging(RequestContext context) {
    print("Request: ${context.request.method} ${context.request.uri.path}");
    return handlerWithAuth(context);
  }

  return handlerWithLogging;
}
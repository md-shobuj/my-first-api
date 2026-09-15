import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405, body: 'Method Not Allowed');
  }

  final db = context.read<Database>();
  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'];
  final password = body['password'];

  if (email == null || email is! String) {
    return Response(statusCode: 400, body: 'Email is required');
  }
  if (password == null || password is! String) {
    return Response(statusCode: 400, body: 'Password is required');
  }

  final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

  try {
    db.execute(
      'INSERT INTO users (email, password) VALUES (?, ?)',
      [email, hashedPassword],
    );
  } catch (e) {
    return Response(statusCode: 409, body: 'Email already exists');
  }

  return Response(
    statusCode: 201,
    body: jsonEncode({'message': 'User registered successfully'}),
    headers: {'Content-Type': 'application/json'},
  );
}
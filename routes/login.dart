import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:sqlite3/sqlite3.dart';

import '../main.dart';

Future<Response> onRequest(RequestContext context) async{

  if(context.request.method != HttpMethod.post){
    return Response(statusCode:  405,body: 'Method Not Allowed');
  }
  final db=context.read<Database>();
  final body = await context.request.json() as Map<String,dynamic>;

  final email = body['email'] ;
  final password = body['password'] ;
  if(email == null || email is! String){
    return Response(statusCode:  400
    ,body: 'Email is required'
    ,headers: {'Content-Type':'application/json'});
  }
  if(password == null || password is! String){
    return Response(statusCode:  400
    ,body: 'Password is required'
    ,headers: {'Content-Type':'application/json'});
  }
  final result =db.select('SELECT * FROM users WHERE email=?',[email]);
  if(result.isEmpty){
    return Response(statusCode:  400
    ,body: 'Email not found'
    ,headers: {'Content-Type':'application/json'});
  }
 
  final user =result.first;
  final storedHash = user['password'] as String;
  final isValid = BCrypt.checkpw(password, storedHash);
  if(!isValid){
    return Response(statusCode:  400
    ,body: 'Password is incorrect'
    ,headers: {'Content-Type':'application/json'});

  }

    final jwt =JWT({'userId':user['id'],'email':user['email']});
   final secret =env['JWT_SECRET']!;
   final token =jwt.sign(SecretKey(secret));
    
    return Response(body: jsonEncode({'token':token}),
    headers: {'Content-Type':'application/json'});


  
}

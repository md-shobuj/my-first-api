import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async{
  final db = await context.read<Future<Connection>>();
  switch(context.request.method){
    case HttpMethod.get:
      return _handleGet(db);
    case HttpMethod.post:
      return  _handlePost(context,db);
    default:
      return Response(statusCode:  405,body: 'Method Not Allowed');
  }
}

Future<Response> _handleGet(Connection db) async{

  final result = await db.execute('SELECT * FROM products');

  final products = result.map((row) => row.toColumnMap()).toList();

  return Response(body: jsonEncode(products) ,
  headers: {'Content-Type':'application/json'});

}

Future<Response> _handlePost(RequestContext context,
Connection db) async{
 
 final Map<String,dynamic>body;
 try{
  body = await context.request.json() as Map<String,dynamic>;
 }catch(e){
  return Response(statusCode:  400
  ,body: 'Invalid JSON'
  ,headers: {'Content-Type':'application/json'});
  }
  if(body['name'] == null || body['name'] is! String){
    return Response(statusCode:  400
    ,body: 'Name is required'
    ,headers: {'Content-Type':'application/json'});
  }
  if(body['price'] == null || body['price'] is! num){
    return Response(statusCode:  400
    ,body: 'Price is required'
    ,headers: {'Content-Type':'application/json'});
  }
  final result = await db.execute(r'INSERT INTO products (name,price) VALUES ($1,$2) RETURNING id',parameters: [body['name'],body['price']]);
  final id = result.first.toColumnMap()['id'];

  return Response(statusCode:  201,
  body :jsonEncode({'id':id,'name':body['name'],'price':body['price']}),
  
  headers: {'Content-Type':'application/json'});

 }
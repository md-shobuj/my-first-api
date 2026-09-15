import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';


Future<Response> onRequest(RequestContext context) async{
  final db = context.read<Database>();
  switch(context.request.method){
    case HttpMethod.get:
      return _handleGet(db);
    case HttpMethod.post:
      return  _handlePost(context,db);
    default:
      return Response(statusCode:  405,body: 'Method Not Allowed');
  }
}

Response _handleGet(Database db){

  final result = db.select('SELECT * FROM products');

  final products = result.map((row)=>{
    'id':row['id'],
    'name':row['name'],
    'price':row['price'],
     }).toList();

  return Response(body: jsonEncode(products) ,
  headers: {'Content-Type':'application/json'});

}

Future<Response> _handlePost(RequestContext context,
Database db) async{
 
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
  if(body['price'] == null || body['price'] is! double){
    return Response(statusCode:  400
    ,body: 'Price is required'
    ,headers: {'Content-Type':'application/json'});
  }
  db.execute('INSERT INTO products (name,price) VALUES (?,?)',[body['name'],body['price']]);
  final id =db.lastInsertRowId;

  return Response(statusCode:  201,
  body :jsonEncode({'id':id,'name':body['name'],'price':body['price']}),
  
  headers: {'Content-Type':'application/json'});

 }
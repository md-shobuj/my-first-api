import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:sqlite3/sqlite3.dart';

 Future<Response> onRequest(RequestContext context,String id) async{
  final db = context.read<Database>();
  switch(context.request.method){
    case HttpMethod.put:
      return _handlePut(context,id,db);
    case HttpMethod.delete:
      return _handleDelete(id,db);
    default:
      return Response(statusCode:  405,body: 'Method Not Allowed');
  }
 }
  Future<Response> _handlePut(RequestContext context,String id,Database db) async{
    final body = await context.request.json() as Map<String,dynamic>;
    final existing =db.select(
      'SELECT * FROM products WHERE id = ?',
      [int.parse(id)],
    );
    if(existing.isEmpty){
      return Response(statusCode:  404, body: 'Product Not Found');
    }
    db.execute(
      'UPDATE products SET name = ?, price = ? WHERE id = ?',
      [body['name'],body['price'],int.parse(id)],
    );
    final result = db.select(
      'SELECT * FROM products WHERE id = ?',
      [int.parse(id)],
    );
    if(result.isEmpty){
      return Response(statusCode:  404, body: 'Product Not Found');
    }
   
   return Response(body :jsonEncode({
     'id':result[0]['id'],
     'name':result[0]['name'],
     'price':result[0]['price'],
   }),
   headers: {'Content-Type':'application/json'});

  }
Response _handleDelete(String id, Database db) {
  final existing = db.select(
    'SELECT * FROM products WHERE id = ?',
    [int.parse(id)],
  );

  if (existing.isEmpty) {
    return Response(statusCode: 404, body: 'Product Not Found');
  }

  final removed = existing.first;

  db.execute('DELETE FROM products WHERE id = ?', [int.parse(id)]);

  return Response(
    statusCode: 200,
    body: jsonEncode({
      'id': removed['id'],
      'name': removed['name'],
      'price': removed['price'],
    }),
    headers: {'Content-Type': 'application/json'},
  );
}
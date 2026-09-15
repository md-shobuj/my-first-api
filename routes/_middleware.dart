import 'package:dart_frog/dart_frog.dart';
import 'package:my_first_api/database.dart';
import 'package:sqlite3/sqlite3.dart';

Handler middleware(Handler handler) {
  return handler.use(provider<Database>((context) => openDb()));
}
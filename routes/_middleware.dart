import 'package:dart_frog/dart_frog.dart';
import 'package:my_first_api/database.dart';
import 'package:postgres/postgres.dart';

import '../main.dart';

Handler middleware(Handler handler) {

  return handler.use(provider<Future<Connection>>((context) => openDb(env['DATABASE_URL']!)));
}
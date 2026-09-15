import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:dart_frog/dart_frog.dart';

late DotEnv env;

Future<void> init(InternetAddress ip, int port) async {
  env = DotEnv(includePlatformEnvironment: true)..load();
}

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  return serve(handler, ip, port);
}
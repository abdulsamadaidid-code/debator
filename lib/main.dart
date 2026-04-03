import 'package:debator/app/app.dart';
import 'package:debator/app/bootstrap.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await AppBootstrap.createRepository();
  runApp(DebatorApp(repository: repository));
}

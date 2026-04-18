import 'package:debator/app/app.dart';
import 'package:debator/app/bootstrap.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await AppBootstrap.create();
  runApp(DebatorApp(bootstrap: bootstrap));
}

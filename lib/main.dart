import 'package:flutter/material.dart';
import 'app.dart';
import 'core/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeApp();

  runApp(const GBPayUserApp());
}

Future<void> _initializeApp() async {
  await LocalStorage.init(); // Initialize local storage for GBPay Users
}

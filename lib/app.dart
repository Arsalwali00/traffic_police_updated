import 'package:flutter/material.dart';
import 'config/routes.dart';
import 'config/theme.dart';

class GBPayUserApp extends StatelessWidget {
  const GBPayUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GBPay Users',
      theme: AppTheme.darkTheme, // ✅ Maintains consistency with the app's theme
      initialRoute: Routes.initial, // ✅ Uses a constant for better maintainability
      routes: Routes.getRoutes(), // ✅ Centralized route management
    );
  }
}

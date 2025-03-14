import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class Financee extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Financee',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: LoginPage(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'financee.dart';
import 'theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Financee(),
    ),
  );
}
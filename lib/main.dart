import 'package:flutter/material.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(const YuraaApp());
}

class YuraaApp extends StatelessWidget {
  const YuraaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'يوراء - Yuraa Super App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
        fontFamily: 'Tahoma',
      ),
      home: const HomeShell(),
    );
  }
}

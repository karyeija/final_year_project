import 'package:flutter/material.dart';

// import 'package:test/home.dart';
import 'package:test/test_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resection App',
      // theme: ThemeData(
      // primarySwatch: Colors.white,
      // ),
      home: Home(),
    );
  }
}

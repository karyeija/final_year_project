import 'package:flutter/material.dart';
import 'package:gnsspro/screens/welcome.dart'; // Import welcome screen

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GNSS pro',
      theme: ThemeData.light(),
      home: WelcomeScreen(), // Start with WelcomeScreen
    );
  }
}

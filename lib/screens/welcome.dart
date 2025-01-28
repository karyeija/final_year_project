import 'package:flutter/material.dart';
import 'package:gnsspro/home.dart';

class WelcomeScreen extends StatefulWidget {
  final int delayInSeconds;

  const WelcomeScreen({super.key, this.delayInSeconds = 1});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String displayText = 'Assess your survey points\' geometry with ease.';
  String welcomingText = "Welcome to Static Survey!";
  final Key welcomingTextKey = const Key('welcomingText');

  @override
  void initState() {
    super.initState();

    // Update the text after the initial delay
    Future.delayed(Duration(seconds: widget.delayInSeconds + 2), () {
      setState(() {
        displayText = 'Enjoy the field!!';
        welcomingText = '';
      });

      // Navigate to the Home screen after another short delay
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => Home(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    welcomingText,
                    key: welcomingTextKey, // Assign the key here
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                displayText, // Dynamically updated text
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

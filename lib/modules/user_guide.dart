// user_guide.dart
import 'package:flutter/material.dart';

void showUserGuide(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("User Guide"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              const Text(
                '1. Launch the App:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                  'Since you\'re here, it means you\'ve already launched the app😁😁😁.\n'),
              const Text(
                '2. Home Screen:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                  'The home screen has \n(a) Icons that you can click to go to other pages.'),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.table_chart, size: 18),
                    ),
                    const TextSpan(
                        text:
                            ' takes you to the table screen where you can search and select any coordinate.'),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.add_location, size: 18),
                    ),
                    const TextSpan(
                        text:
                            ' takes you to the location screen. Here you are prompted to enable location services to work with GPS. You can  copy or clear your current location data.'),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.preview, size: 18),
                    ),
                    const TextSpan(
                        text:
                            ' takes you to the preview screen where you can view the geometry results. The geometry results are distances, angles and bearings.'),
                  ],
                ),
              ),
              const Text(
                '(b) A section of Control Stations:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    const TextSpan(
                      text:
                          'Type in the coordinates (Easting and Northing) of the control stations in the designated "Controls Section." You can also copy station coordinates from the table by clicking the ',
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.table_chart, size: 18),
                    ),
                    const TextSpan(text: ' icon in the home screen.'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '(c) User Location:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    const TextSpan(
                      text:
                          'If you don\'t have the user\'s location data, click on the ',
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(Icons.add_location, size: 18),
                    ),
                    const TextSpan(
                      text:
                          ' icon to pick a location. Copy and paste it into the "User Location" section.\n',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '(d) Buttons:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                  'Reset: To reset the app and clear all input fields, click the "Refresh" button.\n'
                  'View Report: To see a brief report of the calculations, click the "Print" button.\n'
                  'Submit: To initiate the calculations and display the results, click the "Submit" button.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

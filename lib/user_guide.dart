import 'package:flutter/material.dart';
import 'package:gnsspro/modules/widgetbuilders.dart';

void showUserGuide(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("User Guide"),
        content: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              buildSectionTitle('1. Launch the App:'),
              const Text(
                  'Since you\'re here, it means you\'ve already launched the app😁😁😁.\n'),
              const Divider(),
              buildSectionTitle('2. Home Screen:'),
              buildSectionTitle('(a) Icons'),
              buildRichTextWithIcon(
                children: [
                  TextSpan(text: 'Click the '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.table_chart, size: 18),
                  ),
                  TextSpan(
                    text:
                        ' icon to go to the table screen where you can search and select any coordinate.',
                  ),
                ],
              ),
              buildRichTextWithIcon(
                children: [
                  TextSpan(text: 'Click the '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.add_location, size: 18),
                  ),
                  TextSpan(
                    text:
                        ' icon to navigate to the location screen. You will be prompted to enable location services for GPS functionality. You can copy or clear your current location data.',
                  ),
                ],
              ),
              buildRichTextWithIcon(
                children: [
                  TextSpan(text: 'Click the '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.preview, size: 18),
                  ),
                  TextSpan(
                    text:
                        ' icon to view the preview screen where you can see the geometry results, such as distances (baseline) and angles.',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              buildSectionTitle('(b) Base Stations:'),
              buildRichTextWithIcon(
                children: [
                  TextSpan(
                      text:
                          'Type in the coordinates (Easting and Northing) of the Base stations in the "Base stations Section." Alternatively, you can copy station coordinates from the table by clicking the '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.table_chart, size: 18),
                  ),
                  TextSpan(text: ' icon.'),
                ],
              ),
              const SizedBox(height: 10),
              buildSectionTitle('(c) User Location:'),
              buildRichTextWithIcon(
                children: [
                  TextSpan(
                      text:
                          'If you don\'t have the user\'s location data, click on the '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(Icons.add_location, size: 18),
                  ),
                  TextSpan(
                      text:
                          ' icon to pick a location and then copy and paste it into the "User Location" section.'),
                ],
              ),
              const SizedBox(height: 10),
              buildSectionTitle('(d) Buttons:'),
              const Text(
                  'Reset: To reset the app and clear all input fields, click the "Refresh" button.\n'
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

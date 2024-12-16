// import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:test/WebViewPage.dart';
import 'package:test/chart.dart';
import 'package:test/geolocation.dart';
import 'package:test/geometry.dart';
import 'package:test/share_test.dart';
import 'package:test/table.dart';

// import 'package:plot/webview_page.dart';
// import 'package:flutter_apk/geometry.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  // Default and current points
  final List<List<double>> defaultPoints = [
    [100, 85],
    [328, 897],
    [1000, 1220],
    [1267, 200]
  ];
  // final List<List<double>> defaultPoints = [
  //   [1267, 200],
  //   [1000, 1220],
  //   [328, 897],
  //   [100, 85],
  // ];
  late List<List<double>> pts;
  // Dividers for spacing
  final SizedBox vDivider = const SizedBox(width: 2);
  final SizedBox hDivider = const SizedBox(height: 1);
  final SizedBox legDivider = const SizedBox(height: 20);

  // TextEditingControllers for input fields
  final TextEditingController x1Control = TextEditingController();
  final TextEditingController y1Control = TextEditingController();
  final TextEditingController x2Control = TextEditingController();
  final TextEditingController y2Control = TextEditingController();
  final TextEditingController x3Control = TextEditingController();
  final TextEditingController y3Control = TextEditingController();
  final TextEditingController x4Control = TextEditingController();
  final TextEditingController y4Control = TextEditingController();

  late List<TextEditingController> textfields;

  /// The above Dart code is defining a getter method called `distAB` that returns `null`.
  // get distAB => null;

  get bearingAB => dms(forwardBearing(pts[0], pts[1])); //view
  get bearingAB1 => (forwardBearing(pts[0], pts[1])); //calc
  get bearingBA => (forwardBearing(pts[1], pts[0]));
  get bearingBC => dms(forwardBearing(pts[1], pts[2]));
  get bearingBC1 => (forwardBearing(pts[1], pts[2]));
  get bearingCB1 => (forwardBearing(pts[2], pts[1]));
  get bearingAC => dms(forwardBearing(pts[0], pts[2]));
  get bearingPB => (forwardBearing(pts[3], pts[1]));
  get bearingBP => (forwardBearing(pts[1], pts[3]));
  get bearingPC => (forwardBearing(pts[3], pts[2]));
  get bearingCP => (forwardBearing(pts[2], pts[3]));
  get bearingPA => (forwardBearing(pts[3], pts[0]));
  get bearingAP => (forwardBearing(pts[0], pts[3]));
  get backBearingAB => dms(backBearing(pts[0], pts[1]));
  get backBearingBC => dms(backBearing(pts[1], pts[2]));
  get backBearingAC => dms(backBearing(pts[0], pts[2]));
  // angle ABC
  get angleABC => dms(interiorAngle(pts[0], pts[1], pts[2]));
  get angleAlpha1 => bearingBA - bearingBP;
  get angleTheta1 => bearingAP - bearingAB1;
  get angleAlpha => 180.0 - (angleAlpha1 + angleTheta1);
  get angleAlpha2 => bearingBP - bearingBC1;
  get angleTheta2 => bearingCB1 - bearingCP;
  get angleBeta => 180.0 - (angleAlpha2 + angleTheta2);

  // angle PAB
  get anglePAB => dms(interiorAngle(pts[3], pts[0], pts[1]));

  String get angleAPB {
    return dms(angleAlpha);
  }

  String get angleBPC {
    return dms(angleBeta);
  }

  get distAB => calcDistance(pts[0], pts[1]).toStringAsFixed(2);
  get distBC => calcDistance(pts[1], pts[2]).toStringAsFixed(2);
  get distAC => calcDistance(pts[0], pts[2]).toStringAsFixed(2);
  get distBP => calcDistance(pts[1], pts[3]).toStringAsFixed(2);

  @override
  void initState() {
    super.initState();
    // Initialize the points list
    pts = List.from(defaultPoints);

    // Initialize the list of text controllers
    textfields = [
      x1Control,
      y1Control,
      x2Control,
      y2Control,
      x3Control,
      y3Control,
      x4Control,
      y4Control,
    ];

    // Add listeners to handle pasting
    x1Control.addListener(() {
      if (x1Control.text.isNotEmpty) {
        handlePaste(x1Control, y1Control);
      }
    });
    x2Control.addListener(() {
      if (x2Control.text.isNotEmpty) {
        handlePaste(x2Control, y2Control);
      }
    });
    x3Control.addListener(() {
      if (x3Control.text.isNotEmpty) {
        handlePaste(x3Control, y3Control);
      }
    });
    x4Control.addListener(() {
      if (x4Control.text.isNotEmpty) {
        handlePaste(x4Control, y4Control);
      }
    });
  }

  //function to check if any two rows are similar in a 2d list
  bool duplicateRows(List<List<double>> theList) {
    for (int i = 0; i < theList.length; i++) {
      for (int j = i + 1; j < theList.length; j++) {
        if (theList[i].toString() == theList[j].toString()) {
          return true;
        }
      }
    }
    return false;
  }

  //function to check if any two rows are similar in a 2d list
  bool threeIdenticalRows(List<List<double>> theList) {
    for (int i = 0; i < theList.length; i++) {
      for (int j = i + 1; j < theList.length; j++) {
        for (int k = j + 1; k < theList.length; k++) {
          if (theList[i].toString() == theList[j].toString()) {
            return true;
          }
        }
      }
    }
    return false;
  }

// Handle duplicate Eastings or Ns
  bool columnDuplicates(
      List<List<double>> values, int columnIndex, int targetRepetitions) {
    Map<double, int> countMap = {};

    // Count occurrences of each value in the specified column
    for (List<double> row in values) {
      if (columnIndex < row.length) {
        double columnValue = row[columnIndex];
        countMap[columnValue] =
            (countMap[columnValue] ?? 0) + 1; // Increment count
      }
    }
    // Check if any value has the exact number of repetitions
    for (int count in countMap.values) {
      if (count == targetRepetitions) {
        return true; // Found a value with the exact number of repetitions
      }
    }

    return false; // No value appears exactly targetRepetitions times
  }

// Function to check if any x = y in any rows in a 2D list
  bool isXequaltoY(List<List<double>> theList) {
    // Loop through each row in the 2D list
    for (int i = 0; i < theList.length; i++) {
      // Check if the row has at least two elements to compare
      if (theList[i].length > 1) {
        // Compare the first element (x) to the second element (y)
        if (theList[i][0] == theList[i][1]) {
          // print('Found x = y in row ${i + 1}: x = y = ${theList[i][0]}');
          return true;
          // break;
          // return true; // Return true if a match is found
        }
      }
    }
    return false; // Return false if no matches are found
  }

// Function to check if a specified column is either in increasing or decreasing order
  bool isColumnOrdered(List<List<double>> theList, int columnIndex) {
    // Check if the columnIndex is valid
    if (theList.isEmpty ||
        columnIndex < 0 ||
        columnIndex >= theList[0].length) {
      // print('Invalid column index');
      return false; // Return false for invalid input
    }

    bool isIncreasing = true; // Assume it is increasing until proven otherwise
    bool isDecreasing = true; // Assume it is decreasing until proven otherwise

    // Loop through the rows and compare values in the specified column
    for (int i = 1; i < theList.length - 1; i++) {
      if (theList[i][columnIndex] < theList[i - 1][columnIndex]) {
        isIncreasing = false; // Found a decrease, so not increasing
      } else if (theList[i][columnIndex] > theList[i - 1][columnIndex]) {
        isDecreasing = false; // Found an increase, so not decreasing
      }
    }

    // Return true if either condition is met
    return isIncreasing || isDecreasing;
  }

  // Method to handle pasting data
  void handlePaste(
      TextEditingController xControl, TextEditingController yControl) {
    String text = xControl.text; // Get the text from the X controller

    // Split the text by comma
    List<String> values = text.split(',');

    // Check if we have at least two values
    if (values.length >= 2) {
      // Set the x value from the first part
      xControl.text = values[0].trim(); // Assign trimmed value to xControl
      // Set the y value from the second part
      yControl.text = values[1].trim(); // Assign trimmed value to yControl
    }

    // Clear the original text input after handling paste
    // xControl.clear(); // Clear the original pasted value
  }

  @override
  void dispose() {
    // Dispose of the controllers to free up resources
    for (var controller in textfields) {
      controller.dispose();
    }
    super.dispose();
  }

  // Handle the submit button click
  void submitButtonClicked() {
    setState(() {
      bool allValid = true;
      List<List<double>> tempPoints = [];

      // Validate each pair of x and y inputs
      for (int i = 0; i < textfields.length; i += 2) {
        String xValue = textfields[i].text;
        String yValue = textfields[i + 1].text;

        // Check if inputs are valid numbers
        if (xValue.isEmpty ||
            yValue.isEmpty ||
            double.tryParse(xValue) == null ||
            double.tryParse(yValue) == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('All fields must be filled with valid numbers'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ));
          allValid = false;
          break; // Exit the loop if validation fails
        } else {
          tempPoints.add([double.parse(xValue), double.parse(yValue)]);
        }
      }

      // Proceed only if all inputs are valid
      if (allValid) {
        // Check for repeated values and collinearity
        bool threeRepeatedEasting =
            columnDuplicates(tempPoints, 0, 3); // any three repeated eastings
        bool threeRepeatedNorthing =
            columnDuplicates(tempPoints, 1, 3); // any three repeated northings
        bool duplicatedRows = duplicateRows(tempPoints); // repeated points
        bool xEqualstoY = isXequaltoY(
            tempPoints); // curb for x=y as this may lead to infinity
        bool orderlyEasting = isColumnOrdered(
            tempPoints, 0); //check if points are entered in an orderly manner

        if (threeRepeatedEasting || threeRepeatedNorthing) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Collinear'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ));
        } else if (duplicatedRows) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Repeated points'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ));
        } else if (xEqualstoY) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: RichText(
                text: const TextSpan(children: [
              TextSpan(text: 'Check where x=y ', style: TextStyle(fontSize: 20))
            ])),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ));
        } else if (!orderlyEasting) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: RichText(
                text: const TextSpan(children: [
              TextSpan(
                  text: 'jumbled stations ', style: TextStyle(fontSize: 20))
            ])),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ));
        } else {
          pts.clear();
          pts = tempPoints; // Assign the validated points
        }
      }
    });
  }

  // Handle the refresh button click
  void refreshButtonClicked() {
    setState(() {
      // Reset points to default
      pts.clear();
      pts.addAll(defaultPoints);

      // Clear all text fields
      for (var textfield in textfields) {
        textfield.clear();
      }
    });
  }

  // Build method with improved structure
  @override
  Widget build(BuildContext context) {
    double pageWidth = MediaQuery.of(context).size.width;
    double pageHeight = MediaQuery.of(context).size.height;
    double controlsHeight = pageHeight * 0.2;
    double chartHeight = pageWidth * 0.9;
    double chartWidth = chartHeight;

    // Build the main UI components
    Widget plot = Row(
      children: [
        buildChartContainer(chartWidth, chartHeight),
        // buildLegendContainer(chartHeight),
      ],
    );

    Widget controlStationsHeading = const FittedBox(
      fit: BoxFit.fill,
      child: SizedBox(
        height: 30,
        child: Text(
          'Control Stations',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );

    Widget controlStations = buildControlStations(controlsHeight, pageWidth);

    Widget userLocationHeading = SizedBox(
      height: pageHeight * 0.02,
      child: const FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          'User Location',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );

    Widget userLocationEntry =
        buildUserLocationEntry(controlsHeight, pageWidth);

    Widget userButtons = buildUserButtons(pageWidth);

    return Scaffold(
      backgroundColor: Colors.white70,
      persistentFooterButtons: [userButtons],
      appBar: AppBar(
        // leading: IconButton(
        // color: Colors.white,
        // icon: Icon(Icons.cloud), // Icon for the filterable table
        // onPressed: () {
        // Navigate to the table screen when the icon is clicked
        // Navigator.push(context,
        // MaterialPageRoute(builder: (context) => WebViewPage()));
        // },
        // ),
        toolbarHeight: pageHeight * 0.05,
        title: const Text('Resection App'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        // double pageHeight = MediaQuery.of(context).size.height;

        actions: [
          IconButton(
            color: Colors.white,
            icon:
                const Icon(Icons.table_chart), // Icon for the filterable table
            onPressed: () {
              // Navigate to the table screen when the icon is clicked
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TableScreen()),
              );
            },
          ),
          IconButton(
              icon: const Icon(
                  color: Colors.amber,
                  Icons.add_location_rounded), // Icon for the filterable table
              onPressed: () {
                // Navigate to the table screen when the icon is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GeoLocation()),
                );
              }),
          IconButton(
            icon: const Icon(
                Icons.book_outlined), // Icon for the filterable table
            onPressed: () {
              // Navigate to the table screen when the icon is clicked
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReportPage(
                          angleABC: '$angleABC',
                          anglePAB: '$anglePAB',
                          angleAPB: angleAPB,
                          bearingAB: '$bearingAB',
                          angleBPC: angleBPC,
                          bearingBC: '$bearingBC',
                          bearingAC: '$bearingAC',
                          backBearingAB: '$backBearingAB',
                          backBearingBC: '$backBearingBC',
                          backBearingAC: '$backBearingAC',
                          distAB: '$distAB',
                          distBC: '$distBC',
                          distAC: '$distAC',
                        )),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // To avoid overflow on small screens
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  plot,
                  controlStationsHeading,
                  hDivider,
                  controlStations,
                  userLocationHeading,
                  hDivider,
                  userLocationEntry,
                  hDivider,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to build the chart container
  Widget buildChartContainer(double chartWidth, double chartHeight) {
    return Center(
        child: Container(
      decoration:
          BoxDecoration(border: Border.all(width: 2), color: Colors.black54),
      width: chartWidth * 1.05,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      // color: Colors.black,
      child: SizedBox(
          width: chartWidth,
          height: chartHeight,
          child: SyncfusionLineChart(pts)),
    ));
  }

  // Helper method to build legend items
  Widget buildLegendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 8,
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Method to build control stations input
  Widget buildControlStations(double controlsHeight, double pageWidth) {
    return SizedBox(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('STN1'),
              SizedBox(
                width: pageWidth * 0.01,
              ),
              buildCoordinateRow(
                x1Control,
                y1Control,
                controlsHeight,
                pageWidth,
                'E₁',
                'N₁',
              ),
              SizedBox(
                width: pageWidth * 0.01,
              ),
              buildLegendItem(Colors.red, ""),
            ],
          ),
          Row(
            children: [
              const Text('STN2'),
              SizedBox(
                width: pageWidth * 0.01,
              ),
              buildCoordinateRow(
                x2Control,
                y2Control,
                controlsHeight,
                pageWidth,
                'E₂',
                'N₂',
              ),
              SizedBox(
                width: pageWidth * 0.01,
              ),
              buildLegendItem(Colors.green, ""),
            ],
          ),
          Row(
            children: [
              const Text('STN3'),
              SizedBox(
                width: pageWidth * 0.01,
              ),
              buildCoordinateRow(
                x3Control,
                y3Control,
                controlsHeight,
                pageWidth,
                'E₃',
                'N₃',
              ),
              SizedBox(
                width: pageWidth * 0.01,
              ),
              buildLegendItem(Colors.blue, ""),
            ],
          ),
        ],
      ),
    );
  }

  // Method to build coordinate input rows
  Widget buildCoordinateRow(
      TextEditingController xControl,
      TextEditingController yControl,
      double controlsHeight,
      double pageWidth,
      String xLabel,
      String yLabel) {
    // a row of textFields
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: pageWidth * 0.38,
          height: controlsHeight * 0.4,
          child: TextField(
            controller: xControl,
            keyboardType: const TextInputType.numberWithOptions(),
            decoration: InputDecoration(
              labelText: xLabel,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        vDivider,
        SizedBox(
          width: pageWidth * 0.38,
          height: controlsHeight * 0.4,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(),
            controller: yControl,
            decoration: InputDecoration(
              labelText: yLabel,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  // Method to build user location input
  Widget buildUserLocationEntry(double controlsHeight, double pageWidth) {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: pageWidth * 0.08,
          ),
          buildCoordinateRow(
            x4Control,
            y4Control,
            // TextEditingController(),
            controlsHeight,
            pageWidth,
            'User E',
            'User N',
          ),
          SizedBox(
            width: pageWidth * 0.01,
          ),
          buildLegendItem(Colors.yellow, ""),
        ],
      ),
    );
  }

  // Method to build user buttons
  Widget buildUserButtons(double pageWidth) {
    return SizedBox(
      width: pageWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            style: const ButtonStyle(),
            onPressed: submitButtonClicked,
            child: const Text('Submit'),
          ),
          TextButton(
            onPressed: refreshButtonClicked,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

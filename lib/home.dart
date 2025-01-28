import 'package:flutter/material.dart';

import 'package:gnsspro/geolocation.dart';
import 'package:gnsspro/modules/widgetbuilders.dart';
import 'package:gnsspro/modules/custom_drawer.dart';
import 'package:gnsspro/modules/errorhandling.dart';
import 'package:gnsspro/screens/preview_page.dart';
import 'package:gnsspro/table.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final List<List<double>> defaultPoints = [
    [454619.842, 37212.601], //KOLOLO
    [454126.524, 40575.622], //BAHAI
    [458755.8278, 39498.8048],
    [458517.19, 39025.89] //SLIS3
    // [458525.204, 39019.595] //SLIS3 picked
  ];
  late List<List<double>> pts;
  final textfields = List.generate(8, (_) => TextEditingController());

  final vDivider = const SizedBox(width: 2);
  final hDivider = const SizedBox(height: 1);

  @override
  void initState() {
    super.initState();
    pts = List.from(defaultPoints);
    _addPasteListeners();
  }

  void _addPasteListeners() {
    for (int i = 0; i < textfields.length; i += 2) {
      textfields[i].addListener(() {
        if (textfields[i].text.isNotEmpty) {
          handlePaste(textfields[i], textfields[i + 1]);
        }
      });
    }
  }

  void handlePaste(
      TextEditingController xControl, TextEditingController yControl) {
    final values = xControl.text.split(',').map((e) => e.trim()).toList();
    if (values.length >= 2) {
      xControl.text = values[0];
      yControl.text = values[1];
    }
  }

  void submitButtonClicked() {
    setState(() {
      bool allValid = true;
      List<List<double>> tempPoints = [];

      for (int i = 0; i < textfields.length; i += 2) {
        double? x = double.tryParse(textfields[i].text);
        double? y = double.tryParse(textfields[i + 1].text);
        if (x == null || y == null) {
          showErrorSnackBar('All fields must be filled with valid numbers');
          allValid = false;
          break;
        } else {
          tempPoints.add([x, y]);
        }
      }

      if (allValid && validateInputs(tempPoints)) {
        pts = tempPoints;
      }
    });
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontSize: 18)),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    ));
  }

  bool validateInputs(List<List<double>> points) {
    if (columnDuplicates(points, 0, 3) || columnDuplicates(points, 1, 3)) {
      showErrorSnackBar('some points are on a straight line');
      return false;
    }
    if (duplicateRows(points)) {
      showErrorSnackBar('You\'ve repeated some points');
      return false;
    }
    if (isXequaltoY(points)) {
      showErrorSnackBar('some Easting values are equal to Northing values');
      return false;
    }

    return true;
  }

  void refreshButtonClicked() {
    setState(() {
      pts = List.from(defaultPoints);
      for (var controller in textfields) {
        controller.clear();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in textfields) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double pageWidth = MediaQuery.of(context).size.width;
    double pageHeight = MediaQuery.of(context).size.height;
    double controlsHeight = pageHeight * 0.22;
    double chartHeight = pageWidth * 0.9;
    double chartWidth = chartHeight;

    return SizedBox(
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: buildUserButtons(
              pageWidth, submitButtonClicked, refreshButtonClicked),
        ),
        drawer: Drawer(
          semanticLabel: 'Options',
          child: CustomDrawer(),
        ),
        appBar: AppBar(
          // toolbarHeight: pageHeight * 0.05,
          title: const Text('GNSS pro'),
          centerTitle: true,
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
                icon: const Icon(Icons.table_chart),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TableScreen()))),
            IconButton(
                icon: const Icon(Icons.add_location_rounded),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => GeoLocation()))),
            IconButton(
                icon: const Icon(Icons.preview_rounded),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PreviewPage(
                              pts: pts,
                            )))),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    buildChartContainer(chartWidth, chartHeight, pts),
                    buildSectionHeading('Base Stations'),
                    buildControlStations(controlsHeight, pageWidth, textfields),
                    buildSectionHeading('current receiver Location'),
                    buildUserLocationEntry(
                        controlsHeight, pageWidth, textfields),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

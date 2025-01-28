import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, rootBundle;
import 'package:csv/csv.dart';
import 'dart:async';

// Class to load CSV data from assets
class CsvDataLoader {
  // Function to load CSV file and return List<Map<String, dynamic>>
  Future<List<Map<String, dynamic>>> loadCsvData(String path) async {
    final csvString = await rootBundle.loadString(path);
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(csvString);

    List<String> headers = List<String>.from(rowsAsListOfValues.first);
    return rowsAsListOfValues.skip(1).map((row) {
      return Map<String, dynamic>.fromIterables(headers, row);
    }).toList();
  }
}

// Main app widget
class TableScreen extends StatelessWidget {
  const TableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CSV Data page',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CsvTableScreen(),
    );
  }
}

// CSV Table Screen to display data
class CsvTableScreen extends StatefulWidget {
  const CsvTableScreen({super.key});

  @override
  _CsvTableScreenState createState() => _CsvTableScreenState();
}

class _CsvTableScreenState extends State<CsvTableScreen> {
  List<Map<String, dynamic>> csvData = [];
  List<Map<String, dynamic>> filteredData = [];
  String filterText = '';
  // double? inputElevation;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCsv();
  }

  Future<void> _loadCsv() async {
    CsvDataLoader loader = CsvDataLoader();
    List<Map<String, dynamic>> data =
        await loader.loadCsvData('assets/data.csv');

    setState(() {
      csvData = data;
      filteredData = data;
    });
  }

  void _filterData(String filter) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filterText = filter;
        filteredData = csvData.where((row) {
          return row['NAME']
              .toString()
              .toLowerCase()
              .contains(filter.toLowerCase());
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Control Stations Table',
            style: TextStyle(color: Colors.green),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Increase the height and wrap TextFields in Expanded
              Padding(
                padding: const EdgeInsets.all(
                    8.0), // Add padding around the input fields
                child: Row(
                  children: [
                    // Filter by Name TextField
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          // prefix: Icon(Icons.search),
                          suffixIcon: Icon(Icons.search),
                          // icon: Icon(Icons.search),
                          labelText: 'Filter by Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged:
                            _filterData, // Call the filter function on input change
                      ),
                    ),
                    const SizedBox(
                        width: 8), // Add spacing between the two fields
                  ],
                ),
              ),
              // List of filtered data
              SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.6, // Adjust height as needed
                  child: filteredData.isEmpty
                      ? const Center(
                          child:
                              CircularProgressIndicator()) // Show loading spinner
                      : ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> row = filteredData[index];

                            // Replace ListTile with the Container-based layout
                            return Container(
                              margin: const EdgeInsets.all(
                                  2.0), // Add some spacing around each row
                              padding: const EdgeInsets.all(
                                  5.0), // Padding inside each row
                              // decoration: BoxDecoration(
                              //   color: _getElevationColor(row[
                              //       'ELEVATION']), // Set background color based on elevation
                              //   borderRadius: BorderRadius.circular(8.0),
                              // ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // The text information on the left
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Name: ${row['NAME']}'),
                                        Text(
                                            'N: ${row['N']}, E: ${row['E']}, Elevation: ${row['ELEVATION']}'),
                                      ],
                                    ),
                                  ),
                                  // The copy icon on the right
                                  IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      // Copy E and N in reverse order
                                      final reversedValues =
                                          '${row['E']}, ${row['N']}';
                                      Clipboard.setData(
                                          ClipboardData(text: reversedValues));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Copied: $reversedValues')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

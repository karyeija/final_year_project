// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:test/geometry.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoLocation and UTM Conversion ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GeoLocation(),
    );
  }
}

class GeoLocation extends StatefulWidget {
  const GeoLocation({super.key});

  @override
  State<GeoLocation> createState() => _GeoLocationState();
}

class _GeoLocationState extends State<GeoLocation> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _utmNorthingController = TextEditingController();
  final TextEditingController _utmEastingController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _altitudeController = TextEditingController();
  Map<String, dynamic>? utmResult;
  bool isLoading = false;

  Future<void> convertToUtm() async {
    double? latitude = double.tryParse(_latController.text);
    double? longitude = double.tryParse(_longController.text);
    // double? altitude = double.tryParse(_altitudeController.text);

    // _altitudeController.text = getElevation() as String;
    // _altitudeController.text = (await getElevation())?.toString() ?? '0.0';

    if (latitude != null && longitude != null) {
      utmResult = convertLatLngToUtm(latitude, longitude, 3);
// 7.92069999999876
//  160.070500000007
      _utmNorthingController.text = (utmResult!['northing']).toString();

      _utmEastingController.text = (utmResult!['easting']).toString();
      _zoneController.text = utmResult!['zone'].toString();

      setState(() {});
    } else {
      utmResult = null;
      _showSnackBar('Invalid latitude or longitude values.', Colors.red);
    }
  }

  _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  _getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled.', Colors.red);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied', Colors.red);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(
            'Location permissions are permanently denied, we cannot request permissions.',
            Colors.red);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.best));

      _latController.text = '${position.latitude}';
      _longController.text = '${position.longitude}';
      _altitudeController.text =
          (position.altitude + 12.6400000000001).toStringAsFixed(0);

      convertToUtm();

      _showSnackBar(
          'Coordinates updated: ${position.latitude}, ${position.longitude}',
          Colors.green);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _getLastLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Location services are disabled.', Colors.red);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permissions are denied', Colors.red);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar(
            'Location permissions are permanently denied, we cannot request permissions.',
            Colors.red);
        return;
      }

      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        _showSnackBar('No location data available.', Colors.red);
        return;
      }

      _latController.text = '${position.latitude}';
      _longController.text = '${position.longitude}';
      _altitudeController.text = '${position.altitude}';
      convertToUtm();

      _showSnackBar(
          'Last known coordinates: ${position.latitude}, ${position.longitude}',
          Colors.green);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _clearAll() async {
    _utmEastingController.text = '';
    _utmNorthingController.text = '';
    _latController.text = '';
    _longController.text = '';
    _zoneController.text = '';
    _altitudeController.text = '';
  }

  _copyUTM() async {
    if (_utmEastingController.text.isEmpty ||
        _utmNorthingController.text.isEmpty) {
      _showSnackBar('Coordinates are empty, cannot copy.', Colors.red);
      return;
    }

    Clipboard.setData(ClipboardData(
        text: '${_utmEastingController.text}, ${_utmNorthingController.text}'));

    _showSnackBar('UTM coordinates copied to clipboard.', Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    double pageWidth = MediaQuery.sizeOf(context).width;
    double txtFieldHeight = pageWidth * 0.2;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.sizeOf(context).height * 0.2,
        title: const Text(
          'User location ',
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      bottomSheet: const Text('By Karyeija Felex'),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              if (isLoading)
                const LinearProgressIndicator(), // Show progress bar if loading
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Latitude and Longitude Input Fields
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width / 2.5,
                                  // width: txtFieldWidth,
                                  height: txtFieldHeight,
                                  child: TextField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                    controller: _latController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Latitude',
                                    ),
                                  ),
                                ),
                                SizedBox(width: pageWidth * 0.05),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width / 2.5,
                                  height: txtFieldHeight,
                                  child: TextField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(),
                                    controller: _longController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Longitude',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // UTM Output Fields
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                // width: txtFieldWidth,
                                height: txtFieldHeight * 0.9,
                                width: pageWidth / 2.5,
                                child: TextField(
                                  textAlignVertical:
                                      const TextAlignVertical(y: 0),
                                  textAlign: TextAlign.center,
                                  readOnly: true,
                                  controller: _zoneController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    prefixText: 'zone:',
                                    hintText: 'zone:',
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    // width:
                                    width: pageWidth / 2.5,
                                    height: txtFieldHeight,
                                    child: TextField(
                                      readOnly: true,
                                      controller: _utmEastingController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'UTM Easting',
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: pageWidth * 0.03),
                                  SizedBox(
                                    width: pageWidth / 2.5,
                                    height: txtFieldHeight,
                                    child: TextField(
                                      readOnly: true,
                                      controller: _utmNorthingController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'UTM Northing',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _copyUTM,
                                    icon: const Icon(Icons.copy),
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                              height: MediaQuery.sizeOf(context).height * 0.1),
                          SizedBox(width: pageWidth * 0.03),
                          SizedBox(
                            width: pageWidth / 2.5,
                            height: txtFieldHeight,
                            child: TextField(
                              readOnly: true,
                              controller: _altitudeController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Elevation',
                              ),
                            ),
                          ),
                          // Location Buttons
                          ElevatedButton(
                            onPressed: _getCurrentLocation,
                            child: const Text(
                              'Get Current Location',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _getLastLocation,
                            child: const Text(
                              'Get Last Location',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _clearAll,
                            child: const Text(
                              'Clear All',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
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

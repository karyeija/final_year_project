import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gnsspro/geometry.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoLocation and UTM Conversion',
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
  final TextEditingController _accuracyController = TextEditingController();

  Map<String, dynamic>? utmResult;
  bool isLoading = false;
  bool _hasGpsFix = false;
  String _gpsStatus = 'Waiting for GPS fix...';

  get horizontalLine =>
      SizedBox(height: MediaQuery.of(context).size.width * 0.01);
  get verticalLine =>
      SizedBox(height: MediaQuery.of(context).size.height * 0.01);

  Future<void> convertToUtm() async {
    double? latitude = double.tryParse(_latController.text);
    double? longitude = double.tryParse(_longController.text);

    if (latitude != null && longitude != null) {
      utmResult = convertLatLngToUtm(latitude, longitude, 3);
      _utmNorthingController.text = (utmResult!['northing']).toString();
      _utmEastingController.text = (utmResult!['easting']).toString();
      _zoneController.text = utmResult!['zone'].toString();
      setState(() {});
    } else {
      utmResult = null;
      _showSnackBar('Invalid latitude or longitude values.', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            verticalLine,
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
      _gpsStatus = 'Waiting for GPS fix...';
      _hasGpsFix = false;
    });
    void showLocationSettingsDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text('Please enable location services to proceed.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Geolocator.openLocationSettings(); // Open location settings.
                },
                child: const Text('Open Settings'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _gpsStatus = 'Location services are disabled.';
        _showSnackBar(_gpsStatus, Colors.red);

        // Prompt user to enable location services
        showLocationSettingsDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _gpsStatus = 'Location permissions are denied.';
          _showSnackBar(_gpsStatus, Colors.red);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _gpsStatus =
            'Location permissions are permanently denied. Unable to proceed.';
        _showSnackBar(_gpsStatus, Colors.red);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              timeLimit: Duration(seconds: 10)));

      _latController.text = '${position.latitude}';
      _longController.text = '${position.longitude}';
      _altitudeController.text =
          (position.altitude + 12.6400000000001).toStringAsFixed(0);
      _accuracyController.text = '${position.accuracy.toStringAsFixed(2)} m';

      // Classify the GPS fix based on accuracy
      final accuracy = position.accuracy;

      setState(() {
        // if (accuracy < 1) {
        _gpsStatus = 'RTK Fixed, error= ${accuracy.toStringAsFixed(2)} m';
        _hasGpsFix = true;
      });

      convertToUtm();
      _showSnackBar(
          'Coordinates updated: ${position.latitude}, ${position.longitude}',
          Colors.green);
    } catch (e) {
      _gpsStatus = 'Error: Unable to get GPS fix.';
      _showSnackBar(_gpsStatus, Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _clearAll() {
    _utmEastingController.clear();
    _utmNorthingController.clear();
    _latController.clear();
    _longController.clear();
    _zoneController.clear();
    _altitudeController.clear();
    _showSnackBar('Successfully cleared', Colors.green);
  }

  void _copyUTM() {
    if (_utmEastingController.text.isEmpty ||
        _utmNorthingController.text.isEmpty) {
      _showSnackBar('Coordinates are empty, cannot copy.', Colors.red);
      return;
    }

    Clipboard.setData(ClipboardData(
        text: '${_utmEastingController.text}, ${_utmNorthingController.text}'));

    _showSnackBar('UTM coordinates copied to clipboard.', Colors.green);
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      // color: Color.fromARGB(12, 24, 65, 76),
      margin: const EdgeInsets.all(16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            horizontalLine,
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool readOnly = true,
    bool showCursor = false,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      enabled: showCursor,
      showCursor: showCursor,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }

  Widget _buildGpsStatusIndicator() {
    final accuracy = double.tryParse(_accuracyController.text.split(' ')[0]);

    // Set color based on accuracy
    Color statusColor =
        _hasGpsFix && (accuracy != null) ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            _hasGpsFix ? Icons.gps_fixed : Icons.gps_not_fixed,
            color: statusColor,
          ),
          verticalLine,
          Expanded(
            child: Text(
              _gpsStatus,
              style: TextStyle(
                fontSize: 16,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Location'),
        centerTitle: true,
      ),
      bottomSheet: const Text('By Karyeija Felex'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              if (isLoading) const Center(child: CircularProgressIndicator()),
              _buildGpsStatusIndicator(),
              horizontalLine,
              _buildSection(
                title: 'Geographic coordinates',
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'Latitude',
                        controller: _latController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInputField(
                        label: 'Longitude',
                        controller: _longController,
                      ),
                    ),
                  ],
                ),
              ),
              horizontalLine,
              _buildSection(
                title: 'UTM coordinates',
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        label: 'UTM Easting',
                        controller: _utmEastingController,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInputField(
                        label: 'UTM Northing',
                        controller: _utmNorthingController,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              ),
              horizontalLine,
              _buildInputField(
                label: 'Zone',
                controller: _zoneController,
                readOnly: true,
                icon: Icons.map,
              ),
              horizontalLine,
              FittedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: const Text('Get Current Location'),
                      ),
                    ],
                  ),
                ),
              ),
              horizontalLine,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: _clearAll,
                    child: const Text('Clear'),
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: _copyUTM,
                    child: const Text('Copy UTM'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

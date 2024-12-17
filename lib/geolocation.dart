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
      title: 'GeoLocation and UTM Conversion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GeoLocation(),
    );
  }

  static of(BuildContext context) {}
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
            const SizedBox(width: 8),
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

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _gpsStatus = 'Location services are disabled.';
        _showSnackBar(_gpsStatus, Colors.red);
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

      convertToUtm();
      setState(() {
        // Update the accuracy controller with the new position accuracy
        _accuracyController.text = '${position.accuracy.toStringAsFixed(2)} m';

        // Parse the updated accuracy for further processing
        final accuracy = double.tryParse(position.accuracy.toStringAsFixed(2));

        if (accuracy != null) {
          if (accuracy < 5) {
            _gpsStatus =
                'GPS Fix acquired! at ${_accuracyController.text} good';
          } else {
            _gpsStatus =
                'GPS Fix acquired! at ${_accuracyController.text}, poor';
          }
          _hasGpsFix = true;
        } else {
          _gpsStatus = 'Invalid GPS accuracy value';
          _hasGpsFix = false;
        }
      });

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

  Future<void> _getLastLocation() async {
    setState(() {
      isLoading = true;
      _gpsStatus = 'Fetching last known location...';
    });

    try {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        _gpsStatus = 'No last known location available.';
        _showSnackBar(_gpsStatus, Colors.red);
        return;
      }

      _latController.text = '${position.latitude}';
      _longController.text = '${position.longitude}';
      _altitudeController.text = '${position.altitude}';
      convertToUtm();

      setState(() {
        _gpsStatus = 'Last known location retrieved.';
        _hasGpsFix = true;
      });

      _showSnackBar(
          'Last known coordinates: ${position.latitude}, ${position.longitude}',
          Colors.green);
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
      margin: const EdgeInsets.only(bottom: 16),
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
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: icon != null ? Icon(icon) : null,
      ),
    );
  }

  Widget _buildGpsStatusIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            _hasGpsFix ? Icons.gps_fixed : Icons.gps_not_fixed,
            color: _hasGpsFix ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _gpsStatus,
              style: TextStyle(
                fontSize: 16,
                color: _hasGpsFix ? Colors.green : Colors.red,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isLoading) const Center(child: CircularProgressIndicator()),
            _buildGpsStatusIndicator(),
            const Divider(height: 30),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: 'Longitude',
                        controller: _longController,
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 20),
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInputField(
                        label: 'UTM Northing',
                        controller: _utmNorthingController,
                        readOnly: true,
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            _buildInputField(
              label: 'Zone',
              controller: _zoneController,
              readOnly: true,
              icon: Icons.map,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              label: 'Elevation',
              controller: _altitudeController,
              readOnly: true,
              icon: Icons.terrain,
            ),
            const SizedBox(height: 20),
            _buildSection(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _getCurrentLocation,
                    child: const Text('Get Current Location'),
                  ),
                  ElevatedButton(
                    onPressed: _getLastLocation,
                    child: const Text('Get Last Location'),
                  ),
                ],
              ),
              title: 'Action',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _clearAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Clear All'),
                ),
                ElevatedButton(
                  onPressed: _copyUTM,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Copy UTM'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

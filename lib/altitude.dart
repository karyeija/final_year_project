import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationService {
  final Location location = Location();

  Future<LocationData?> getLocationData() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location services are enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Return null if the user did not enable the service
        return null;
      }
    }

    // Check if the app has permission to access location
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        // Return null if the user did not grant permission
        return null;
      }
    }

    // Get and return the location data
    try {
      LocationData locationData = await location.getLocation();
      return locationData;
    } catch (e) {
      // Handle any errors when trying to get location
      // print("Error retrieving location data: $e");
      return null;
    }
  }
}

class LocationWidget extends StatefulWidget {
  const LocationWidget({super.key});

  @override
  _LocationWidgetState createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  LocationService locationService = LocationService();
  LocationData? _locationData;
  bool _loading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    // Get the location data
    LocationData? locationData = await locationService.getLocationData();

    setState(() {
      if (locationData != null) {
        _locationData = locationData;
        _loading = false;
      } else {
        _errorMessage = 'Failed to retrieve location data';
        _loading = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Service')),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : _locationData != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Latitude: ${_locationData?.latitude ?? 'N/A'}'),
                      Text('Longitude: ${_locationData?.longitude ?? 'N/A'}'),
                    ],
                  )
                : Text(_errorMessage, style: TextStyle(color: Colors.red)),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: LocationWidget()));
}

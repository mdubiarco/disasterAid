import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String location = 'Loading location...';
  String cityAndState = ''; // Stores city and state info

  @override
  void initState() {
    super.initState();
    _requestPermissions(); // Request permissions on startup
  }

  // Function to request location permissions and fetch the location
  Future<void> _requestPermissions() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      setState(() {
        location = 'Location permissions denied';
      });
    } else {
      _getLocation(); // Fetch the location if permission is granted
    }
  }

  // Function to determine the user's current location
  Future<void> _getLocation() async {
    try {
      // Slight delay to prevent blocking the UI thread
      await Future.delayed(Duration(milliseconds: 50));

      Position position = await _determinePosition();
      // Now use reverse geocoding to get the city and state
      _getCityAndState(position.latitude, position.longitude);

    } catch (e) {
      setState(() {
        location = 'Failed to get location: $e';
      });
    }
  }

  // Determine the current position of the device
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // Permissions are granted, and we can proceed to get the current position
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // Function to get city and state from coordinates
  Future<void> _getCityAndState(double latitude, double longitude) async {
    try {
      // Using geocoding package to get a list of placemarks
      List<Placemark> placemarks = await GeocodingPlatform.instance?.placemarkFromCoordinates(latitude, longitude) ?? [];

      if (placemarks.isNotEmpty) {
        // Get the city and state from the first placemark
        Placemark place = placemarks.first;
        setState(() {
          cityAndState = '${place.locality}, ${place.administrativeArea}';
          location = 'Location: $cityAndState';
        });
      }
    } catch (e) {
      setState(() {
        location = 'Failed to get city and state: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Survival Guide Page')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location displayed at the top of the screen
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display "Location:" in bold 
                Text(
                  'Location:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                // Display the city and state 
                Text(
                  cityAndState.isEmpty ? 'Loading location...' : cityAndState,
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Center(
              child: location == 'Loading location...'
                  ? CircularProgressIndicator() // Show loading spinner
                  : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

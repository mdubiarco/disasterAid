import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'WebViewPage.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String location = 'Loading location...';
  String cityAndState = ''; // Stores city and state info
  String incidentTypes = ''; // Stores incident types 
  String errorMessage = ''; // Stores error message
  List<String> currentIncidentTypes = []; // List of current incident types for the state

  // Full map of states and their incident types
  final Map<String, List<String>> stateToIncidentTypes = {
    'Alabama': ['Flood', 'Tornado', 'Hurricane'],
    'Alaska': ['Earthquake', 'Flood', 'Fire'],
    'Arizona': ['Flood', 'Fire', 'Tornado'],
    'Arkansas': ['Flood', 'Tornado', 'Hurricane'],
    'California': ['Flood', 'Wildfire', 'Earthquake'],
    'Colorado': ['Flood', 'Fire', 'Earthquake'],
    'Connecticut': ['Flood', 'Hurricane'],
    'Delaware': ['Flood', 'Hurricane'],
    'Florida': ['Flood', 'Hurricane', 'Fire'],
    'Georgia': ['Flood', 'Tornado', 'Hurricane'],
    'Hawaii': ['Earthquake', 'Flood', 'Tsunami'],
    'Idaho': ['Flood', 'Fire', 'Earthquake'],
    'Illinois': ['Flood', 'Tornado', 'Hurricane'],
    'Indiana': ['Flood', 'Tornado', 'Fire'],
    'Iowa': ['Flood', 'Tornado', 'Fire'],
    'Kansas': ['Flood', 'Tornado', 'Fire'],
    'Kentucky': ['Flood', 'Tornado', 'Hurricane'],
    'Louisiana': ['Flood', 'Hurricane', 'Tornado'],
    'Maine': ['Flood', 'Hurricane', 'Fire'],
    'Maryland': ['Flood', 'Hurricane', 'Tornado'],
    'Massachusetts': ['Flood', 'Hurricane', 'Fire'],
    'Michigan': ['Flood', 'Fire', 'Tornado'],
    'Minnesota': ['Flood', 'Tornado', 'Fire'],
    'Mississippi': ['Flood', 'Tornado', 'Hurricane'],
    'Missouri': ['Flood', 'Tornado', 'Fire'],
    'Montana': ['Flood', 'Fire', 'Earthquake'],
    'Nebraska': ['Flood', 'Tornado', 'Fire'],
    'Nevada': ['Flood', 'Fire', 'Earthquake'],
    'New Hampshire': ['Flood', 'Fire', 'Tornado'],
    'New Jersey': ['Flood', 'Hurricane', 'Fire'],
    'New Mexico': ['Flood', 'Fire', 'Earthquake'],
    'New York': ['Flood', 'Hurricane', 'Fire'],
    'North Carolina': ['Flood', 'Hurricane', 'Tornado'],
    'North Dakota': ['Flood', 'Tornado', 'Fire'],
    'Ohio': ['Flood', 'Tornado', 'Fire'],
    'Oklahoma': ['Flood', 'Tornado', 'Fire'],
    'Oregon': ['Flood', 'Fire', 'Earthquake'],
    'Pennsylvania': ['Flood', 'Fire', 'Tornado'],
    'Rhode Island': ['Flood', 'Hurricane', 'Fire'],
    'South Carolina': ['Flood', 'Hurricane', 'Tornado'],
    'South Dakota': ['Flood', 'Tornado', 'Fire'],
    'Tennessee': ['Flood', 'Tornado', 'Hurricane'],
    'Texas': ['Flood', 'Fire', 'Tornado'],
    'Utah': ['Flood', 'Fire', 'Earthquake'],
    'Vermont': ['Flood', 'Fire', 'Tornado'],
    'Virginia': ['Flood', 'Hurricane', 'Tornado'],
    'Washington': ['Flood', 'Fire', 'Earthquake'],
    'West Virginia': ['Flood', 'Tornado', 'Fire'],
    'Wisconsin': ['Flood', 'Tornado', 'Fire'],
    'Wyoming': ['Flood', 'Fire', 'Earthquake'],
    'District of Columbia': ['Flood', 'Fire', 'Tornado'],
    'Puerto Rico': ['Flood', 'Hurricane', 'Earthquake'],
    'Guam': ['Earthquake', 'Tsunami'],
    'Northern Mariana Islands': ['Typhoon', 'Flood', 'Earthquake'],
    'U.S. Virgin Islands': ['Flood', 'Hurricane'],
  };

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
      Position position = await _determinePosition();
      // Geocoding to get the city and state
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

        if (place.administrativeArea != null) {
          String stateName = place.administrativeArea!;
          _fetchIncidentTypes(stateName); 
        } else {
          setState(() {
            errorMessage = 'State information is unavailable.'; 
            incidentTypes = ''; 
          });
        }
      }
    } catch (e) {
      setState(() {
        location = 'Failed to get city and state: $e';
      });
    }
  }

  // Function to fetch incident types for a given state 
  void _fetchIncidentTypes(String stateName) {
    String formattedStateName = stateName.trim().toLowerCase().split(" ").map((word) => word[0].toUpperCase() + word.substring(1)).join(" ");

    // Check if the state name exists in our map
    if (stateToIncidentTypes.containsKey(formattedStateName)) {
      setState(() {
        currentIncidentTypes = stateToIncidentTypes[formattedStateName]!; // Set the incident types for the state
        errorMessage = ''; 
      });
    } else {
      setState(() {
        currentIncidentTypes = [];
        errorMessage = 'No incident information found for $formattedStateName';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disaster Information')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                Text(
                  cityAndState.isEmpty ? 'Loading location...' : cityAndState,
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              currentIncidentTypes.isEmpty ? 'Fetching incident types in your area...' : 'Incident Types:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: currentIncidentTypes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          currentIncidentTypes[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        if (currentIncidentTypes[index] == 'Flood') 
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the WebView for Flood
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebViewPage(
                                    url: 'https://www.ready.gov/floods',
                                  ),
                                ),
                              );
                            },
                            child: Text('Learn More'),
                          ),
                        if (currentIncidentTypes[index] == 'Earthquake') 
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the WebView for Earthquake
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebViewPage(
                                    url: 'https://www.ready.gov/earthquakes',
                                  ),
                                ),
                              );
                            },
                            child: Text('Learn More'),
                          ),
                        if (currentIncidentTypes[index] == 'Wildfire') 
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the WebView for Wildfires
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebViewPage(
                                    url: 'https://www.ready.gov/wildfires',
                                  ),
                                ),
                              );
                            },
                            child: Text('Learn More'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              errorMessage.isEmpty ? '' : errorMessage,
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

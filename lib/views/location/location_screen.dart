import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;

class LocationScreen extends StatefulWidget {
  LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController mapController;
  late LatLng _currentLocation;
  String _currentLocationName = '';
  List<geo.Location> _searchResults = [];
  LatLng? _selectedLocation;
  Set<Polyline> _polylines = {};
  TextEditingController _searchController = TextEditingController();
  String _distance = '12km';
  String _duration = '30 Mint';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    loc.LocationData locationData = await loc.Location().getLocation();
    setState(() {
      _currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
      _getAddressFromCoordinates();
    });
  }

  Future<void> _getAddressFromCoordinates() async {
    List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        _currentLocation.latitude, _currentLocation.longitude);
    if (placemarks.isNotEmpty) {
      geo.Placemark placemark = placemarks[0];
      setState(() {
        _currentLocationName = placemark.name ?? '';
      });
    }
  }

  Future<List<geo.Location>> _searchLocation(String query) async {
    return await geo.locationFromAddress(query);
  }

  void _createRoute() async {
    _polylines.add(Polyline(
      polylineId: PolylineId('route'),
      visible: true,
      points: [
        _currentLocation, // Starting point
        _selectedLocation!, // Destination point
      ],
      color: Colors.blue,
      width: 4,
    ));

    await _fetchDirections();
  }

  Future<void> _fetchDirections() async {
    if (_currentLocation != null && _selectedLocation != null) {
      final String apiKey = 'YOUR_API_KEY_HERE'; // Replace with your API key
      final String origin =
          '${_currentLocation.latitude},${_currentLocation.longitude}';
      final String destination =
          '${_selectedLocation!.latitude},${_selectedLocation!.longitude}';
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$apiKey';

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final routes = data['routes'];
        final distance = routes[0]['legs'][0]['distance']['text'];
        final duration = routes[0]['legs'][0]['duration']['text'];
        setState(() {
          _distance = distance;
          _duration = duration;
          print(duration);
          print(distance);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search for a location',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    String query = _searchController.text;
                    if (query.isNotEmpty) {
                      List<geo.Location> results = await _searchLocation(query);
                      setState(() {
                        _searchResults = results;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? LatLng(0, 0),
                zoom: 15.0,
              ),
              markers: {
                if (_currentLocation != null)
                  Marker(
                    markerId: MarkerId('currentLocation'),
                    position: _currentLocation,
                    icon: BitmapDescriptor.defaultMarker,
                    infoWindow: InfoWindow(
                      title: _currentLocationName.isEmpty
                          ? 'Current Location'
                          : _currentLocationName,
                      snippet:
                          'Latitude: ${_currentLocation.latitude}, Longitude: ${_currentLocation.longitude}',
                    ),
                  ),
                if (_selectedLocation != null)
                  Marker(
                    markerId: MarkerId('selectedLocation'),
                    position: _selectedLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                    infoWindow: InfoWindow(
                      title: 'Destination',
                      snippet: 'Distance: $_distance, Duration: $_duration',
                    ),
                  ),
              },
              polylines: _polylines,
              onTap: (LatLng position) {
                setState(() {
                  _selectedLocation = position;
                  _createRoute(); // Call the function to create route
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

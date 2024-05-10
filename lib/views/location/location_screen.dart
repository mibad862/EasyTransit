import 'package:demo_project1/views/location/provider/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController mapController;
  late LatLng _currentLocation;
  String _currentLocationName = '';
  Marker? _startMarker;
  Marker? _endMarker;
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
    });
  }

  Future<String> _getAddressFromCoordinates(LatLng coordinates) async {
    List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        coordinates.latitude, coordinates.longitude);
    if (placemarks.isNotEmpty) {
      final geo.Placemark placemark = placemarks.first;
      return '${placemark.street ?? ''}, ${placemark.locality ?? ''}, ${placemark.postalCode ?? ''},${placemark.subAdministrativeArea ?? ''},${placemark.country ?? ''}';
    } else {
      return 'Unknown address';
    }
  }

  Future<List<geo.Location>> _searchLocation(String query) async {
    return await geo.locationFromAddress(query);
  }

  void _createRoute() async {
    _polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      visible: true,
      points: [
        _currentLocation, // Starting point
        _selectedLocation!, // Destination point
      ],
      color: Colors.blue,
      width: 4,
    ));
  }

  void _saveLocations(BuildContext context) async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    // Ensure that both start and end markers are set
    if (_startMarker != null && _endMarker != null) {
      // Get the addresses for start and end markers
      String startAddress =
          await _getAddressFromCoordinates(_startMarker!.position);
      String endAddress =
          await _getAddressFromCoordinates(_endMarker!.position);

      // Set the addresses in the location provider
      locationProvider.setStartAddress(startAddress);
      locationProvider.setEndAddress(endAddress);

      // Print the stored addresses for verification
      print(locationProvider.getStartAddress);
      print(locationProvider.getEndAddress);

      // Close the screen after saving
      Navigator.pop(context);
    } else {
      // Show a message if both start and end points are not set
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set both start and end points.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            onTap: (LatLng tappedPoint) {
              setState(() {
                // Set the tapped point as the end route
                _endMarker = Marker(
                  markerId: const MarkerId('endPoint'),
                  position: tappedPoint,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                  infoWindow: InfoWindow(
                    title: 'End Point',
                  ),
                );

                // Update the selected location
                _selectedLocation = tappedPoint;
              });
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? const LatLng(0, 0),
              zoom: 15.0,
            ),
            markers: {
              if (_startMarker != null) _startMarker!,
              if (_endMarker != null) _endMarker!,
              Marker(
                markerId: const MarkerId('currentLocation'),
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
            },
          ),
          SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: const OutlineInputBorder(),
                  hintText: 'Search for a location',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () async {
                      String query = _searchController.text;
                      if (query.isNotEmpty) {
                        List<geo.Location> results =
                            await _searchLocation(query);
                        setState(() {
                          _searchResults = results;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 80,
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.green)),
                    onPressed: () {
                      _saveLocations(context);
                    },
                    child: const Text(
                      "Done",
                      style: TextStyle(color: Colors.white),
                    )),
              )),
          Positioned(
            bottom: 60,
            left: 23,
            child: Container(
              width: 300,
              height: 180,
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const SizedBox(
                      height: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.green,
                      ),
                    ),
                    title: const Text(
                      "ROUTE START POINT",
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    subtitle: FutureBuilder<String>(
                      future: _getAddressFromCoordinates(_currentLocation),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          );
                        } else {
                          return Text(
                            snapshot.data ?? 'Tap to set start point',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: snapshot.data != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          );
                        }
                      },
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          _startMarker = Marker(
                            markerId: const MarkerId('startPoint'),
                            position:
                                _currentLocation, // Set the current location as start point
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueGreen),
                            infoWindow: InfoWindow(
                              title: 'Start Point',
                            ),
                          );
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const SizedBox(
                      height: 20,
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                      ),
                    ),
                    title: const Text(
                      "ROUTE END POINT",
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    subtitle: FutureBuilder<String>(
                      future: _getAddressFromCoordinates(
                          _selectedLocation ?? _currentLocation),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          );
                        } else {
                          return Text(
                            snapshot.data ?? 'Tap to set end point',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: snapshot.data != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          );
                        }
                      },
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          _endMarker = Marker(
                            markerId: const MarkerId('endPoint'),
                            position:
                                _currentLocation, // Set the current location as end point
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed),
                            infoWindow: InfoWindow(
                              title: 'End Point',
                            ),
                          );
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

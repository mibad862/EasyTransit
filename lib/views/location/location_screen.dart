import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';

import 'provider/location_provider.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController mapController;
  late LatLng _currentLocation;
  Marker? _pickupMarker;
  Marker? _dropoffMarker;
  Set<Polyline> _polylines = {};
  late BitmapDescriptor _pickupIcon;
  late BitmapDescriptor _dropoffIcon;

  TextEditingController _searchController = TextEditingController();
  List<PlacePrediction> _placePredictions = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    loadCustomIcons();
  }

  Future<void> loadCustomIcons() async {
    final BitmapDescriptor pickupIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/pin.png',
    );

    final BitmapDescriptor dropoffIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/pin_dropoff.png',
    );

    // Once the icons are loaded, assign them to the respective variables
    setState(() {
      _pickupIcon = pickupIcon;
      _dropoffIcon = dropoffIcon;
    });
  }

  Future<void> _getCurrentLocation() async {
    loc.LocationData locationData = await loc.Location().getLocation();
    setState(() {
      _currentLocation =
          LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  void _selectPickupLocation(LatLng location) {
    setState(() {
      _pickupMarker = Marker(
        markerId: const MarkerId('pickup'),
        position: location,
        icon: _pickupIcon,
        infoWindow: const InfoWindow(
          title: 'Pickup Location',
        ),
      );
      _updatePath();
    });
  }

  void _selectDropoffLocation(LatLng location) {
    setState(() {
      _dropoffMarker = Marker(
        markerId: const MarkerId('dropoff'),
        position: location,
        icon: _dropoffIcon,
        infoWindow: const InfoWindow(
          title: 'Drop-off Location',
        ),
      );
      _updatePath();
    });
  }

  Future<void> _updatePath() async {
    if (_pickupMarker != null && _dropoffMarker != null) {
      String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${_pickupMarker!.position.latitude},${_pickupMarker!.position.longitude}&destination=${_dropoffMarker!.position.latitude},${_dropoffMarker!.position.longitude}&key=YOUR_API_KEY";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<LatLng> routeCoords = [];
        List<dynamic> steps = decoded["routes"][0]["legs"][0]["steps"];
        steps.forEach((step) {
          String polyline = step["polyline"]["points"];
          List<LatLng> decodedPolyline = _decodePoly(polyline);
          routeCoords.addAll(decodedPolyline);
        });

        setState(() {
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            visible: true,
            points: routeCoords,
            color: Colors.blue,
            width: 4,
          ));
        });
      } else {
        throw Exception('Failed to load directions');
      }
    }
  }

  List<LatLng> _decodePoly(String poly) {
    var list = poly.codeUnits;
    List<int> lList = [];

    int index = 0;
    do {
      var shift = 0;
      int result = 0;
      do {
        int b = list[index] - 63;
        result |= (b & 0x1F) << (shift * 5);
        shift++;
        index++;
      } while (list[index] >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var dlat = ((result >> 1) / 100000.0);
      lList.add(dlat.toInt());
    } while (index < list.length - 1);
    List<LatLng> polylineCoords = [];
    for (var i = 0; i < lList.length; i += 2) {
      var lat = lList[i];
      var lng = lList[i + 1];
      polylineCoords.add(LatLng(lat.toDouble(), lng.toDouble()));
    }
    return polylineCoords;
  }

  Future<String> _getAddressFromCoordinates(LatLng coordinates) async {
    List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        coordinates.latitude, coordinates.longitude);
    if (placemarks.isNotEmpty) {
      final geo.Placemark placemark = placemarks.first;
      return '${placemark.street ?? ''}, ${placemark.locality ?? ''},${placemark.subAdministrativeArea ?? ''},${placemark.country ?? ''}';
    } else {
      return 'Unknown address';
    }
  }

  Future<void> _searchPlaces(String input) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=geocode&key=AIzaSyC1f6cHoNQCGkerIJ7vzCLZgV9QE1Zr6Xg";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      setState(() {
        _placePredictions = (decoded['predictions'] as List)
            .map((prediction) => PlacePrediction.fromJson(prediction))
            .toList();
      });
    }
  }

  void _selectSearchedPlace(String placeId) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,geometry&key=AIzaSyC1f6cHoNQCGkerIJ7vzCLZgV9QE1Zr6Xg";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      double lat = decoded['result']['geometry']['location']['lat'];
      double lng = decoded['result']['geometry']['location']['lng'];
      LatLng selectedLocation = LatLng(lat, lng);

      // Determine whether to select as pickup or dropoff based on which marker is currently being set
      if (_pickupMarker == null) {
        _selectPickupLocation(selectedLocation);
      } else if (_dropoffMarker == null) {
        _selectDropoffLocation(selectedLocation);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Screen'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              onTap: (LatLng tappedPoint) {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 150.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _selectPickupLocation(tappedPoint);
                              Navigator.pop(context);
                            },
                            child: const Text('Pickup Location'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _selectDropoffLocation(tappedPoint);
                              Navigator.pop(context);
                            },
                            child: const Text('Drop-off Location'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? const LatLng(0, 0),
                zoom: 15.0,
              ),
              markers: {
                if (_pickupMarker != null) _pickupMarker!,
                if (_dropoffMarker != null) _dropoffMarker!,
              },
              polylines: _polylines,
            ),
            Positioned(
              top: 10.0,
              left: 10.0,
              right: 10.0,
              child: Container(
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search places...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onSubmitted: (value) {
                    _searchPlaces(value);
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 10.0,
              left: 10.0,
              right: 10.0,
              child: ElevatedButton(
                onPressed: () async {
                  // Access the LocationProvider and set start and end addresses
                  final locationProvider =
                      Provider.of<LocationProvider>(context, listen: false);
                  if (_pickupMarker != null && _dropoffMarker != null) {
                    final pickupAddress = await _getAddressFromCoordinates(
                        _pickupMarker!.position);
                    final dropoffAddress = await _getAddressFromCoordinates(
                        _dropoffMarker!.position);
                    locationProvider.setStartAddress(pickupAddress);
                    locationProvider.setEndAddress(dropoffAddress);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Locations saved successfully!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Please select both pickup and drop-off locations.'),
                      ),
                    );
                  }
                },
                child: const Text('Save Location'),
              ),
            ),
            if (_placePredictions.isNotEmpty)
              Positioned(
                top: 60.0,
                left: 10.0,
                right: 10.0,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _placePredictions
                        .map(
                          (prediction) => ListTile(
                            title: Text(prediction.description),
                            onTap: () {
                              _selectSearchedPlace(prediction.placeId);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PlacePrediction {
  final String description;
  final String placeId;

  PlacePrediction({
    required this.description,
    required this.placeId,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      description: json['description'],
      placeId: json['place_id'],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// // import 'package:flutter_mapbox_gl/flutter_mapbox_gl.dart';
// class MapBoxIntegration extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('MapBox Integration'),
//       ),
//       body: FlutterMap(
//         options: MapOptions(
//           center: LatLng(37.7749, -122.4194), // Replace with your desired initial map center coordinates
//           zoom: 13.0, // Adjust the initial zoom level as needed
//         ),
//         layers: [
//           TileLayerOptions(
//             urlTemplate:
//             'https://api.mapbox.com/styles/v1/sherryblueberry/clrcbsn8a009w01qvgvk0at0l/wmts?access_token=pk.eyJ1Ijoic2hlcnJ5Ymx1ZWJlcnJ5IiwiYSI6ImNscWwxeWJkNDJoOTMybW1rbDhud3NjcTkifQ.Kfc8aDB72s2xDTF1R3Oy7w', // Replace YOUR_ACCESS_TOKEN with your MapBox access token
//             subdomains: ['a', 'b', 'c'],
//             tileProvider: NonCachingNetworkTileProvider(),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? _controller;

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    print("MapScreen: Map created");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteRelay Map'),
      ),
      body: MapLibreMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 2.0,
        ),
        styleString: "https://demotiles.maplibre.org/style.json",
      ),
    );
  }
}

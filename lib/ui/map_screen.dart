import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../models/telemetry_state.dart';
import 'widgets/convoy_sidebar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? _controller;
  List<TelemetryState> _members = [];
  double _leadVelocity = 0.0;

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    _updateMarkers(); // Initial marker update
  }

  void _updateMarkers() {
    if (_controller == null) return;
    // In a real app, this would use _controller!.addSymbol
    // to place avatars and ghosts on the map.
    for (var member in _members) {
      // ignore: unused_local_variable
      final pos = member.getProjectedPosition();
      // Add symbol to map at pos
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteRelay Map'),
      ),
      body: Stack(
        children: [
          MapLibreMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 2.0,
            ),
            styleString: "https://demotiles.maplibre.org/style.json",
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: ConvoySidebar(
              members: _members,
              leadVelocity: _leadVelocity,
            ),
          ),
        ],
      ),
    );
  }
}

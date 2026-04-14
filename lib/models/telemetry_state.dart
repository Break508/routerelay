import 'dart:math' as math;
import 'package:maplibre_gl/maplibre_gl.dart';

class TelemetryState {
  final String userId;
  final LatLng lastKnownPosition;
  final double velocity; // in m/s
  final double heading; // in degrees
  final DateTime timestamp;

  TelemetryState({
    required this.userId,
    required this.lastKnownPosition,
    required this.velocity,
    required this.heading,
    required this.timestamp,
  });

  /// Calculates the projected position based on dead reckoning.
  LatLng getProjectedPosition() {
    final double secondsElapsed = DateTime.now().difference(timestamp).inMilliseconds / 1000.0;
    if (secondsElapsed <= 0 || velocity <= 0) return lastKnownPosition;

    // Radius of the Earth in meters
    const double r = 6371000;

    // Convert heading to radians
    final double brng = heading * math.pi / 180.0;
    final double dist = velocity * secondsElapsed;

    final double lat1 = lastKnownPosition.latitude * math.pi / 180.0;
    final double lon1 = lastKnownPosition.longitude * math.pi / 180.0;

    final double lat2 = math.asin(math.sin(lat1) * math.cos(dist / r) +
        math.cos(lat1) * math.sin(dist / r) * math.cos(brng));
    final double lon2 = lon1 + math.atan2(math.sin(brng) * math.sin(dist / r) * math.cos(lat1),
        math.cos(dist / r) - math.sin(lat1) * math.sin(lat2));

    return LatLng(lat2 * 180.0 / math.pi, lon2 * 180.0 / math.pi);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mesh_service.dart';
import '../services/ble_service.dart';

/// Provider for BLE Service
final bleServiceProvider = Provider<BleService>((ref) {
  return BleService();
});

/// Provider for Mesh Service
final meshServiceProvider = Provider<MeshService>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return MeshService(bleService);
});

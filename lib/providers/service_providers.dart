import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mesh_service.dart';
import '../services/ble_service.dart';
import '../services/audio_service.dart';
import '../services/crypto_service.dart';
import '../services/map_service.dart';
import '../repositories/convoy_repository.dart';

/// Provider for BLE Service
final bleServiceProvider = Provider<BleService>((ref) {
  final service = BleService();
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for Mesh Service
final meshServiceProvider = Provider<MeshService>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  final service = MeshService(bleService);
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for Audio Service
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

/// Provider for Crypto Service
final cryptoServiceProvider = Provider<CryptoService>((ref) {
  return CryptoService();
});

/// Provider for Map Service
final mapServiceProvider = Provider<MapService>((ref) {
  return MapService();
});

/// Provider for Convoy Repository
final convoyRepositoryProvider = Provider<ConvoyRepository>((ref) {
  final meshService = ref.watch(meshServiceProvider);
  final cryptoService = ref.watch(cryptoServiceProvider);
  final bleService = ref.watch(bleServiceProvider);

  final repository = ConvoyRepository(
    meshService: meshService,
    cryptoService: cryptoService,
    bleService: bleService,
  );
  ref.onDispose(repository.dispose);
  return repository;
});

import 'package:get_it/get_it.dart';
import '../services/ble_service.dart';
import '../services/mesh_service.dart';
import '../services/audio_service.dart';
import '../services/crypto_service.dart';
import '../services/map_service.dart';
import '../repositories/convoy_repository.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies for the application
void setupDependencies() {
  // Services (LazySingleton - created on first use)
  getIt.registerLazySingleton<BleService>(() => BleService());
  getIt.registerLazySingleton<MeshService>(() => MeshService(getIt<BleService>()));
  getIt.registerLazySingleton<AudioService>(() => AudioService());
  getIt.registerLazySingleton<CryptoService>(() => CryptoService());
  getIt.registerLazySingleton<MapService>(() => MapService());
  
  // Repositories
  getIt.registerLazySingleton<ConvoyRepository>(
    () => ConvoyRepository(
      meshService: getIt<MeshService>(),
      cryptoService: getIt<CryptoService>(),
      bleService: getIt<BleService>(),
    ),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
  setupDependencies();
}

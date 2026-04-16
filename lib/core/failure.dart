/// Base class for all failures in the application
abstract class Failure {
  final String message;
  final Exception? exception;

  const Failure({required this.message, this.exception});

  @override
  String toString() => 'Failure(message: $message, exception: $exception)';
}

/// BLE connection related failures
class BleConnectionFailure extends Failure {
  const BleConnectionFailure({super.message = 'Failed to connect via BLE', super.exception});
}

class BleScanFailure extends Failure {
  const BleScanFailure({super.message = 'Failed to scan for devices', super.exception});
}

class BleAdvertisementFailure extends Failure {
  const BleAdvertisementFailure({super.message = 'Failed to start advertising', super.exception});
}

/// Mesh network related failures
class MeshMessageFailure extends Failure {
  const MeshMessageFailure({super.message = 'Failed to send mesh message', super.exception});
}

class MeshDecodingFailure extends Failure {
  const MeshDecodingFailure({super.message = 'Failed to decode mesh message', super.exception});
}

/// Audio related failures
class AudioRecordingFailure extends Failure {
  const AudioRecordingFailure({super.message = 'Failed to record audio', super.exception});
}

class AudioPlaybackFailure extends Failure {
  const AudioPlaybackFailure({super.message = 'Failed to play audio', super.exception});
}

class AudioEncodingFailure extends Failure {
  const AudioEncodingFailure({super.message = 'Failed to encode audio', super.exception});
}

/// Location related failures
class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure({super.message = 'Location permission denied', super.exception});
}

class LocationUpdateFailure extends Failure {
  const LocationUpdateFailure({super.message = 'Failed to get location update', super.exception});
}

/// Crypto related failures
class CryptoKeyGenerationFailure extends Failure {
  const CryptoKeyGenerationFailure({super.message = 'Failed to generate crypto key', super.exception});
}

class CryptoEncryptionFailure extends Failure {
  const CryptoEncryptionFailure({super.message = 'Failed to encrypt data', super.exception});
}

class CryptoDecryptionFailure extends Failure {
  const CryptoDecryptionFailure({super.message = 'Failed to decrypt data', super.exception});
}

/// Convoy related failures
class ConvoyJoinFailure extends Failure {
  const ConvoyJoinFailure({super.message = 'Failed to join convoy', super.exception});
}

class ConvoyLeaveFailure extends Failure {
  const ConvoyLeaveFailure({super.message = 'Failed to leave convoy', super.exception});
}

/// Generic unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unknown error occurred', super.exception});
}

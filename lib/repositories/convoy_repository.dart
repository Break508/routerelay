import 'package:dartz/dartz.dart';
import '../core/failure.dart';
import '../models/telemetry_state.dart';
import '../services/mesh_service.dart';
import '../services/crypto_service.dart';
import '../services/ble_service.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Repository pattern implementation for convoy operations
/// Separates business logic from data access
class ConvoyRepository {
  final MeshService _meshService;
  final CryptoService _cryptoService;
  final BleService _bleService;

  String? _currentConvoyId;
  String? _myUserId;
  SecretKey? _tripKey;
  bool _isLead = false;

  ConvoyRepository({
    required MeshService meshService,
    required CryptoService cryptoService,
    required BleService bleService,
  })  : _meshService = meshService,
        _cryptoService = cryptoService,
        _bleService = bleService;

  /// Get current convoy ID
  String? get currentConvoyId => _currentConvoyId;

  /// Get current user ID
  String? get myUserId => _myUserId;

  /// Check if user is the lead
  bool get isLead => _isLead;

  /// Create a new convoy as the lead
  Future<Either<Failure, void>> createConvoy() async {
    try {
      // Generate unique convoy ID and user ID
      _currentConvoyId = _generateUniqueId();
      _myUserId = 'lead_$_currentConvoyId';
      _isLead = true;

      // Generate encryption key for the convoy
      _tripKey = await _cryptoService.generateTripKey();

      // Initialize mesh service as lead
      _meshService.init(_currentConvoyId!, _myUserId!, isLead: true);

      // Start advertising
      await _bleService.startAdvertising(_currentConvoyId!);

      return const Right(null);
    } on Exception catch (e) {
      return Left(ConvoyJoinFailure(message: 'Failed to create convoy', exception: e));
    }
  }

  /// Join an existing convoy
  Future<Either<Failure, void>> joinConvoy(String convoyId, String base64Key) async {
    try {
      _currentConvoyId = convoyId;
      _myUserId = _generateUniqueId();
      _isLead = false;

      // Import the trip key
      _tripKey = _cryptoService.importKey(base64Key);

      // Initialize mesh service as follower
      _meshService.init(convoyId, _myUserId!, isLead: false);

      // Start scanning for the convoy
      await _bleService.startScanning(convoyId);

      return const Right(null);
    } on Exception catch (e) {
      return Left(ConvoyJoinFailure(message: 'Failed to join convoy', exception: e));
    }
  }

  /// Leave the current convoy
  Future<Either<Failure, void>> leaveConvoy() async {
    try {
      await _bleService.stopAdvertising();
      await _bleService.stopScanning();
      
      _currentConvoyId = null;
      _myUserId = null;
      _tripKey = null;
      _isLead = false;

      return const Right(null);
    } on Exception catch (e) {
      return Left(ConvoyLeaveFailure(message: 'Failed to leave convoy', exception: e));
    }
  }

  /// Broadcast telemetry data
  Future<Either<Failure, void>> broadcastTelemetry({
    required double latitude,
    required double longitude,
    required double velocity,
    required double heading,
  }) async {
    try {
      if (_currentConvoyId == null) {
        return const Left(ConvoyJoinFailure(message: 'Not in a convoy'));
      }

      await _meshService.broadcastTelemetry(latitude, longitude, velocity, heading);
      return const Right(null);
    } on Exception catch (e) {
      return Left(MeshMessageFailure(message: 'Failed to broadcast telemetry', exception: e));
    }
  }

  /// Broadcast voice data
  Future<Either<Failure, void>> broadcastVoice(Uint8List opusData) async {
    try {
      if (_currentConvoyId == null) {
        return const Left(ConvoyJoinFailure(message: 'Not in a convoy'));
      }

      await _meshService.broadcastVoice(opusData);
      return const Right(null);
    } on Exception catch (e) {
      return Left(MeshMessageFailure(message: 'Failed to broadcast voice', exception: e));
    }
  }

  /// Get exportable key for QR code sharing
  Future<String?> getExportableKey() async {
    if (_tripKey == null || !_isLead) return null;
    return await _cryptoService.exportKey(_tripKey!);
  }

  /// Generate a unique ID
  String _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  }

  /// Dispose resources
  void dispose() {
    _bleService.dispose();
  }
}

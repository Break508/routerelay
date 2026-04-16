import 'dart:async';
import 'dart:typed_data';
import 'package:fixnum/fixnum.dart';
import '../generated/protos/mesh.pb.dart';
import 'ble_service.dart';

class MeshService {
  final BleService _bleService;
  
  String? _currentConvoyId;
  String? _myId;
  Timer? _telemetryTimer;
  Timer? _cleanupTimer;

  final _voiceController = StreamController<Uint8List>.broadcast();
  Stream<Uint8List> get voiceStream => _voiceController.stream;
  
  // Cache for deduplication with TTL: [sender_id + timestamp] -> timestamp
  final Map<String, DateTime> _seenMessageIds = {};
  static const _messageTtl = Duration(minutes: 5);
  
  // My hop distance from the Lead (Root)
  int localHopCountToLead = 99; // Default to large value
  static const int maxHops = 10;
  
  // Current velocity for adaptive telemetry
  double _currentVelocity = 0.0;

  MeshService(this._bleService);

  void init(String convoyId, String myId, {bool isLead = false}) {
    _currentConvoyId = convoyId;
    _myId = myId;
    if (isLead) localHopCountToLead = 0;
    _startTelemetryTimer();
    _startCleanupTimer();
  }

  void _startTelemetryTimer() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(_getTelemetryInterval(), (timer) {
      // Reset timer with potentially new interval based on velocity
      _startTelemetryTimer();
      broadcastTelemetry(0.0, 0.0, _currentVelocity, 0.0); // Mock coordinates for now
    });
  }

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _cleanupOldMessages();
    });
  }

  void _cleanupOldMessages() {
    final now = DateTime.now();
    _seenMessageIds.removeWhere((_, timestamp) => 
      now.difference(timestamp) > _messageTtl);
  }

  Duration _getTelemetryInterval() {
    // Adaptive telemetry based on velocity
    if (_currentVelocity > 5) return const Duration(seconds: 5);
    if (_currentVelocity > 0) return const Duration(seconds: 15);
    return const Duration(seconds: 30);
  }

  /// Update current velocity for adaptive telemetry
  void updateVelocity(double velocity) {
    _currentVelocity = velocity;
  }

  Future<void> broadcastTelemetry(double lat, double lng, double velocity, double heading) async {
    if (_currentConvoyId == null || _myId == null) return;

    final telemetry = Telemetry()
      ..lat = lat
      ..lng = lng
      ..velocity = velocity
      ..heading = heading;

    final meshPayload = MeshPayload()
      ..convoyId = _currentConvoyId!
      ..senderId = _myId!
      ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
      ..hopCount = localHopCountToLead
      ..type = MeshPayload_Type.TELEMETRY
      ..data = telemetry.writeToBuffer();

    _relayMessage(meshPayload);
  }

  Future<void> broadcastVoice(Uint8List opusData) async {
    if (_currentConvoyId == null || _myId == null) return;

    final meshPayload = MeshPayload()
      ..convoyId = _currentConvoyId!
      ..senderId = _myId!
      ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
      ..hopCount = localHopCountToLead
      ..type = MeshPayload_Type.VOICE
      ..data = opusData;

    _relayMessage(meshPayload);
  }

  Future<void> requestTile(int z, int x, int y) async {
    if (_currentConvoyId == null || _myId == null) return;

    final request = TileRequest()
      ..z = z
      ..x = x
      ..y = y;

    final meshPayload = MeshPayload()
      ..convoyId = _currentConvoyId!
      ..senderId = _myId!
      ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
      ..hopCount = localHopCountToLead
      ..type = MeshPayload_Type.TILE_REQUEST
      ..data = request.writeToBuffer();

    _relayMessage(meshPayload);
    }

  void handleIncomingMessage(Uint8List data) {
    try {
      final payload = MeshPayload.fromBuffer(data);
      final msgId = "${payload.senderId}-${payload.timestamp}";

      // Check if message was already seen (deduplication)
      if (_seenMessageIds.containsKey(msgId)) return;
      _seenMessageIds[msgId] = DateTime.now();

      // Dispatch based on type
      switch (payload.type) {
        case MeshPayload_Type.OGM:
          _updateRoutingTable(payload);
          break;
        case MeshPayload_Type.TILE_REQUEST:
          _handleTileRequest(payload);
          break;
        case MeshPayload_Type.TILE_RESPONSE:
          _handleTileResponse(payload);
          break;
        case MeshPayload_Type.TELEMETRY:
          _handleTelemetry(payload);
          break;
        case MeshPayload_Type.VOICE:
          _handleVoice(payload);
          break;
        case MeshPayload_Type.SOS:
          _handleSOS(payload);
          break;
        case MeshPayload_Type.TEXT:
          _handleTextMessage(payload);
          break;
        default:
          break;
      }

      // Relay Logic - increment hop count and relay
      if (payload.hopCount < maxHops) {
        _relayMessage(payload);
      }
    } catch (e) {
      // Log error in production
      // ignore: avoid_print
      print('Failed to decode mesh message: $e');
    }
  }

    void _handleTileRequest(MeshPayload payload) {
    // In a real app, check local Isar cache for the tile
    }

    void _handleTileResponse(MeshPayload payload) {
    // Store in local cache and notify MapService
    }

    void _handleTelemetry(MeshPayload payload) {
    // Update local state of other cars
    }

    void _handleVoice(MeshPayload payload) {
      if (payload.senderId != _myId) {
        _voiceController.add(Uint8List.fromList(payload.data));
      }
    }

  void _handleSOS(MeshPayload payload) {
    // SOS messages should be handled with highest priority
    // In a real implementation, this would trigger alerts and notifications
    // ignore: avoid_print
    print('SOS received from ${payload.senderId} at hop ${payload.hopCount}');
  }

  void _handleTextMessage(MeshPayload payload) {
    // Decode and handle text messages
    try {
      final text = String.fromCharCodes(payload.data);
      // ignore: avoid_print
      print('Text message from ${payload.senderId}: $text');
    } catch (e) {
      // Failed to decode text
    }
  }

  void _relayMessage(MeshPayload payload) {
    // Increment hop count for the relay and relay the message
    final updated = MeshPayload()
      ..convoyId = payload.convoyId
      ..senderId = payload.senderId
      ..timestamp = payload.timestamp
      ..hopCount = payload.hopCount + 1
      ..type = payload.type
      ..data = payload.data
      ..signature = payload.signature;
    
    final buffer = updated.writeToBuffer();
    _bleService.send(buffer);
  }


  void _updateRoutingTable(MeshPayload ogm) {
    if (ogm.senderId == "lead" && ogm.hopCount < localHopCountToLead) {
      localHopCountToLead = ogm.hopCount + 1;
    }
  }
}

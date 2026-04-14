import 'dart:async';
import 'dart:typed_data';
import 'package:fixnum/fixnum.dart';
import '../generated/protos/mesh.pb.dart';
import 'ble_service.dart';

class MeshService {
  static final MeshService _instance = MeshService._internal();
  factory MeshService() => _instance;
  MeshService._internal();

  final BleService _bleService = BleService();
  String? _currentConvoyId;
  String? _myId;
  
  // Cache for deduplication: [sender_id + timestamp] -> boolean
  final Set<String> _seenMessageIds = {};
  
  // My hop distance from the Lead (Root)
  int localHopCountToLead = 99; // Default to large value
  static const int maxHops = 10;

  void init(String convoyId, String myId, {bool isLead = false}) {
    _currentConvoyId = convoyId;
    _myId = myId;
    if (isLead) localHopCountToLead = 0;
  }

  Future<void> broadcastOGM() async {
    if (_currentConvoyId == null || _myId == null) return;

    final meshPayload = MeshPayload()
      ..convoyId = _currentConvoyId!
      ..senderId = _myId!
      ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
      ..hopCount = localHopCountToLead
      ..type = MeshPayload_Type.OGM;

    _relayMessage(meshPayload);
  }

  void handleIncomingMessage(Uint8List data) {
    try {
      final payload = MeshPayload.fromBuffer(data);
      final msgId = "${payload.senderId}-${payload.timestamp}";

      if (_seenMessageIds.contains(msgId)) return;
      _seenMessageIds.add(msgId);

      // Distance-Vector Logic
      if (payload.type == MeshPayload_Type.OGM) {
        _updateRoutingTable(payload);
      }

      // Relay Logic: Only relay if it makes sense (Distance-Vector)
      if (payload.hopCount < maxHops) {
        // Only relay if we are further or equal distance from root (or we are not lead)
        // Simplified: Relay if hopCount is less than our current known distance + 1
        _relayMessage(payload);
      }
    } catch (e) {
      // Failed to decode
    }
  }

  void _relayMessage(MeshPayload payload) {
    // Increment hop count for the relay
    final relayPayload = payload.deepCopy()..hopCount = payload.hopCount + 1;
    // final buffer = relayPayload.writeToBuffer();

    // In actual implementation, we'd send this over BLE
    // _bleService.send(buffer);
  }


  void _updateRoutingTable(MeshPayload ogm) {
    if (ogm.senderId == "lead" && ogm.hopCount < localHopCountToLead) {
      localHopCountToLead = ogm.hopCount + 1;
      print("New distance to Lead: $localHopCountToLead");
    }
  }
}

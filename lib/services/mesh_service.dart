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

  void init(String convoyId, String myId) {
    _currentConvoyId = convoyId;
    _myId = myId;
  }

  /// Broadcasts an Originator Message (OGM) to declare existence in the mesh
  Future<void> broadcastOGM() async {
    if (_currentConvoyId == null || _myId == null) return;

    final meshPayload = MeshPayload()
      ..convoyId = _currentConvoyId!
      ..senderId = _myId!
      ..timestamp = Int64(DateTime.now().millisecondsSinceEpoch)
      ..hopCount = 0
      ..type = MeshPayload_Type.OGM;

    final data = meshPayload.writeToBuffer();
    // In a real implementation, we'd chunk this if it exceeds BLE MTU
    // For MVP, we assume small payloads fit in Advertisements or basic writes.
    print("Broadcasting OGM for convoy: $_currentConvoyId");
    // This would typically involve updating the advertisement data or a GATT characteristic
    await _bleService.startAdvertising(_currentConvoyId!);
  }

  void handleIncomingMessage(Uint8List data) {
    try {
      final payload = MeshPayload.fromBuffer(data);
      print("Received mesh message: ${payload.type} from ${payload.senderId}");
      
      // Process based on type (Task 4 will implement relay logic)
      if (payload.type == MeshPayload_Type.OGM) {
        _updateRoutingTable(payload);
      }
    } catch (e) {
      print("Failed to decode mesh payload: $e");
    }
  }

  void _updateRoutingTable(MeshPayload ogm) {
    // Basic OGM tracking
    print("Updating mesh routing for peer: ${ogm.senderId}");
  }
}

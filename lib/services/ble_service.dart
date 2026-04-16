import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

class BleService {
  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();
  final StreamController<ScanResult> _scanResultController = StreamController<ScanResult>.broadcast();
  Stream<ScanResult> get scanResults => _scanResultController.stream;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<dynamic>? _l2capSubscription;

  static const MethodChannel _l2capChannel = MethodChannel('io.routerelay/l2cap');
  static const EventChannel _l2capStream = EventChannel('io.routerelay/l2cap_stream');

  final StreamController<Map<String, dynamic>> _incomingDataController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get incomingData => _incomingDataController.stream;

  String? _targetConvoyId;

  BleService() {
    _l2capSubscription = _l2capStream.receiveBroadcastStream().listen((data) {
      _incomingDataController.add(Map<String, dynamic>.from(data));
    });
  }

  Future<void> openL2capChannel(String deviceId, int psm) async {
    await _l2capChannel.invokeMethod('open', {
      'deviceId': deviceId,
      'psm': psm,
    });
  }

  Future<void> send(Uint8List data, {String? deviceId}) async {
    await _l2capChannel.invokeMethod('send', {'data': data, 'deviceId': deviceId});
  }

  Future<void> startAdvertising(String convoyId) async {
    final AdvertiseData advertiseData = AdvertiseData(
      serviceUuid: 'bf277ae8-82ad-42b3-b970-bad711e122d0', // Unique for RouteRelay
      manufacturerId: 1234, // Mock ID
      manufacturerData: Uint8List.fromList(convoyId.codeUnits),
    );
    await _peripheral.start(advertiseData: advertiseData);
  }

  Future<void> stopAdvertising() async {
    await _peripheral.stop();
  }

  Future<void> startScanning(String targetConvoyId) async {
    _targetConvoyId = targetConvoyId;

    await _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
      for (final r in results) {
        // Filter for targetConvoyId in manufacturerSpecificData
        if (_matchesConvoyId(r.advertisementData.manufacturerData, targetConvoyId)) {
          _scanResultController.add(r);
        }
      }
    }, onError: (error) {
      _scanResultController.addError(error);
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10), androidUsesFineLocation: true);
  }

  /// Check if manufacturer data matches the target convoy ID
  bool _matchesConvoyId(Uint8List? data, String targetConvoyId) {
    if (data == null) return false;
    try {
      final advertisedId = String.fromCharCodes(data);
      return advertisedId == targetConvoyId;
    } catch (e) {
      return false;
    }
  }

  Future<void> stopScanning() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    _targetConvoyId = null;
  }
  
  /// Dispose resources
  void dispose() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _l2capSubscription?.cancel();
    _l2capSubscription = null;
    _scanResultController.close();
    _incomingDataController.close();
    _peripheral.stop();
  }
}

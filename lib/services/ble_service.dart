import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();
  final StreamController<ScanResult> _scanResultController = StreamController<ScanResult>.broadcast();
  Stream<ScanResult> get scanResults => _scanResultController.stream;

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
    FlutterBluePlus.onScanResults.listen((results) {
      for (ScanResult r in results) {
        // Here we'd filter for targetConvoyId in manufacturerSpecificData
        _scanResultController.add(r);
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10), androidUsesFineLocation: true);
  }

  Future<void> stopScanning() async {
    await FlutterBluePlus.stopScan();
  }
}

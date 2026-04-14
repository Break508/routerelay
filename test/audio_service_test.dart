import 'dart:typed_data';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:opus_dart/opus_dart.dart';
import 'package:routerelay/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AudioService audioService;

  setUpAll(() {
    // For VM tests on Linux, load the system library
    if (Platform.isLinux) {
      initOpus(DynamicLibrary.open('/usr/lib/x86_64-linux-gnu/libopus.so.0') as dynamic);
    }
  });

  setUp(() {
    audioService = AudioService();
  });

  test('AudioService.encode should return non-empty data', () async {
    // 320 samples (20ms at 16kHz) of silent PCM 16-bit
    final pcmData = Int16List(320); 
    final result = await audioService.encode(pcmData.buffer.asUint8List());
    expect(result, isNotEmpty);
  });
}

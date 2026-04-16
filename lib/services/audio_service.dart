import 'dart:typed_data';
import 'dart:math' as math;
import 'package:opus_dart/opus_dart.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioRecorder? _recorder;
  AudioPlayer? _player;
  SimpleOpusEncoder? _encoder;
  SimpleOpusDecoder? _decoder;

  static const int sampleRate = 16000;
  static const int channels = 1;

  AudioRecorder get recorder => _recorder ??= AudioRecorder();
  AudioPlayer get player => _player ??= AudioPlayer();

  // Use circular buffer with typed data for better performance
  final _pcmBuffer = Uint8List(4096);
  int _bufferPosition = 0;
  
  // Voice Activity Detection threshold (simple energy-based)
  static const double _vadThreshold = 50.0;

  void _ensureEncoder() {
    _encoder ??= SimpleOpusEncoder(
      sampleRate: sampleRate,
      channels: channels,
      application: Application.voip,
    );
  }

  Future<Uint8List> encode(Uint8List pcmData) async {
    _ensureEncoder();
    // Opus expects Int16List for 16-bit PCM
    final Int16List int16pcm = pcmData.buffer.asInt16List();
    return _encoder!.encode(input: int16pcm);
  }

  /// Check if audio frame contains speech using simple energy-based VAD
  bool _hasSpeech(Uint8List pcmData) {
    // Calculate RMS energy
    double sum = 0;
    final int16Data = pcmData.buffer.asInt16List();
    for (var i = 0; i < int16Data.length; i++) {
      sum += int16Data[i] * int16Data[i];
    }
    final rms = math.sqrt(sum / int16Data.length);
    return rms > _vadThreshold;
  }

  Future<void> startRecording(Function(Uint8List) onData, {bool useVad = true}) async {
    if (await recorder.hasPermission()) {
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: channels,
      );
      final stream = await recorder.startStream(config);
      stream.listen((data) async {
        // Append to circular buffer
        for (var byte in data) {
          _pcmBuffer[_bufferPosition++] = byte;
          if (_bufferPosition >= _pcmBuffer.length) {
            _bufferPosition = 0;
          }
        }
        
        // 20ms frame at 16kHz, mono, 16-bit = 16000 * 0.02 * 1 * 2 = 640 bytes
        const frameSizeInBytes = 640;
        
        // Process frames when we have enough data
        if (_bufferPosition >= frameSizeInBytes || _bufferPosition == 0 && data.length >= frameSizeInBytes) {
          Uint8List frame;
          if (data.length >= frameSizeInBytes) {
            frame = data.sublist(0, frameSizeInBytes);
          } else {
            // Extract from circular buffer
            final startIdx = (_bufferPosition - frameSizeInBytes + _pcmBuffer.length) % _pcmBuffer.length;
            if (startIdx + frameSizeInBytes <= _pcmBuffer.length) {
              frame = _pcmBuffer.sublist(startIdx, startIdx + frameSizeInBytes);
            } else {
              // Wrap around case
              frame = Uint8List(frameSizeInBytes);
              final firstPart = _pcmBuffer.sublist(startIdx);
              final secondPart = _pcmBuffer.sublist(0, frameSizeInBytes - firstPart.length);
              frame.setRange(0, firstPart.length, firstPart);
              frame.setRange(firstPart.length, frameSizeInBytes, secondPart);
            }
          }
          
          // Apply VAD if enabled
          if (!useVad || _hasSpeech(frame)) {
            final encoded = await encode(frame);
            onData(encoded);
          }
        }
      });
    }
  }

  Future<void> stopRecording() async {
    await recorder.stop();
    _bufferPosition = 0;
  }

  Future<void> play(Uint8List opusData) async {
    // Decoding back to PCM for now, although playback needs a PCM-capable player
    // This is a placeholder for actual playback logic
    _decoder ??= SimpleOpusDecoder(sampleRate: sampleRate, channels: channels);
    // Int16List pcm = _decoder!.decode(input: opusData, frameSize: 320); // 20ms at 16k
    // TODO: Implement actual playback of PCM data
  }

  void dispose() {
    _encoder?.destroy();
    _decoder?.destroy();
    _recorder?.dispose();
    _player?.dispose();
  }
}

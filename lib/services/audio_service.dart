import 'dart:typed_data';
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

  final List<int> _pcmBuffer = [];

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

  Future<void> startRecording(Function(Uint8List) onData) async {
    if (await recorder.hasPermission()) {
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: channels,
      );
      final stream = await recorder.startStream(config);
      stream.listen((data) async {
        _pcmBuffer.addAll(data);
        // 20ms frame at 16kHz, mono, 16-bit = 16000 * 0.02 * 1 * 2 = 640 bytes
        const frameSizeInBytes = 640;
        while (_pcmBuffer.length >= frameSizeInBytes) {
          final frame = Uint8List.fromList(_pcmBuffer.sublist(0, frameSizeInBytes));
          _pcmBuffer.removeRange(0, frameSizeInBytes);
          final encoded = await encode(frame);
          onData(encoded);
        }
      });
    }
  }

  Future<void> stopRecording() async {
    await recorder.stop();
    _pcmBuffer.clear();
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

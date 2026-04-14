import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/audio_service.dart';

class PTTButton extends StatefulWidget {
  final AudioService audioService;
  final Function(Uint8List) onAudioData;

  const PTTButton({super.key, required this.audioService, required this.onAudioData});

  @override
  State<PTTButton> createState() => _PTTButtonState();
}

class _PTTButtonState extends State<PTTButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) {
        setState(() => _isPressed = true);
        widget.audioService.startRecording(widget.onAudioData);
      },
      onLongPressEnd: (_) {
        setState(() => _isPressed = false);
        widget.audioService.stopRecording();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: _isPressed ? Colors.redAccent : Colors.blueAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: _isPressed ? 20 : 10,
              spreadRadius: _isPressed ? 5 : 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isPressed ? Icons.mic : Icons.mic_none,
              color: Colors.white,
              size: 50,
            ),
            const SizedBox(height: 5),
            Text(
              _isPressed ? "TRANSMITTING" : "HOLD TO TALK",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

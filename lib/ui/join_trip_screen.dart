import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class JoinTripScreen extends StatefulWidget {
  final String? convoyId;
  final String? base64TripKey;

  const JoinTripScreen({super.key, this.convoyId, this.base64TripKey});

  @override
  State<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends State<JoinTripScreen> {
  bool _isScanning = false;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Join Convoy")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.convoyId != null && widget.base64TripKey != null)
              Column(
                children: [
                  const Text("Show this to your convoy members", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  QrImageView(
                    data: "${widget.convoyId}|${widget.base64TripKey}",
                    version: QrVersions.auto,
                    size: 250.0,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text("Convoy ID: ${widget.convoyId}"),
                ],
              )
            else if (_isScanning)
              SizedBox(
                height: 400,
                width: 300,
                child: MobileScanner(
                  onDetect: (capture) async {
                    // Prevent multiple detections
                    if (_isProcessing) return;
                    _isProcessing = true;
                    
                    try {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        final String? code = barcode.rawValue;
                        if (code != null && code.contains('|')) {
                          final parts = code.split('|');
                          if (parts.length == 2) {
                            final convoyId = parts[0];
                            final key = parts[1];
                            
                            if (!mounted) return;
                            setState(() => _isScanning = false);
                            Navigator.pop(context, {'id': convoyId, 'key': key});
                            return;
                          }
                        }
                      }
                    } finally {
                      _isProcessing = false;
                    }
                  },
                ),
              )
            else
              ElevatedButton(
                onPressed: () => setState(() => _isScanning = true),
                child: const Text("Scan Lead's QR Code"),
              ),
          ],
        ),
      ),
    );
  }
}

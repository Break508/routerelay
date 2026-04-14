import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/crypto_service.dart';

class JoinTripScreen extends StatefulWidget {
  final String? convoyId;
  final String? base64TripKey;

  const JoinTripScreen({Key? key, this.convoyId, this.base64TripKey}) : super(key: key);

  @override
  _JoinTripScreenState createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends State<JoinTripScreen> {
  bool _isScanning = false;

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
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      final String? code = barcode.rawValue;
                      if (code != null && code.contains('|')) {
                        final parts = code.split('|');
                        final convoyId = parts[0];
                        final key = parts[1];
                        print("Joined Convoy: $convoyId with key: $key");
                        setState(() => _isScanning = false);
                        Navigator.pop(context, {'id': convoyId, 'key': key});
                      }
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../models/telemetry_state.dart';
import '../services/audio_service.dart';
import '../providers/service_providers.dart';
import '../providers/convoy_provider.dart';
import 'widgets/convoy_sidebar.dart';
import 'widgets/ptt_button.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapLibreMapController? _controller;
  final List<TelemetryState> _members = [];
  final double _leadVelocity = 0.0;
  late final AudioService _audioService;
  static const _hardwareKeys = MethodChannel('io.routerelay/hardware_keys');

  @override
  void initState() {
    super.initState();
    _audioService = ref.read(bleServiceProvider).hashCode > 0 ? AudioService() : AudioService();
    
    _hardwareKeys.setMethodCallHandler((call) async {
      if (call.method == 'volumeUpPressed') {
        _audioService.startRecording((data) {
          final meshService = ref.read(meshServiceProvider);
          meshService.broadcastVoice(data);
        });
      } else if (call.method == 'volumeUpReleased') {
        _audioService.stopRecording();
      }
    });

    final meshService = ref.read(meshServiceProvider);
    meshService.voiceStream.listen((data) {
      _audioService.play(data);
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    _updateMarkers(); // Initial marker update
  }

  void _updateMarkers() {
    if (_controller == null) return;
    
    // Efficiently update markers using batch operations
    _controller!.clearSymbols().then((_) {
      final symbols = _members.map((member) {
        final pos = member.getProjectedPosition();
        return SymbolOptions(
          geometry: pos,
          iconSize: 1.0,
          iconImage: 'marker_icon', // You'll need to add this asset
        );
      }).toList();
      
      if (symbols.isNotEmpty) {
        _controller!.addSymbols(symbols);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteRelay Map'),
        actions: [
          // Show convoy status
          Consumer(builder: (context, ref, _) {
            final convoyState = ref.watch(convoyStateProvider);
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  convoyState.isConnected 
                    ? 'Connected: ${convoyState.convoyId ?? "N/A"}'
                    : 'Not Connected',
                  style: TextStyle(
                    color: convoyState.isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Stack(
        children: [
          MapLibreMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 2.0,
            ),
            styleString: "https://demotiles.maplibre.org/style.json",
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: ConvoySidebar(
              members: _members,
              leadVelocity: _leadVelocity,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Center(
              child: PTTButton(
                audioService: _audioService,
                onAudioData: (data) {
                  final meshService = ref.read(meshServiceProvider);
                  meshService.broadcastVoice(data);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

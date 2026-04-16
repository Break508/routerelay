import 'dart:async';
import 'dart:typed_data';

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
  List<TelemetryState> _members = const [];
  final Map<String, Symbol> _memberSymbols = {};
  final double _leadVelocity = 0.0;
  late final AudioService _audioService;
  StreamSubscription<Uint8List>? _voiceSubscription;
  static const _hardwareKeys = MethodChannel('io.routerelay/hardware_keys');

  @override
  void initState() {
    super.initState();
    _audioService = ref.read(audioServiceProvider);

    _hardwareKeys.setMethodCallHandler((call) async {
      if (call.method == 'volumeUpPressed') {
        await _audioService.startRecording((data) {
          final meshService = ref.read(meshServiceProvider);
          unawaited(meshService.broadcastVoice(data));
        });
      } else if (call.method == 'volumeUpReleased') {
        await _audioService.stopRecording();
      }
    });

    final meshService = ref.read(meshServiceProvider);
    _voiceSubscription = meshService.voiceStream.listen((data) {
      unawaited(_audioService.play(data));
    });
  }

  @override
  void dispose() {
    _voiceSubscription?.cancel();
    _voiceSubscription = null;
    _hardwareKeys.setMethodCallHandler(null);
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller;
    unawaited(_updateMarkers()); // Initial marker update
  }

  Future<void> _updateMarkers() async {
    final controller = _controller;
    if (controller == null) return;

    try {
      final nextByUser = <String, TelemetryState>{
        for (final member in _members) member.userId: member,
      };

      final removedUsers = _memberSymbols.keys
          .where((userId) => !nextByUser.containsKey(userId))
          .toList(growable: false);
      for (final userId in removedUsers) {
        final symbol = _memberSymbols.remove(userId);
        if (symbol != null) {
          await controller.removeSymbol(symbol);
        }
      }

      for (final entry in nextByUser.entries) {
        final member = entry.value;
        final options = SymbolOptions(
          geometry: member.getProjectedPosition(),
          iconImage: 'marker-15',
          iconSize: 1.1,
          textField: member.userId,
          textOffset: const Offset(0, 1.2),
          textSize: 11.0,
        );

        final existing = _memberSymbols[entry.key];
        if (existing == null) {
          _memberSymbols[entry.key] = await controller.addSymbol(options);
        } else {
          await controller.updateSymbol(existing, options);
        }
      }
    } catch (_) {
      // Ignore map marker update failures and keep the UI responsive.
    }
  }

  @override
  Widget build(BuildContext context) {
    final convoyState = ref.watch(convoyStateProvider);
    if (!identical(_members, convoyState.members)) {
      _members = List<TelemetryState>.from(convoyState.members);
      unawaited(_updateMarkers());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteRelay Map'),
        actions: [
          // Show convoy status
          Padding(
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
          ),
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
                  unawaited(meshService.broadcastVoice(data));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

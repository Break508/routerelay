import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/convoy_repository.dart';
import '../models/telemetry_state.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Provider for the ConvoyRepository
final convoyRepositoryProvider = Provider<ConvoyRepository>((ref) {
  throw UnimplementedError('Initialize via service locator');
});

/// State class for convoy information
class ConvoyState {
  final String? convoyId;
  final String? userId;
  final bool isLead;
  final List<TelemetryState> members;
  final bool isConnected;
  final String? error;

  ConvoyState({
    this.convoyId,
    this.userId,
    this.isLead = false,
    this.members = const [],
    this.isConnected = false,
    this.error,
  });

  ConvoyState copyWith({
    String? convoyId,
    String? userId,
    bool? isLead,
    List<TelemetryState>? members,
    bool? isConnected,
    String? error,
  }) {
    return ConvoyState(
      convoyId: convoyId ?? this.convoyId,
      userId: userId ?? this.userId,
      isLead: isLead ?? this.isLead,
      members: members ?? this.members,
      isConnected: isConnected ?? this.isConnected,
      error: error ?? this.error,
    );
  }
}

/// Notifier for managing convoy state
class ConvoyNotifier extends StateNotifier<ConvoyState> {
  final ConvoyRepository _repository;

  ConvoyNotifier(this._repository) : super(ConvoyState()) {
    _init();
  }

  void _init() {
    // Initialize with current repository state
    state = state.copyWith(
      convoyId: _repository.currentConvoyId,
      userId: _repository.myUserId,
      isLead: _repository.isLead,
    );
  }

  Future<void> createConvoy() async {
    state = state.copyWith(isConnected: false, error: null);
    
    final result = await _repository.createConvoy();
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message, isConnected: false),
      (_) => state = state.copyWith(
        convoyId: _repository.currentConvoyId,
        userId: _repository.myUserId,
        isLead: _repository.isLead,
        isConnected: true,
        error: null,
      ),
    );
  }

  Future<void> joinConvoy(String convoyId, String base64Key) async {
    state = state.copyWith(isConnected: false, error: null);
    
    final result = await _repository.joinConvoy(convoyId, base64Key);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message, isConnected: false),
      (_) => state = state.copyWith(
        convoyId: _repository.currentConvoyId,
        userId: _repository.myUserId,
        isLead: _repository.isLead,
        isConnected: true,
        error: null,
      ),
    );
  }

  Future<void> leaveConvoy() async {
    final result = await _repository.leaveConvoy();
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => state = ConvoyState(), // Reset state
    );
  }

  Future<void> broadcastTelemetry({
    required double latitude,
    required double longitude,
    required double velocity,
    required double heading,
  }) async {
    await _repository.broadcastTelemetry(
      latitude: latitude,
      longitude: longitude,
      velocity: velocity,
      heading: heading,
    );
  }

  Future<void> addMember(TelemetryState member) async {
    final updatedMembers = [...state.members];
    final existingIndex = updatedMembers.indexWhere((m) => m.userId == member.userId);
    
    if (existingIndex >= 0) {
      updatedMembers[existingIndex] = member;
    } else {
      updatedMembers.add(member);
    }
    
    state = state.copyWith(members: updatedMembers);
  }

  void removeMember(String userId) {
    state = state.copyWith(
      members: state.members.where((m) => m.userId != userId).toList(),
    );
  }

  Future<String?> getExportableKey() async {
    return await _repository.getExportableKey();
  }
}

/// Provider for convoy state management
final convoyStateProvider = StateNotifierProvider<ConvoyNotifier, ConvoyState>((ref) {
  final repository = ref.watch(convoyRepositoryProvider);
  return ConvoyNotifier(repository);
});

/// Provider for voice stream from mesh service
// final voiceStreamProvider = StreamProvider<Uint8List>((ref) {
//   final meshService = ref.watch(meshServiceProvider);
//   return meshService.voiceStream;
// });

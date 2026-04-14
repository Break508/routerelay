# RouteRelay Phase 3: The Voice Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Push-to-Talk (PTT) voice communication using the Opus codec over BLE L2CAP Connection-Oriented Channels.

**Architecture:** 
- **Capture:** Mic input -> Mono 16kHz PCM -> Opus Encoder (6-8 kbps).
- **Transport:** Binary chunks sent via BLE L2CAP CoC for reliability.
- **Playback:** Opus Decoder -> PCM -> Audio Output.
- **Control:** UI button + Hardware Volume Rocker interception (Android).

**Tech Stack:** Flutter, `record`, `audioplayers`, `opus_dart`, Native Platform Channels (L2CAP).

---

### Task 1: Audio Pipeline & Opus Codec

**Files:**
- Create: `lib/services/audio_service.dart`
- Modify: `pubspec.yaml`

- [x] **Step 1: Add Audio Dependencies**
Add `record`, `audioplayers`, `opus_dart`, and `fixnum` to `pubspec.yaml`.
Run: `flutter pub get`

- [x] **Step 2: Implement AudioService**
```dart
class AudioService {
  // Logic for recording PCM and encoding to Opus chunks
  Future<Uint8List> encode(List<int> pcmData) { /* opus_dart */ }
  Future<void> play(Uint8List opusData) { /* decode -> audioplayers */ }
}
```

- [x] **Step 3: Commit**
```bash
git add .
git commit -m "feat: implement audio recording and Opus encoding pipeline"
```

---

### Task 2: BLE L2CAP Transport (Native Bridge)

**Files:**
- Modify: `lib/services/ble_service.dart`
- Create: `android/src/main/kotlin/com/example/routerelay/L2CapPlugin.kt`

- [x] **Step 1: Define L2CAP Platform Channel**
In `lib/services/ble_service.dart`, add a `MethodChannel` for L2CAP CoC (Connection-Oriented Channels).

- [x] **Step 2: Implement Android L2CAP**
Write Kotlin code to open a `BluetoothSocket` using `device.createL2capChannel(psm)`. This is required for high-bandwidth audio streaming that GATT can't handle efficiently.

- [x] **Step 3: Commit**
```bash
git add .
git commit -m "feat: add native L2CAP support for high-bandwidth audio"
```

---

### Task 3: PTT Logic & Hardware Buttons

**Files:**
- Create: `lib/ui/widgets/ptt_button.dart`
- Modify: `lib/main.dart`

- [x] **Step 1: Build PTT Button**
A large, circular "Hold to Speak" button that triggers `AudioService.startRecording()` on down and `stop` on up.

- [x] **Step 2: Intercept Volume Rocker (Android)**
Use a platform channel to listen for `KeyEvent.KEYCODE_VOLUME_UP` to trigger PTT without looking at the screen.

- [x] **Step 3: Commit**
```bash
git add .
git commit -m "feat: implement PTT button and hardware key interception"
```

---

### Task 4: Voice Mesh Integration

**Files:**
- Modify: `protos/mesh.proto`
- Modify: `lib/services/mesh_service.dart`

- [x] **Step 1: Add VOICE Type to Protobuf**
Add `VOICE = 6;` to the `MeshPayload.Type` enum.

- [x] **Step 2: Implement Voice Relay**
In `MeshService`, handle `MeshPayload_Type.VOICE`. Use the Gossip logic to relay audio chunks, ensuring "Tier 3" priority (buffered, not live-broadcast if mesh is congested).

- [x] **Step 3: Commit**
```bash
git add .
git commit -m "feat: integrate voice communication into the gossip mesh"
```

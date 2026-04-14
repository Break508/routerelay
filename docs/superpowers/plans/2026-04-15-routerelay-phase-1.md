# RouteRelay Phase 1: The Backbone Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the foundational BLE-based gossip network using Protobuf for location and text sharing, with mutual authentication via QR codes.

**Architecture:** A Flutter-based app using native platform channels for BLE. It implements a Layer 7 B.A.T.M.A.N.-inspired OGM (Originator Message) logic for decentralized routing.

**Tech Stack:** Flutter, Dart, Protobuf, flutter_blue_plus, Isar (Local DB).

---

### Task 1: Project Initialization & Protobuf Setup

**Files:**
- Create: `pubspec.yaml`
- Create: `protos/mesh.proto`
- Create: `lib/models/mesh_message.dart`

- [ ] **Step 1: Initialize Flutter Project**
Run: `flutter create . --platforms=android,ios`
Expected: Project structure created.

- [ ] **Step 2: Add Dependencies**
Add `protobuf`, `flutter_blue_plus`, `isar`, `isar_flutter_libs`, `path_provider`, `crypto` to `pubspec.yaml`.
Run: `flutter pub get`

- [ ] **Step 3: Define Protobuf Schema**
```protobuf
syntax = "proto3";

message MeshPayload {
  enum Type {
    SOS = 0;
    TELEMETRY = 1;
    TEXT = 2;
    OGM = 3;
  }
  string convoy_id = 1;
  string sender_id = 2;
  uint64 timestamp = 3;
  uint32 hop_count = 4;
  Type type = 5;
  bytes data = 6;
  bytes signature = 7;
}

message Telemetry {
  double lat = 1;
  double lng = 2;
  double velocity = 3;
  double heading = 4;
}
```

- [ ] **Step 4: Generate Dart Protos**
Run: `protoc --dart_out=lib/generated protos/mesh.proto`
Expected: `lib/generated/mesh.pb.dart` exists.

- [ ] **Step 5: Commit**
```bash
git add .
git commit -m "feat: init project and protobuf schema"
```

---

### Task 2: BLE Discovery & OGM Logic

**Files:**
- Create: `lib/services/ble_service.dart`
- Create: `lib/services/mesh_service.dart`

- [ ] **Step 1: Implement BLE Scanner/Advertiser**
```dart
class BleService {
  void startAdvertising(String convoyId) {
    // Uses flutter_blue_plus to broadcast Convoy ID in Manufacturer Data
  }
  Stream<ScanResult> startScanning() {
    // Scans for matching Convoy IDs
  }
}
```

- [ ] **Step 2: Implement B.A.T.M.A.N. OGM Broadcast**
```dart
class MeshService {
  void broadcastOGM() {
    final ogm = MeshPayload(
      type: MeshPayload_Type.OGM,
      hopCount: 0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    _bleService.send(ogm.writeToBuffer());
  }
}
```

- [ ] **Step 3: Test OGM Serialization**
Write a test in `test/mesh_service_test.dart` to verify Protobuf encoding/decoding.

- [ ] **Step 4: Commit**
```bash
git add .
git commit -m "feat: implement BLE OGM discovery logic"
```

---

### Task 3: QR Handshake & Security

**Files:**
- Create: `lib/services/crypto_service.dart`
- Create: `lib/ui/join_trip_screen.dart`

- [ ] **Step 1: Implement AES Key Generation**
```dart
class CryptoService {
  String generateTripKey() => // Secure random 32 bytes
  Uint8List encrypt(Uint8List data, String key) => // AES-GCM
}
```

- [ ] **Step 2: Create QR Generation UI**
Display a QR code containing `convoyId|tripKey`.

- [ ] **Step 3: Implement QR Scanner**
Use `mobile_scanner` to parse the key and join the mesh.

- [ ] **Step 4: Commit**
```bash
git add .
git commit -m "feat: add QR-based mutual authentication"
```

---

### Task 4: Distance-Vector Gossip Relay

**Files:**
- Modify: `lib/services/mesh_service.dart`

- [ ] **Step 1: Implement Relay Logic with Pruning**
```dart
void onMessageReceived(MeshPayload msg) {
  if (hasSeen(msg.id)) return;
  if (msg.hopCount >= MAX_HOPS) return;
  
  // Distance-Vector check
  if (msg.hopCount < localHopCountToLead) {
    relay(msg.rebuild((b) => b.hopCount++));
  }
}
```

- [ ] **Step 2: Run Mock Mesh Test**
Verify message propagation across 3 mock nodes in a unit test.

- [ ] **Step 3: Commit**
```bash
git add .
git commit -m "feat: implement distance-vector gossip relay"
```

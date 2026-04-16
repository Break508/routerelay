# RouteRelay Phase 4: The Gateway & High-Bandwidth P2P

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement headless Linux gateway support and Android Wi-Fi Aware (NAN) for high-bandwidth peer-to-peer data transfer.

**Architecture:** 
- **Headless Gateway:** A pure Dart CLI entry point for Linux (Raspberry Pi) using `bluez` for BLE mesh relaying without a UI.
- **Wi-Fi Aware:** Use Android NAN for Tier 4 (Map Tiles) and Tier 3 (Voice) to offload BLE when devices are in range, providing much higher bandwidth.

**Tech Stack:** Dart CLI, `bluez`, `dbus`, `wifi_aware` (Android), `path` (for CLI paths).

---

### Task 1: Headless Linux Gateway Entry Point

**Files:**
- Create: `bin/routerelay_gateway.dart`
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add Linux CLI Dependencies**
Add `bluez`, `dbus`, and `args` to `pubspec.yaml`.
Run: `flutter pub get`

- [ ] **Step 2: Create Gateway Entry Point**
```dart
import 'package:args/args.dart';
import 'package:routerelay/services/mesh_service.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('convoy', abbr: 'c', help: 'Convoy ID')
    ..addOption('id', abbr: 'i', help: 'Node ID');
  
  final argResults = parser.parse(arguments);
  final convoyId = argResults['convoy'];
  final nodeId = argResults['id'];

  if (convoyId == null || nodeId == null) {
    print('Usage: dart bin/routerelay_gateway.dart -c <convoy_id> -i <node_id>');
    return;
  }

  print('Starting RouteRelay Gateway for Convoy: $convoyId...');
  final mesh = MeshService();
  mesh.init(convoyId, nodeId, isLead: false);
  
  // Keep the process alive
  ProcessSignal.sigint.watch().listen((_) {
    print('Shutting down...');
    exit(0);
  });
}
```

- [ ] **Step 3: Test CLI Execution**
Run: `/home/zer0day/Development/flutter/bin/cache/dart-sdk/bin/dart bin/routerelay_gateway.dart --help`
Expected: Shows help menu.

- [ ] **Step 4: Commit**
```bash
git add .
git commit -m "feat: add headless Linux gateway entry point"
```

---

### Task 2: Android Wi-Fi Aware (NAN) Implementation

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `lib/services/wifi_aware_service.dart`

- [ ] **Step 1: Update Android Manifest**
Add permissions for `ACCESS_WIFI_STATE`, `CHANGE_WIFI_STATE`, `ACCESS_FINE_LOCATION`, and the `android.hardware.wifi.aware` feature.

- [ ] **Step 2: Implement WifiAwareService**
```dart
import 'package:wifi_aware/wifi_aware.dart';

class WifiAwareService {
  Future<void> start(String convoyId) async {
    if (await WifiAware.isAvailable()) {
      final session = await WifiAware.attach();
      // Publish/Subscribe based on convoyId
    }
  }
}
```

- [ ] **Step 3: Commit**
```bash
git add .
git commit -m "feat: implement Android Wi-Fi Aware for high-bandwidth P2P"
```

---

### Task 3: Cross-Transport Relay Logic

**Files:**
- Modify: `lib/services/mesh_service.dart`

- [ ] **Step 1: Integrate Wi-Fi Aware into Mesh**
Update `MeshService` to prefer Wi-Fi Aware for large payloads (Tier 3/4) when a peer is discovered via NAN.

- [ ] **Step 2: Commit**
```bash
git add .
git commit -m "feat: prefer Wi-Fi Aware for high-bandwidth mesh traffic"
```

---

### Task 4: Linux BLE Support via bluez

**Files:**
- Modify: `lib/services/ble_service.dart`

- [ ] **Step 1: Add Conditional BLE for Linux**
Use the `bluez` package to implement `startScanning` and `startAdvertising` for Linux when running in headless mode.

- [ ] **Step 2: Commit**
```bash
git add .
git commit -m "feat: add native Linux BLE support via bluez"
```

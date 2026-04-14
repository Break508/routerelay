# RouteRelay Phase 2: The Canvas Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement offline map rendering, dynamic tile sharing over the mesh, and predictive telemetry for "ghost" vehicles.

**Architecture:** Integration of MapLibre GL for offline vector maps. Telemetry data (Tier 1) is broadcast via the Phase 1 mesh, and missing map tiles are requested and served opportunistically between peers.

**Tech Stack:** Flutter, MapLibre GL, Protobuf, Isar, Geology/Vector math for breadcrumbs.

---

### Task 1: MapLibre Integration & Offline Caching

**Files:**
- Create: `lib/ui/map_screen.dart`
- Create: `lib/services/map_service.dart`

- [ ] **Step 1: Add MapLibre Dependencies**
Add `maplibre_gl` to `pubspec.yaml`.
Run: `flutter pub get`

- [ ] **Step 2: Implement Map Service**
```dart
class MapService {
  // Logic for managing offline tile regions and caching
  Future<void> downloadRegion(LatLngBounds bounds) async {
    // Uses MapLibre's offline manager
  }
}
```

- [ ] **Step 3: Create Basic Map UI**
Initialize a `MapLibreMap` with a local style JSON.

- [ ] **Step 4: Commit**
```bash
git add .
git commit -m "feat: integrate MapLibre and offline map service"
```

---

### Task 2: Telemetry & Predictive Breadcrumbs

**Files:**
- Create: `lib/models/telemetry_state.dart`
- Modify: `lib/services/mesh_service.dart`

- [ ] **Step 1: Update Protobuf for Telemetry** (Already done in Phase 1, but ensure logic is tied)
- [ ] **Step 2: Implement Dead Reckoning Logic**
```dart
class TelemetryState {
  LatLng lastKnownPosition;
  double velocity;
  double heading;
  DateTime timestamp;

  LatLng getProjectedPosition() {
    // Calculate new position based on velocity and heading since timestamp
  }
}
```

- [ ] **Step 3: Broadcast Periodic Telemetry**
Set up a timer in `MeshService` to broadcast `Telemetry` payloads every 10 seconds.

- [ ] **Step 4: Commit**
```bash
git add .
git commit -m "feat: implement telemetry broadcasting and predictive breadcrumbs"
```

---

### Task 3: Opportunistic Tile Sync (Tier 4)

**Files:**
- Modify: `protos/mesh.proto`
- Modify: `lib/services/mesh_service.dart`

- [ ] **Step 1: Add Tile Messaging to Protobuf**
```protobuf
message TileRequest {
  int32 z = 1;
  int32 x = 2;
  int32 y = 3;
}

message TileResponse {
  int32 z = 1;
  int32 x = 2;
  int32 y = 3;
  bytes tile_data = 4;
}
```

- [ ] **Step 2: Implement Tile Request/Response Logic**
When the map hits a 404/missing tile, broadcast `TileRequest`. Any peer with the tile in their Isar cache responds with `TileResponse`.

- [ ] **Step 3: Commit**
```bash
git add .
git commit -m "feat: implement opportunistic tile mesh sync"
```

---

### Task 4: Convoy HUD & Formation View

**Files:**
- Create: `lib/ui/widgets/convoy_sidebar.dart`
- Modify: `lib/ui/map_screen.dart`

- [ ] **Step 1: Build Convoy Sidebar**
A vertical list showing convoy members, their relative speed delta, and distance.

- [ ] **Step 2: Overlay Avatars on Map**
Render markers for all convoy members. Use "Ghost" icons for projected positions when data is stale.

- [ ] **Step 3: Commit**
```bash
git add .
git commit -m "feat: add convoy HUD and map avatars"
```

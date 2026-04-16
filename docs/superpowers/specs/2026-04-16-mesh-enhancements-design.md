# Mesh Connectivity and Performance Enhancements Design

> **Topic:** Scaling RouteRelay with Multi-peer L2CAP, Mesh Isolates, and Priority Queueing.
> **Status:** Draft
> **Date:** 2026-04-16

## 1. Overview
This design addresses the core "brain" of RouteRelay, transforming it from a simple 1:1 relay into a high-performance, multi-peer mesh network. We prioritize UI responsiveness (60fps), high-density connectivity (multiple BLE peers), and network intelligence (priority-based routing).

## 2. Connectivity: Multi-Peer L2CAP (Android)
The current implementation only supports a single connection. To scale, we must maintain concurrent links to multiple nearby devices.

### Components
- **L2CapSocketPool (Kotlin):** A `ConcurrentHashMap<String, BluetoothSocket>` managing active connections.
- **Connection Lifecycle:** 
    - `open(deviceId, psm)`: Adds a new socket to the pool if not already present.
    - `close(deviceId)`: Closes and removes a specific socket.
    - `send(deviceId, data)`: Sends bytes to a specific peer or broadcasts to all connected peers if `deviceId` is null.
- **Read Loop (Coroutines):** Each socket in the pool runs an infinite `read` loop in `Dispatchers.IO`. 
- **EventChannel:** A single stream that pushes `IncomingMessage` objects (byte array + sender device ID) to Dart.

## 3. Concurrency: The Mesh Isolate
Processing mesh packets (Protobuf decoding, routing table updates, deduplication) on the UI thread causes jank. We'll offload this to a dedicated long-lived Isolate.

### Data Flow
1. **Main Isolate:** Receives raw bytes from `EventChannel` (native).
2. **Transfer:** Raw bytes are wrapped in `TransferableTypedData` and sent via `SendPort` to the Mesh Isolate. This ensures zero-copy memory movement.
3. **Mesh Isolate:**
    - Decodes `MeshPayload` using Protobuf.
    - Checks `Deduplicator` (TTL-based map).
    - Updates `RoutingTable` (B.A.T.M.A.N. algorithm).
    - If message needs relay: Adds to `PriorityQueue`.
    - If message is for local consumption: Sends high-level Dart objects back to Main Isolate.

## 4. Network Intelligence: Priority Queueing & Adaptive Voice
In a congested mesh, we must ensure critical data (SOS, Voice) gets through before background data (Map Tiles).

### Priority Queue (PQ)
The Mesh Isolate maintains a PQ for outgoing messages:
1. **Priority 1 (SOS):** Immediate relay.
2. **Priority 2 (Voice):** Jitter-sensitive, high priority.
3. **Priority 3 (Telemetry):** Medium priority.
4. **Priority 4 (Tiles/Text):** Low priority, best-effort.

### Adaptive Voice Feedback
The `MeshIsolate` monitors the size of the Priority Queue.
- **High Pressure:** If PQ size > Threshold, send a `CongestionSignal` to Main Isolate.
- **Response:** `AudioService` reduces Opus bitrate (e.g., 16kbps -> 8kbps) or increases frame size (20ms -> 60ms) to reduce packet overhead.

## 5. Implementation Roadmap
1. **Task 1:** Refactor `L2CapPlugin.kt` for multi-peer support and `EventChannel`.
2. **Task 2:** Scaffold the `MeshIsolate` and implement `TransferableTypedData` communication.
3. **Task 3:** Migrate `MeshService` logic into the Isolate and implement the `PriorityQueue`.
4. **Task 4:** Add the `CongestionSignal` feedback loop to `AudioService`.

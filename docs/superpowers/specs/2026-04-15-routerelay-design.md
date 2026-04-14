# RouteRelay: Production-Hardened MANET for Convoys

**Date:** 2026-04-15
**Status:** Final Spec (Refined for Mobile Reality)
**Target Platforms:** Android (Full Relay), iOS (Client-Only Phase 1), Linux (Headless Gateway)

## 1. Executive Summary
RouteRelay is a decentralized Mobile Ad-hoc Network (MANET) providing resilient communication and navigation for vehicle convoys. It prioritizes location awareness and safety through predictive telemetry and an application-layer gossip protocol.

## 2. Protocol & State Management
*   **Layer 7 Doppler-Aware B.A.T.M.A.N. OGM:** Proactive routing logic implemented at the application layer. OGMs (Originator Messages) are broadcast via BLE Manufacturer Specific Data. Routing metrics are weighted by **RSSI + Relative Velocity** (Doppler-aware) to favor stable links.
*   **Merkle Tree State Reconciliation:** Rejoining nodes perform an O(log N) handshake to sync missed Tier 2 (Text) and Tier 4 (Map) updates without re-broadcasting the entire history.
*   **Serialization:** **Protobuf** for all high-priority telemetry (Tier 0-2).

## 3. Security & Anti-Spoofing
*   **Consensus-Based Location Verification:** Mesh nodes compare reported GPS coordinates against BLE RSSI triangulation. Significant discrepancies (e.g., claiming 10ft away but signal is -95dBm) flag a node as "Spoofed" and mute its telemetry.
*   **Mutual Authentication:** Mandatory QR-code handshake for E2EE (AES-256-GCM) and Sybil mitigation.

## 4. Hardware & Failover
*   **Persistent Node Priority (PNP):** Nodes carry a priority byte (0x00 Follower, 0x64 Lead, 0xFF Gateway). The highest-priority active node automatically assumes the "Master Route" and "Map Tile" broadcast roles.
*   **IMU-Based Automatic SOS:** Local crash detection via phone accelerometer/gyroscope (Rollover/High-G event). If not canceled within 15s, a Tier 0 SOS is blasted to the mesh.
*   **Headless Gateways:** Dedicated Linux nodes (RPi) handle heavy relay tasks and provide persistent network backbone.

## 5. Platform-Specific Reality
*   **Android:** Full mesh capability; background relaying via WorkManager/Foreground Services.
*   **iOS (Phase 1):** **Client-Only**. iOS nodes can receive telemetry and send/receive text but cannot act as Relay Nodes in the B.A.T.M.A.N. mesh due to background BLE restrictions.
*   **iOS UI:** Explicit "Relay Unavailable: Keep app in foreground" warning.

## 6. Traffic Tiering (Priority Queue)
1.  **Tier 0 (SOS):** Automatic (IMU) or Manual; Protobuf; Highest Priority.
2.  **Tier 1 (Telemetry):** Location/Velocity/Heading; Protobuf; Predictive "Ghost" rendering.
3.  **Tier 2 (Comms):** Text/Haptics; Protobuf; Merkle-synced.
4.  **Tier 3 (Voice):** Opus/L2CAP; Medium-Low Priority.
5.  **Tier 4 (Data):** Binary Chunks; Lowest Priority (Opportunistic Map Tiles).

## 7. Implementation Milestones (Revised)
1.  **Phase 1 (The Tracker):** BLE OGM Discovery, Protobuf Telemetry, and **Predictive Breadcrumbs** (Ghost cars).
2.  **Phase 2 (The Link):** Tier 2 Text Messaging and Merkle Tree History Reconciliation.
3.  **Phase 3 (The Canvas):** MapLibre integration and Opportunistic "Map Painting" (Tile Mesh).
4.  **Phase 4 (The Voice):** BLE L2CAP Opus streaming and Hardware PTT mapping.
5.  **Phase 5 (The Gateway):** Headless Linux support and Wi-Fi Aware (NAN) for Android.

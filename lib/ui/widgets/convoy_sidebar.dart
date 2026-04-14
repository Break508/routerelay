import 'package:flutter/material.dart';
import '../../models/telemetry_state.dart';

class ConvoySidebar extends StatelessWidget {
  final List<TelemetryState> members;
  final double leadVelocity;

  const ConvoySidebar({super.key, required this.members, required this.leadVelocity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.black.withOpacity(0.8),
      child: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final double delta = member.velocity - leadVelocity;
          final isStale = DateTime.now().difference(member.timestamp).inSeconds > 30;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isStale ? Colors.grey : Colors.green,
              child: Text(member.userId[0].toUpperCase()),
            ),
            title: Text(member.userId, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              "${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} m/s",
              style: TextStyle(color: delta >= 0 ? Colors.green : Colors.red),
            ),
            trailing: isStale ? const Icon(Icons.timer_off, color: Colors.orange, size: 16) : null,
          );
        },
      ),
    );
  }
}

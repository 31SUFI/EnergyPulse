import 'package:flutter/material.dart';
import '../model/firebase_schedule_model.dart';
import '../provider/firebase_schedule_provider.dart';

class FirebaseScheduleCard extends StatelessWidget {
  final FirebaseSchedule schedule;
  final FirebaseScheduleProvider provider;

  const FirebaseScheduleCard({
    Key? key,
    required this.schedule,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = _isScheduleActive(schedule.startTime, schedule.endTime, TimeOfDay.now());
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text(schedule.relay.toString())),
        title: Text('Relay ${schedule.relay} - ${schedule.action}'),
        subtitle: Text('${schedule.startTime} - ${schedule.endTime} • ${isActive ? "Active Now" : "Upcoming"}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: schedule.enabled,
              onChanged: (val) => provider.updateSchedule(schedule.id, {'enabled': val}),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => provider.deleteSchedule(schedule.id),
            ),
          ],
        ),
      ),
    );
  }

  bool _isScheduleActive(String start, String end, TimeOfDay now) {
    final startParts = start.split(':').map(int.parse).toList();
    final endParts = end.split(':').map(int.parse).toList();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = startParts[0] * 60 + startParts[1];
    final endMinutes = endParts[0] * 60 + endParts[1];
    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
  }
}
